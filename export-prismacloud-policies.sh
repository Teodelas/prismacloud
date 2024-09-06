#!/bin/bash 
PC_APIURL="https://apix.prismacloud.io"
PC_ACCESSKEY=""
PC_SECRETKEY=""
CLOUD_TYPE=""

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
REPORT_LOCATION="$HOME/reports/prisma_cloud_policies_$REPORT_DATE.csv"
mkdir -p $HOME/reports
echo "Name, Clout Type, Compliance Standard Name, Compliance Standard Description, Compliance Section Description, " > $REPORT_LOCATION
curl -L -X GET \
        --url "$PC_APIURL/v2/policy?cloud.type=$CLOUD_TYPE" \
        -H 'Accept: */*' \
        -H 'Content-Type: application/json; charset=UTF-8' \
        -H "x-redlock-auth: $PC_JWT" | jq -r '.[] | [.name, .cloudType, .complianceMetadata[0].standardName, .complianceMetadata[0].standardDescription, .complianceMetadata[0].sectionDescription] | @csv' >> $REPORT_LOCATION




