param(
    [string]$environmentUrl,
    [string]$clientId,
    [string]$clientSecret,
    [string]$tenantId
)

Write-Host "Authenticating to Power Platform..."
pac auth create --applicationId $clientId --clientSecret $clientSecret --tenant $tenantId --environment $environmentUrl

Write-Host "Fetching required connection references..."
$solutionPath = "./src/AMLGit/ConnectionReferences"

$connectionRefs = Get-ChildItem $solutionPath -Filter *.json

foreach ($ref in $connectionRefs) {

    $json = Get-Content $ref.FullName | ConvertFrom-Json
    $logicalName = $json.properties.connectionReferenceLogicalName
    $apiDisplayName = $json.properties.apiDisplayName

    Write-Host "Processing reference: $logicalName ($apiDisplayName)"

    $connections = pac connection list | ConvertFrom-Json

    $existing = $connections.connections | Where-Object { $_.properties.apiDisplayName -eq $apiDisplayName }

    if ($existing) {
        Write-Host "Existing connection found: $($existing.name)"
        continue
    }

    Write-Host "Creating new connection for API: $apiDisplayName..."
    pac connection create --api-display-name "$apiDisplayName" --connection-name "$logicalName"

    Write-Host "Connection created successfully!"
}
