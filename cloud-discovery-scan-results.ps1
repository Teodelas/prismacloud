#POWERSHELL Cloud Scan results
# Get token and console address from Manage -> System and click on the Utilities tab
$TOKEN = ""
# Base URL for the API
$BaseUrl = "y"

$Response = Invoke-WebRequest -Uri $BaseUrl -Headers @{ "Authorization" = "Bearer $TOKEN" } -Method Get

# Total count of entries
$TotalCount = [int]$Response.Headers.'Total-Count'[0]

# Number of entries to retrieve per request
$Limit = 100

# Output file
$OutputFile = "Cloud_Disccovery_Scan_Results.csv"

# Loop through all entries using the offset parameter
for ($Offset = 0; $Offset -lt $TotalCount; $Offset += $Limit) {
    # Construct the URL with the offset and limit parameters
    $Url = $BaseUrl+"?offset=$Offset&limit=$Limit"

    # Make the API request
    $Response = Invoke-RestMethod -Uri $Url -Headers @{ "Authorization" = "Bearer $TOKEN" } -Method Get

    # Append the results to the output file
    $Response | Export-Csv -Path ./$OutputFile -Append

}
