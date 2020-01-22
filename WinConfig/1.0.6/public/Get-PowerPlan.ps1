Function Get-PowerPlan
{
    # https://technet.microsoft.com/en-us/library/hh824902.aspx
    # http://blogs.technet.com/b/heyscriptingguy/archive/2010/08/30/find-active-power-plan-on-remote-servers-by-using-powershell.aspx
    $PowerPlanInfo =@{
                    'PowerPlan' = (powercfg /GetActiveScheme).split("()")[1]
                    'GUID' = (powercfg /GetActiveScheme).split("()")[0].Split(":")[-1].trim()
                 }#PowerPlan

    $PowerPlan = New-Object -TypeName psobject -Property $PowerPlanInfo
    $PowerPlan = $PowerPlan | Select PowerPlan,Guid | fl

    Return $PowerPlan

} #Function Get-PowerPlan