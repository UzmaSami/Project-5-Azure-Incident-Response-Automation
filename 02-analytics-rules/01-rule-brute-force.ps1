# ============================================
# Script: rule-brute-force.ps1
# Purpose: Detect brute force attacks - STABLE VERSION
# Author: Uzma Shabbir
# ============================================

Connect-AzAccount -ErrorAction SilentlyContinue

$rgName        = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"

# 1. Simplified KQL Query
$bruteForceQuery = "SecurityEvent | where EventID == 4625 | summarize count() by Computer, IpAddress | where count_ >= 10"

Write-Host "Deploying IR-001 Analytics Rule..." -ForegroundColor Yellow

# 2. Ultra-stable Parameter Set (No Tactics/Techniques to avoid module errors)
$ruleParams = @{
    ResourceGroupName      = $rgName
    WorkspaceName          = $workspaceName
    Kind                   = "Scheduled"
    DisplayName            = "IR-001: Brute Force Attack Detected"
    Severity               = "High"
    Enabled                = $true
    Query                  = $bruteForceQuery
    QueryFrequency         = (New-TimeSpan -Minutes 60)
    QueryPeriod            = (New-TimeSpan -Minutes 60)
    TriggerOperator        = "GreaterThan"
    TriggerThreshold       = 0
}

# 3. Execution
New-AzSentinelAlertRule @ruleParams

Write-Host "`n✅ SUCCESS: Rule IR-001 is now live in Sentinel!" -ForegroundColor Green

