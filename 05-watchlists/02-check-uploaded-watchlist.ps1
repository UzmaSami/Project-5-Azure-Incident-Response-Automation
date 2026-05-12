# This asks for ALL watchlists in the workspace                
PS /home/uzma> Get-AzResource -ResourceGroupName $rg `
>>     -ResourceType "Microsoft.OperationalInsights/workspaces/providers/watchlists" `
>>     -ResourceName "$ws/Microsoft.SecurityInsights" `
>>     -ApiVersion "2023-02-01"

