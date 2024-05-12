#!/usr/bin/env bash
# requires jq
# written by Teo De Las Heras
# shows all the policies mapped to alert rules in the Prisma Cloud Enterprise edition console for alert rule troubleshooting and routing

PC_APIURL="https://apix.prismacloud.io"
PC_ACCESSKEY=""
PC_SECRETKEY=""

export REPORT_LOCATION=Virtual_Desktop_Session_Hosts.csv
echo "Id, Name, Status, Status Time Stamp" > $REPORT_LOCATION
curl --url "$PC_APIURL/search/api/v2/config" \
     --header "accept: application/json; charset=UTF-8" \
     --header "content-type: application/json" \
     --header "x-redlock-auth: $PC_JWT" \
--data-raw '{
  "limit": 1000,
  "withResourceJson": true,
  "startTime": 1620226933,
  "query": "config from cloud.resource where cloud.type = \"azure\" AND api.name = \"azure-virtual-desktop-session-host\" AND json.rule = session-hosts[?any( properties.status equals \"Unavailable\" )] exists"
}' | jq -r '.items[] | .data."session-hosts"[] | [.id, .name, .properties.status, .properties.statusTimestamp] | @csv' >> $REPORT_LOCATION
