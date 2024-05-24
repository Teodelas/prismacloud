PC_APIURL=""
TOKEN=""

#Get the count. curl -I not working
curl -s -D headers.txt -o /dev/null -k \
-H "Authorization: Bearer $TOKEN" \
-H 'Accept: application/json, text/plain, */*' \
"$PC_APIURL/api/v1/cloud-scan-rules?limit=1"
TOTAL_COUNT=$(grep "Total-Count" headers.txt | awk '{print $2}' | tr -d '\r')

STEP=100
#Create CSV & add header
REPORT_DATE=$(date  +%m_%d_%y)
mkdir -p $HOME/reports
REPORT_LOCATION="$HOME/reports/PC_Host_report_$REPORT_DATE.csv"
echo "type, accountID, accountName, successful, unsupported, Issues, Pending, lastScan" > $REPORT_LOCATION

#Iterate through account list and get the data aggregated by account
for ((OFFSET=0; OFFSET<=TOTAL_COUNT; OFFSET+=STEP)); do
curl -k -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/json, text/plain, */*' \
    "$PC_APIURL/api/v1/cloud-scan-rules?offset=$OFFSET&limit=100" | jq -r '
    (.[] | [
        .credential.type,
        .credential.accountID,
        .credential.accountName,
        (.agentlessAccountState.regions // [] | map(.scanCoverage.successful) | add),
        (.agentlessAccountState.regions // [] | map(.scanCoverage.unsupported) | add),
        (.agentlessAccountState.regions // [] | map(.scanCoverage.issued) | add),
        (.agentlessAccountState.regions // [] | map(.scanCoverage.pending) | add),
        .agentlessAccountState.lastScan
    ]) | @csv' >> $REPORT_LOCATION
done
