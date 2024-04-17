#Update variables
PC_APIURL="https://apix.prismacloud.io"
PC_ACCESSKEY=""
PC_SECRETKEY=""
REPORT_DATE=$(date  +%m_%d_%y)
REPORT_LOCATION="$HOME/reports/alert_report_$REPORT_DATE.csv"
mkdir -p $HOME/reports

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

echo "Cloud Account Id, Account Name, Cloud and Region, Resource Type, Resource Name, Alert on Policy, Description, Policy Severity, Recommendation, Status" > $REPORT_LOCATION

curl -L -X GET \
        --url "$PC_APIURL/v2/alert?alert.status=open&detailed=true" \
        -H 'Accept: */*' \
        -H 'Content-Type: application/json; charset=UTF-8' \
        -H "x-redlock-auth: $PC_JWT" | jq .items[] | jq -r '[.resource.accountId, .resource.account, .resource.region, .resource.resourceType, .resource.name, .policy.name, .policy.description, .policy.severity, .policy.recommendation, .status] | @csv' >> $REPORT_LOCATION

