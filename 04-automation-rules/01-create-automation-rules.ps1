$rgName = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"
# Your specific GUID for IR-001
$bruteForceRuleGuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

$subId = (Get-AzContext).Subscription.Id
$tenantId = (Get-AzContext).Tenant.Id
$token = (az account get-access-token --query accessToken --output tsv)

Write-Host "Deploying Final Automation Rules..." -ForegroundColor Cyan

# Fetching the Resource IDs of your updated Playbooks
$logicApps = @{
    "ar001" = (Get-AzLogicApp -ResourceGroupName $rgName -Name "playbook-block-ip").Id
    "ar002" = (Get-AzLogicApp -ResourceGroupName $rgName -Name "playbook-disable-user").Id
    "ar003" = (Get-AzLogicApp -ResourceGroupName $rgName -Name "playbook-alert-team").Id
    "ar004" = (Get-AzLogicApp -ResourceGroupName $rgName -Name "playbook-capture-evidence").Id
}

function New-SentinelRuleAPI($id, $name, $order, $conditions, $playbookId) {
    $uri = "https://management.azure.com/subscriptions/$subId/resourceGroups/$rgName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/automationRules/$id`?api-version=2023-12-01-preview"
    
    $body = @{
        properties = @{
            displayName = $name
            order = $order
            triggeringLogic = @{
                isEnabled = $true
                triggersOn = "Incidents"
                triggersWhen = "Created"
                conditions = $conditions
            }
            actions = @(@{
                order = 1
                actionType = "RunPlaybook"
                actionConfiguration = @{
                    logicAppResourceId = $playbookId
                    tenantId = $tenantId
                }
            })
        }
    } | ConvertTo-Json -Depth 20

    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{Authorization="Bearer $token"; "Content-Type"="application/json"} -Body $body
        Write-Host "✅ $name Created!" -ForegroundColor Green
    } catch {
        Write-Host "❌ $name Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Execution ---

# Rule 1: Brute Force -> Block IP (Using Incident Title filter for stability)
$cond1 = @(@{
    conditionType = "Property"
    conditionProperties = @{
        propertyName = "IncidentTitle"
        operator = "Contains"
        propertyValues = @("Brute Force") 
    }
})
New-SentinelRuleAPI "ar001" "AR-001: Brute Force -> Block IP" 1 $cond1 $logicApps["ar001"]

# Rule 2: Suspicious Sign-in -> Disable User
New-SentinelRuleAPI "ar002" "AR-002: Suspicious Sign-in -> Disable User" 2 @() $logicApps["ar002"]

# Rule 3: High Severity -> Alert Team
$cond3 = @(@{conditionType="Property"; conditionProperties=@{propertyName="IncidentSeverity"; operator="Equals"; propertyValues=@("High")}})
New-SentinelRuleAPI "ar003" "AR-003: High Severity -> Alert Team" 3 $cond3 $logicApps["ar003"]

# Rule 4: All Incidents -> Capture Evidence
New-SentinelRuleAPI "ar004" "AR-004: All Incidents -> Capture Evidence" 4 @() $logicApps["ar004"]

Write-Host "`n=== DEPLOYMENT COMPLETE ===" -ForegroundColor Cyan

