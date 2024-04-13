#Update with your API endpoint, access key and secret
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

curl -L -X GET \
        --url "$PC_APIURL/v2/alert?alert.status=open&detailed=true&fields=alert.id,policy.name,policy.type,policy.label,policy.severity,resource.name,cloud.type,cloud.account,cloud.accountId,resource.id,alert.status" \
        -H 'Accept: */*' \
        -H 'Content-Type: application/json; charset=UTF-8' \
        -H "x-redlock-auth: $PC_JWT" | jq .items[] | jq -r '[.id, .policy.name, .policy.policyType, .policy.severity, .resource.name, .resource.cloudType, .resource.accountId, .resource.id] | @csv' > output.csv
