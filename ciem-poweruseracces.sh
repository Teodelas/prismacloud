#!/bin/bash 
PC_APIURL=""
PC_ACCESSKEY=""
PC_SECRETKEY=""

AUTH_PAYLOAD=$(cat <<EOF
{"username": "$PC_ACCESSKEY", "password": "$PC_SECRETKEY"}
EOF
)

PC_JWT_RESPONSE=$(curl -s --request POST \
                       --url "$PC_APIURL/login" \
                       --header 'Accept: application/json; charset=UTF-8' \
                       --header 'Content-Type: application/json; charset=UTF-8' \
                       --data "${AUTH_PAYLOAD}")


PC_JWT=$(printf %s "$PC_JWT_RESPONSE" | jq -r '.token' )

REPORT_DATE=$(date  +%m_%d_%y)
REPORT_LOCATION="$HOME/reports/CIEM_PowerUserAccess_$REPORT_DATE.csv"
mkdir -p $HOME/reports
# 
query_prismacloud(){

    rql_request_body=$(cat <<EOF
    {
    "query": "config from iam where source.cloud.type = 'AWS' and grantedby.cloud.policy.name = 'PowerUserAccess'", 
    "groupByFields":["source","sourceCloudAccount","grantedByEntity","entityCloudAccount","grantedByPolicy","policyCloudAccount"],
    "nextPageToken": "$next_page_token"
    }
EOF
    )

    curl -L -X POST "$PC_APIURL/iam/api/v4/search/permission" \
        --header "accept: application/json; charset=UTF-8" \
        --header "content-type: application/json" \
        --header "x-redlock-auth: $PC_JWT" \
        --data-raw "$rql_request_body" > temp.json

    next_page_token=$(jq -r '.data.nextPageToken' temp.json)
    total_rows=$(jq -r '.data.totalRows' temp.json)

    cat temp.json | jq ' .data.items[]' | jq -r '[.sourceResourceId, .sourceCloudAccount, .grantedByCloudEntityId, .grantedByCloudEntityAccount, .grantedByCloudPolicyName, .grantedByCloudPolicyAccount, .grantedByCloudPolicyType ] | @csv' >> $REPORT_LOCATION

}

echo "Resource ID, Resource Cloud Account, Granted By Entity, Entity Cloud Account, Granted By Policy, Policy Cloud Account, Policy Type" > $REPORT_LOCATION

#query prisma cloud to get total rows and the next page token
query_prismacloud



chunk_size=1000

for ((i=0; i<total_rows; i+=chunk_size)); do
    start=$i
    end=$((i + chunk_size - 1))

    # Ensure the end index does not exceed the total number of items
    if [ $end -ge $total_items ]; then
        end=$((total_items - 1))
    fi

    echo "Processing items from $start to $end"
    query_prismacloud

done

