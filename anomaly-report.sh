#Update variables
PC_APIURL="https://apix.prismacloud.io"
PC_ACCESSKEY=""
PC_SECRETKEY=""
REPORT_DATE=$(date  +%m_%d_%y)
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

declare -A anomaly_reports
anomaly_reports=("WORM_alerts:69c707bb-9f42-4501-b403-013e84be5f99" "Trojan_alerts:ad51ce53-c0bc-460e-a535-1c1d0344abec" "File_Infector:1fd2c019-6af7-4382-8a40-6d2d06abb0e5" "Remote_Commands:79c81276-74c4-4575-ba02-33c3d37f5cf7" "Downloader_Activity:bc9a976a-906c-4f56-8c0d-c6aa8190304a" "Backdoor_Activity:361cf3cf-54f1-43fd-b474-b960b50eb6d5" "DDoS_Activity:c3f8b692-6761-47f2-b97c-344c750abd9d" "Cryptominer_Activity:56948190-3aa1-4d06-a2b5-21f68822b59b" "Hacking_Tool:028edd58-52b0-4b6b-8e18-80c7ca9d7cdc")

#WORM alerts:69c707bb-9f42-4501-b403-013e84be5f99
#Trojen alerts:ad51ce53-c0bc-460e-a535-1c1d0344abec
#File Infector:1fd2c019-6af7-4382-8a40-6d2d06abb0e5
#Remote Commands:79c81276-74c4-4575-ba02-33c3d37f5cf7
#Downloader Activity:bc9a976a-906c-4f56-8c0d-c6aa8190304a
#Backdoor Activity:361cf3cf-54f1-43fd-b474-b960b50eb6d5
#DDoS Activity:c3f8b692-6761-47f2-b97c-344c750abd9d
#Cryptominer Activity:56948190-3aa1-4d06-a2b5-21f68822b59b
#Hacking Tool:028edd58-52b0-4b6b-8e18-80c7ca9d7cdc

REPORT_LOCATION="$HOME/reports/anomaly_alert_report_$REPORT_DATE.csv"

export POLICY_ID="69c707bb-9f42-4501-b403-013e84be5f99"

echo "Alert Id, Resource Name, Resource ID, Account Id, Account, Region, Resource Type, Anomalous Public IP" > $REPORT_LOCATION
curl -L -X GET \
        --url "$PC_APIURL/v2/alert?timeType=relative&timeAmount=1&timeUnit=year&detailed=false&alert.status=open&policy.id=$POLICY_ID" \
        --header "accept: application/json; charset=UTF-8" \
        --header "content-type: application/json" \
        --header "x-redlock-auth: $PC_JWT" | jq ' .items[]' | jq -r '[.id, .resource.name, .resource.id, .resource.accountId, .resource.account, .resource.region, .resource.resourceType, .anomalyDetail.targetHost.ip] | @csv' >> $REPORT_LOCATION
