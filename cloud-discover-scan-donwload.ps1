# Get token and console address from Manage -> System and click on the Utilities tab
$token = ""
$console_address = ""

# Define headers
$headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type' = 'text/csv'
}

# Define the URI
$uri = "$console_address/api/v1/cloud/discovery/download"

# Send the request
Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -OutFile 'cloud-discovery.csv'
