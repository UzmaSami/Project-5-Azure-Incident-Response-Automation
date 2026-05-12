# ============================================
# Script: rule-data-exfiltration.ps1
# Purpose: Detect potential data exfiltration
# Author: Uzma Shabbir
# Project: Zero-Trust Hub & Spoke Baseline 2026
# ============================================

Connect-AzAccount -ErrorAction SilentlyContinue

$rgName        = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"

Write-Host "=== DEPLOYING DATA EXFILTRATION RULE (IR-004) ===" -ForegroundColor Cyan
Write-Host "Lead Engineer: Uzma Shabbir" -ForegroundColor White

# KQL Query for Data Exfiltration
$exfiltrationQuery = @"
StorageBlobLogs
| where TimeGenerated > ago(1h)
| where OperationName == "GetBlob"
| summarize
    TotalDownloadsMB = sum(ResponseBodySize) / 1048576
    by AccountName, bin(TimeGenerated, 1h), CallerIpAddress
| where TotalDownloadsMB > 500
"@

# Define stable parameters
$ruleParams = @{
    ResourceGroupName      = $rgName
    WorkspaceName          = $workspaceName
    Kind                   = "Scheduled"
    DisplayName            = "IR-004: Potential Data Exfiltration Detected"
    Description            = "Detects downloads exceeding 500MB in 1 hour from storage accounts."
    Severity               = "High"
    Enabled                = $true
    Query                  = $exfiltrationQuery
    QueryFrequency         = (New-TimeSpan -Hours 1)
    QueryPeriod            = (New-TimeSpan -Hours 1)
    TriggerOperator        = "GreaterThan"
    TriggerThreshold       = 0
    Tactic                 = @("Exfiltration")
}

Write-Host "Pushing IR-004 to Sentinel Analytics..." -ForegroundColor Yellow

# Execute
New-AzSentinelAlertRule @ruleParams | Out-Null

Write-Host "`n✅ SUCCESS: Data Exfiltration rule is now live!" -ForegroundColor Green

# Final Verification Table
Write-Host "`n=== CURRENT ACTIVE SECURITY RULES ===" -ForegroundColor Cyan
Get-AzSentinelAlertRule -ResourceGroupName $rgName -WorkspaceName $workspaceName | `
Select-Object DisplayName, Severity, Enabled | Format-Table -AutoSize

