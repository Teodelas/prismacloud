PC_APIURL="https://apix.prismacloud.io"
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
REPORT_LOCATION="$HOME/reports/prisma_cloud_repositories_$REPORT_DATE.csv"
mkdir -p $HOME/reports
echo "Full Name, URL, Provider, Archived, Last Updated, Last Commit Timestamp " > $REPORT_LOCATION
curl -L -X POST \
        --url "$PC_APIURL/code/api/v1/vcs-repository/repositories" \
        -H 'Accept: */*' \
        -H 'Content-Type: application/json; charset=UTF-8' \
        -H "authorization: $PC_JWT" | jq -r '.[] | [.fullName, .url, .provider, .isArchived, .lastUpdated, (.lastCommitTimestamp / 1000 | strftime("%Y-%m-%d %H:%M:%S %Z"))] | @csv' >> $REPORT_LOCATION
