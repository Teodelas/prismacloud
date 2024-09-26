#pre-requisites: pip3 install pyjwt requests
import requests
import json
import csv
import os
from datetime import datetime, timezone, timedelta
import jwt  # PyJWT

PC_APIURL=""
PC_ACCESSKEY=""
PC_SECRETKEY=""

AUTH_PAYLOAD = {
    "username": PC_ACCESSKEY,
    "password": PC_SECRETKEY
}

PC_JWT = None
PC_JWT_EXPIRATION = None

def get_jwt():
    global PC_JWT, PC_JWT_EXPIRATION
    response = requests.post(f"{PC_APIURL}/login", headers={
        'Accept': 'application/json; charset=UTF-8',
        'Content-Type': 'application/json; charset=UTF-8'
    }, data=json.dumps(AUTH_PAYLOAD))
    PC_JWT = response.json().get('token')
    decoded_jwt = jwt.decode(PC_JWT, options={"verify_signature": False})
    PC_JWT_EXPIRATION = datetime.fromtimestamp(decoded_jwt['exp'], tz=timezone.utc)

def get_valid_jwt():
    global PC_JWT, PC_JWT_EXPIRATION
    if PC_JWT is None or PC_JWT_EXPIRATION is None or datetime.now(tz=timezone.utc) >= PC_JWT_EXPIRATION:
        get_jwt()
    return PC_JWT

get_valid_jwt()

REPORT_DATE = datetime.now().strftime("%m_%d_%y")
REPORT_LOCATION = os.path.expanduser(f"~/reports/alert_counts_{REPORT_DATE}.csv")
os.makedirs(os.path.expanduser("~/reports"), exist_ok=True)


# Get details for a single alert to identify POLICY_ID
response = requests.get(f"{PC_APIURL}/alert/policy", headers={
    'Accept': '*/*',
    'Content-Type': 'application/json; charset=UTF-8',
    'x-redlock-auth': get_valid_jwt()
})
alerts = response.json()


with open(REPORT_LOCATION, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    for alert in alerts:
        #print(alert.get('policy').get('name')+str(alert.get('alertCount')))
        csvwriter.writerow([alert.get('policy').get('name'), alert.get('alertCount')])

home_directory = os.path.expanduser("~")
print(f"Report saved to: {REPORT_LOCATION}")
