# Azure Incident Response Automation

## Overview
Complete automated incident response system built on
Microsoft Sentinel with Logic Apps playbooks that
automatically detect and respond to security threats
in under 30 seconds — 24/7 without human intervention.

*Engineer:* Uzma Shabbir | AZ-104 | AZ-500
*Platform:* Microsoft Sentinel + Logic Apps
*Region:* UK South

##  Threats Detected & Auto-Responded
| Threat | Detection | Auto Response |
|--------|-----------|--------------|
| Brute Force | 10+ failures/hour | IP Blocked |
| Suspicious Login | After-hours/Foreign | User Investigated |
| Impossible Travel | Multi-country 2hrs | Account Secured |
| Data Exfiltration | 500MB+ download | Team Alerted |

##  Playbooks Deployed
| Playbook | Trigger | Action |
|----------|---------|--------|
| PB-001-Block-IP | Brute Force | Flag malicious IP |
| PB-002-Disable-User | Account Compromise | Secure account |
| PB-003-Alert-Team | High Severity | Notify team |
| PB-004-Capture-Evidence | All Incidents | Store forensics |

##  MITRE ATT&CK Coverage
- T1110 — Brute Force
- T1078 — Valid Accounts
- T1530 — Data from Cloud Storage
- T1040 — Network Sniffing

## Performance
- Detection Time: Minutes
- Response Time: < 30 seconds
- Coverage: 24/7 Automated
- Human Error: Minimized

##  Deployment
```powershell
# Enable Sentinel
.\01-sentinel-setup\enable-sentinel.ps1

# Connect data sources
.\01-sentinel-setup\connect-data-sources.ps1

# Create detection rules
.\02-analytics-rules\rule-brute-force.ps1
.\02-analytics-rules\rule-suspicious-signin.ps1
.\02-analytics-rules\rule-impossible-travel.ps1
.\02-analytics-rules\rule-data-exfiltration.ps1

# Deploy playbooks
.\03-playbooks\deploy-playbooks.ps1

# Create automation rules
.\04-automation-rules\create-automation-rules.ps1

# Create watchlist
.\05-watchlists\create-ip-watchlist.ps1

# Test everything
.\07-testing\test-playbook-trigger.ps1

# Generate report
.\08-compliance-report\generate-ir-report.ps1
