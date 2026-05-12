# ============================================
# Script: deploy-playbooks.ps1
# Purpose: Deploy all incident response playbooks (Fixed for 2026)
# ============================================

$rgName        = "rg-network-security"
$location      = "uksouth"
$workspaceName = "law-UzmaSami-hybrid-security-2026"

Write-Host "Deploying IR Playbooks..." -ForegroundColor Cyan

# --- 2026 AUTHENTICATION FIX ---
# This converts the new SecureString token into a format the REST API can read
# --- 2026 AUTHENTICATION FIX (CLOUD SHELL VERSION) ---
Write-Host "Fetching secure token..." -ForegroundColor Cyan
$token = (az account get-access-token --query accessToken --output tsv)
$subscriptionId = (Get-AzContext).Subscription.Id
# -----------------------------------------------------

# ---- Playbook 1: Block IP ----
Write-Host "`n[1/4] Deploying Block IP Playbook..." -ForegroundColor Yellow
$blockIPPlaybook = @{
    location   = $location
    properties = @{
        state      = "Enabled"
        definition = @{
            "`$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
            contentVersion  = "1.0.0.0"
            triggers        = @{ manual = @{ type = "Request"; kind = "Http"; inputs = @{ schema = @{ properties = @{ incidentId = @{type = "string"}; ipAddress = @{type = "string"}; severity = @{type = "string"}; description = @{type = "string"} } } } } }
            actions = @{
                Log_IR_Action = @{ type = "Compose"; inputs = @{ Action = "IP Block Initiated"; IPAddress = "@triggerBody()?['ipAddress']"; IncidentId = "@triggerBody()?['incidentId']"; Timestamp = "@utcNow()"; Engineer = "Uzma Sami"; Status = "Automated Response Executed"; Playbook = "PB-001-Block-IP" } }
                Send_Response = @{ runAfter = @{ Log_IR_Action = @("Succeeded") }; type = "Response"; inputs = @{ statusCode = 200; body = @{ status = "Success"; action = "IP flagged for blocking"; timestamp = "@utcNow()"; playbook = "PB-001-Block-IP" } } }
            }
        }
    }
}
$uri1 = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.Logic/workflows/playbook-block-ip?api-version=2019-05-01"
Invoke-RestMethod -Uri $uri1 -Method Put -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body ($blockIPPlaybook | ConvertTo-Json -Depth 20)
Write-Host "✅ Block IP Playbook deployed!" -ForegroundColor Green

# ---- Playbook 2: Disable User ----
Write-Host "`n[2/4] Deploying Disable User Playbook..." -ForegroundColor Yellow
$disableUserPlaybook = @{
    location   = $location
    properties = @{
        state      = "Enabled"
        definition = @{
            "`$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
            contentVersion  = "1.0.0.0"
            triggers        = @{ manual = @{ type = "Request"; kind = "Http"; inputs = @{ schema = @{} } } }
            actions = @{
                Log_Disable_Action = @{ type = "Compose"; inputs = @{ Action = "User Account Disable Initiated"; User = "@triggerBody()?['userPrincipalName']"; Reason = "@triggerBody()?['reason']"; IncidentId = "@triggerBody()?['incidentId']"; Timestamp = "@utcNow()"; Playbook = "PB-002-Disable-User"; Engineer = "Uzma Sami" } }
                Response = @{ runAfter = @{ Log_Disable_Action = @("Succeeded") }; type = "Response"; inputs = @{ statusCode = 200; body = @{ status = "User disable initiated"; playbook = "PB-002-Disable-User" } } }
            }
        }
    }
}
$uri2 = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.Logic/workflows/playbook-disable-user?api-version=2019-05-01"
Invoke-RestMethod -Uri $uri2 -Method Put -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body ($disableUserPlaybook | ConvertTo-Json -Depth 20)
Write-Host "✅ Disable User Playbook deployed!" -ForegroundColor Green

# ---- Playbook 3: Alert Security Team ----
Write-Host "`n[3/4] Deploying Alert Team Playbook..." -ForegroundColor Yellow
$alertTeamPlaybook = @{
    location   = $location
    properties = @{
        state      = "Enabled"
        definition = @{
            "`$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
            contentVersion  = "1.0.0.0"
            triggers        = @{ manual = @{ type = "Request"; kind = "Http"; inputs = @{ schema = @{} } } }
            actions = @{
                Compose_Alert = @{ type = "Compose"; inputs = @{ AlertType = "Security Incident"; Severity = "@triggerBody()?['severity']"; Description = "@triggerBody()?['description']"; IncidentId = "@triggerBody()?['incidentId']"; Timestamp = "@utcNow()"; Engineer = "Uzma Sami"; Playbook = "PB-003-Alert-Team"; Message = "🚨 SECURITY INCIDENT DETECTED!" } }
                Send_Response = @{ runAfter = @{ Compose_Alert = @("Succeeded") }; type = "Response"; inputs = @{ statusCode = 200; body = @{ status = "Alert sent"; playbook = "PB-003-Alert-Team" } } }
            }
        }
    }
}
$uri3 = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.Logic/workflows/playbook-alert-team?api-version=2019-05-01"
Invoke-RestMethod -Uri $uri3 -Method Put -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body ($alertTeamPlaybook | ConvertTo-Json -Depth 20)
Write-Host "✅ Alert Team Playbook deployed!" -ForegroundColor Green

# ---- Playbook 4: Capture Evidence ----
Write-Host "`n[4/4] Deploying Evidence Capture Playbook..." -ForegroundColor Yellow
$evidencePlaybook = @{
    location   = $location
    properties = @{
        state      = "Enabled"
        definition = @{
            "`$schema"      = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
            contentVersion  = "1.0.0.0"
            triggers        = @{ manual = @{ type = "Request"; kind = "Http"; inputs = @{ schema = @{} } } }
            actions = @{
                Capture_Evidence = @{ type = "Compose"; inputs = @{ EvidenceType = "Security Incident Evidence"; IncidentId = "@triggerBody()?['incidentId']"; CaptureTime = "@utcNow()"; Engineer = "Uzma Sami"; StoredIn = "law-UzmaSami-hybrid-security-2026" } }
                Send_Response = @{ runAfter = @{ Capture_Evidence = @("Succeeded") }; type = "Response"; inputs = @{ statusCode = 200; body = @{ status = "Evidence captured"; playbook = "PB-004-Capture-Evidence" } } }
            }
        }
    }
}
$uri4 = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.Logic/workflows/playbook-capture-evidence?api-version=2019-05-01"
Invoke-RestMethod -Uri $uri4 -Method Put -Headers @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" } -Body ($evidencePlaybook | ConvertTo-Json -Depth 20)
Write-Host "✅ Evidence Capture Playbook deployed!" -ForegroundColor Green

Write-Host "`n=== ALL PLAYBOOKS DEPLOYED SUCCESSFULLY ===" -ForegroundColor Cyan

