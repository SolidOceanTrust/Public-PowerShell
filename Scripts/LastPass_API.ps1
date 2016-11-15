#Last Pass
    # "cid":8536702
    # "provhash":
    # -chsh=1696c336d2 

$BaseURL = 'https://lastpass.com/enterpriseapi.php'
$cid = '8536702'
$provhash = $(Get-Content -Path D:\git\Public-PowerShell\Scripts\LastPass_API.key)
$cmd = 'getsfdata'
$apiuser = 'bnabel-API'
$data = @()

$payload = @{
                cid      = $cid
                provhash = $provhash
                apiuser  = $apiuser
                cmd      = $cmd
                data    = @($data) 
             } | ConvertTo-Json


$respose = Invoke-WebRequest $BaseURL -Body $payload -UseBasicParsing -Method Post
$respose.Content


$sharedfolders = ($respose.Content | ConvertFrom-Json)
$Index = ($sharedfolders | Get-Member -MemberType NoteProperty).Name
$index | foreach { $sharedFolders.$_}


#$sharedfolders | Get-Member -MemberType NoteProperty

#$SharedFolderObject = $sharedfolders | Get-Member -MemberType NoteProperty

<#
# Example

$payload = @{cid=$cid;provhash=$provhash;apiuser=$apiuser;cmd=$cmd;data=@($data) } | ConvertTo-Json

$payload = @{
                cid      = $cid
                provhash = $provhash
                apiuser  = $apiuser
                cmd      = $cmd
                data    =@ ($data) 
             } | ConvertTo-Json



Invoke-WebRequest $url -Body $payload -UseBasicParsing -Method Post





# Get UserData
{
    "cid": "8536702",
    "provhash": "<Your API Secret>",
    "cmd": "getuserdata",
    "data": {
        "username": "user1@lastpass.com"
    }
}

#>