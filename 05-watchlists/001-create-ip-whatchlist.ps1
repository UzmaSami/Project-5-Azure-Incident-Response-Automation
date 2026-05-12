$rgName = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"
$watchlistId = "malicious-ip-watchlist"

# Fix: Force the content to be a simple string and use a direct path
$csvContent = [System.IO.File]::ReadAllText("/home/uzma/malicious-ips.csv")

Write-Host "Creating Watchlist via Direct API..." -ForegroundColor Cyan

# The full Resource ID path required by the API
$fullResourceId = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/$rgName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/watchlists/$watchlistId"

$props = @{
    displayName = "Known Malicious IP Addresses"
    source = "Local file"
    provider = "Uzma Sami Security"
    itemsSearchKey = "IPAddress"
    description = "Curated list of known malicious IPs"
    rawContent = $csvContent
    contentType = "text/csv"
}

# Create using the ID directly to avoid naming confusion
New-AzResource -ResourceId $fullResourceId `
    -ApiVersion "2023-02-01" `
    -PropertyObject $props `
    -Force

Write-Host "✅ Watchlist created!" -ForegroundColor Green

