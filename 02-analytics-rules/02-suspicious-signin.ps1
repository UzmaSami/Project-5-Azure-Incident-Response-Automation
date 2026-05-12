# ============================================
# Script: rule-suspicious-signin.ps1
# Purpose: Detect suspicious sign-in patterns
# Author: Uzma Shabbir
# ============================================

Connect-AzAccount -ErrorAction SilentlyContinue

$rgName        = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"

Write-Host "=== DEPLOYING SUSPICIOUS SIGN-IN RULE (IR-002) ===" -ForegroundColor Cyan
Write-Host "Lead Engineer: Uzma Shabbir" -ForegroundColor White

# KQL for suspicious sign-ins
$suspiciousSigninQuery = @"
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType != 0
| extend
    Hour = hourofday(TimeGenerated),
    Country = tostring(LocationDetails.countryOrRegion)
| where
    (Hour < 8 or Hour > 18)
    or Country !in ("United Kingdom", "Pakistan")
| summarize
    SuspiciousCount = count()
    by UserPrincipalName, IPAddress
| where SuspiciousCount >= 3
"@

# Define stable parameters using Splatting
$ruleParams = @{
    ResourceGroupName      = $rgName
    WorkspaceName          = $workspaceName
    Kind                   = "Scheduled"
    DisplayName            = "IR-002: Suspicious Sign-in Pattern Detected"
    Description            = "Detects logins after-hours or from unauthorized countries."
    Severity               = "Medium"
    Enabled                = $true
    Query                  = $suspiciousSigninQuery
    QueryFrequency         = (New-TimeSpan -Hours 1)
    QueryPeriod            = (New-TimeSpan -Hours 1)
    TriggerOperator        = "GreaterThan"
    TriggerThreshold       = 0
    Tactic                 = @("InitialAccess")
}

Write-Host "Pushing IR-002 to Sentinel Analytics..." -ForegroundColor Yellow

# Execute
New-AzSentinelAlertRule @ruleParams | Out-Null

Write-Host "`n✅ SUCCESS: Suspicious Sign-in rule is now live!" -ForegroundColor Green
Write-Host "Note: This rule monitors Entra ID (Azure AD) logs." -ForegroundColor Gray

