Function Test-IsAdmin
{
 #Shamlessly Stolen from "Hey Scripting Guy"
 <#

    .Synopsis

        Tests if the user is an administrator

    .Description

        Returns true if a user is an administrator, false if the user is not an administrator

    .Example

        Test-IsAdmin

    #>

 $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

 $principal = New-Object Security.Principal.WindowsPrincipal $identity

 $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

}#Function Test-IsAdmin