# ============================================
# Script: rule-impossible-travel.ps1
# Purpose: Detect geographically impossible sign-ins
# Author: Uzma Shabbir
# ============================================

Connect-AzAccount -ErrorAction SilentlyContinue

$rgName        = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"

Write-Host "=== DEPLOYING IMPOSSIBLE TRAVEL RULE (IR-003) ===" -ForegroundColor Cyan
Write-Host "Lead Engineer: Uzma Shabbir" -ForegroundColor White

# KQL for Impossible Travel
$impossibleTravelQuery = @"
let timeWindow = 2h;
SigninLogs
| where TimeGenerated > ago(timeWindow)
| where ResultType == 0
| extend Country = tostring(LocationDetails.countryOrRegion)
| where isnotempty(Country)
| summarize 
    Countries = make_set(Country), 
    SigninCount = count() 
    by UserPrincipalName, bin(TimeGenerated, timeWindow)
| where array_length(Countries) >= 2
| project TimeGenerated = now(), UserPrincipalName, Countries, SigninCount
"@

# Define stable parameters using Splatting
# Removed 'Technique' and 'IncidentConfiguration' to resolve module conflicts
$ruleParams = @{
    ResourceGroupName      = $rgName
    WorkspaceName          = $workspaceName
    Kind                   = "Scheduled"
    DisplayName            = "IR-003: Impossible Travel Detected"
    Description            = "Detects sign-ins from multiple countries within 2 hours."
    Severity               = "High"
    Enabled                = $true
    Query                  = $impossibleTravelQuery
    QueryFrequency         = (New-TimeSpan -Hours 2)
    QueryPeriod            = (New-TimeSpan -Hours 2)
    TriggerOperator        = "GreaterThan"
    TriggerThreshold       = 0
    Tactic                 = @("InitialAccess")
}

Write-Host "Pushing IR-003 to Sentinel Analytics..." -ForegroundColor Yellow

# Execute
New-AzSentinelAlertRule @ruleParams | Out-Null

Write-Host "`n✅ SUCCESS: Impossible Travel rule is now live!" -ForegroundColor Green
Write-Host "Note: High severity rule active in $workspaceName" -ForegroundColor Gray

