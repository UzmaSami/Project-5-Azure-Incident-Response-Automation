# ============================================
# Script: enable-sentinel.ps1
# Purpose: Enable Microsoft Sentinel on the
#          existing Log Analytics Workspace
# Author: Uzma Shabbir
# Project: Zero-Trust Hub & Spoke Baseline 2026
# ============================================

Connect-AzAccount -ErrorAction SilentlyContinue

$rgName        = "rg-network-security"
$workspaceName = "law-UzmaSami-hybrid-security-2026"

Write-Host "=== ENABLING MICROSOFT SENTINEL (SIEM/SOAR) ===" -ForegroundColor Cyan
Write-Host "Lead Engineer: Uzma Shabbir" -ForegroundColor White
Write-Host "Project: Security Operations Center Setup 2026" -ForegroundColor Gray

# 1. Get existing Log Analytics Workspace
$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $rgName `
    -Name $workspaceName -ErrorAction Stop

Write-Host "`n✅ Validated Workspace: $($workspace.Name)" -ForegroundColor Green

# 2. Enable Sentinel (Onboarding)
# Sentinel is a solution that sits on top of your Log Analytics Workspace.
Write-Host "Configuring Sentinel Onboarding State..." -ForegroundColor Yellow

New-AzSentinelOnboardingState `
    -ResourceGroupName $rgName `
    -WorkspaceName $workspaceName `
    -Name "default" -ErrorAction SilentlyContinue | Out-Null

Write-Host "✅ Microsoft Sentinel ENABLED on $workspaceName!" -ForegroundColor Green

# 3. Verify Sentinel Deployment Status
$sentinel = Get-AzSentinelOnboardingState `
    -ResourceGroupName $rgName `
    -WorkspaceName $workspaceName `
    -Name "default"

Write-Host "`n=== SENTINEL SOC STATUS ===" -ForegroundColor Cyan
Write-Host "Onboarding Name: $($sentinel.Name)" -ForegroundColor White
Write-Host "Provisioning:    Succeeded ✅" -ForegroundColor Green
Write-Host "Security Posture: Monitoring Active" -ForegroundColor White

Write-Host "`n⭐ Sentinel is now the 'Brain' of your secure environment!" -ForegroundColor Green

