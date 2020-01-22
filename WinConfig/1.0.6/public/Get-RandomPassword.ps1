Function Get-RandomPassword
{
   # Stolen from MSFT
   #http://blogs.technet.com/b/heyscriptingguy/archive/2013/06/03/generating-a-new-password-with-windows-powershell.aspx
   [cmdletbinding()]
   [Alias('randompwd','rpwd')]
   [OutputType([String])]
   Param(
            [ValidateRange(1,99)]
            [int]$length = 8,

            [ValidateSet("ascii","alphabet")]
            [string]$sourcetype = "alphabet"
        ) #Param

        # Enumerate ASCII and Alphabet Chars. (Stolen from MSFT)
        # To user for "Generate-Random" Password
        Switch($sourcetype)
        {
            ("alphabet") { $alphabet=$NULL ; For ($a=65;$a -le 90;$a++) {$alphabet+=,[char][byte]$a } ; For ($a=97;$a -le 122;$a++) {$alphabet+=,[char][byte]$a } ; $sourcedata = $alphabet }
            ("ascii") { $ascii=$NULL;For ($a=33;$a -le 126;$a++) {$ascii+=,[char][byte]$a } ; $sourcedata = $ascii }
        } #switch

        #Build the password as a string
        For ($loop=1; $loop -le $length; $loop++)
            {
                $TempPassword+=($sourcedata | GET-RANDOM)
            } #for

        return $TempPassword.trim()
}#Get-RandomPassword