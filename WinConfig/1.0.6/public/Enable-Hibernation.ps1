Function Enable-Hibernation
{
    # https://technet.microsoft.com/en-us/library/hh824902.aspx
    # http://blogs.technet.com/b/heyscriptingguy/archive/2010/08/30/find-active-power-plan-on-remote-servers-by-using-powershell.aspx

        try {
          powercfg /HIBERNATE On
          Write-Output "Hibernation: Enabled"
         } #try

         catch{"Could not Enable hibernation for some reason. Check rights, or something...."}

} #Function Enable-Hibernation