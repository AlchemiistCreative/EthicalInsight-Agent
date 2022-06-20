<#

EthicalInsight Task Script

Author: github.com/AlchemiistCreative

#>


param(
    [string]$APIhost = "10.0.0.113:5000",
    [string]$path= $pwd
)

$LogFile = "$path\error.log"

Function Log-Write
{
   Param ($Text)
 
   Add-Content $LogFile -Value $Text
}

#### Domain

$DomainController = Get-ADDomainController -Filter *


$domain = $DomainController.Domain

### API key encrypted
$APIKey_encrypted = Get-Content -Path "$path\EthicalInsight-apikeys.conf" | ConvertTo-SecureString


### API key decrypt function

function decrypt_APIkeys{



$Marshal = [System.Runtime.InteropServices.Marshal]
$Bstr = $Marshal::SecureStringToBSTR($APIKey_encrypted)
$APIKey_decrypted = $Marshal::PtrToStringAuto($Bstr)

return $APIKey_decrypted

}


### API key decrypted
$APIKeys = decrypt_APIkeys

$LoginBody = @{

apikey = $APIKeys
}


#### Get info about this DC

function get-info{


$DCInfo_AD = Get-ADDomainController -Filter *


$DCInfo_AD_Domain = $DCInfo_AD.Domain
$DCInfo_AD_Forest = $DCInfo_AD.Forest
$DCInfo_AD_hostname = $DCInfo_AD.HostName
$DCInfo_AD_site = $DCInfo_AD.Site
$DCInfo_AD_ID = $DCInfo_AD.ServerObjectGuid



$DCInfo_Version = Get-ComputerInfo

$DCInfo_Version_product = $DCInfo_Version.WindowsProductName
$DCInfo_Version_OS = $DCInfo_Version.OsVersion

$DCInfo_network =  Get-NetIPConfiguration
$DCInfo_network_IP = $DCInfo_network.IPv4Address.IPaddress
$timestamp = Get-Date

$info = @{
ID = $DCInfo_AD_ID
Domain = $DCInfo_AD_Domain
Forest = $DCInfo_AD_Forest
Hostname = $DCInfo_AD_hostname
Site = $DCInfo_AD_site
ProductName = $DCInfo_Version_product
OSVersion = $DCInfo_Version_OS
IPAddress = $DCInfo_network_IP
last_run = $timestamp
}


return $info



}



function get-events{

$EventID = 4720, 4722, 4740, 4725, 4726, 4738


$date = (Get-Date).AddMinutes(-10)



$Events = Get-WinEvent -FilterHashTable @{Logname = "Security" ; ID = $EventID;} | Where-Object { $_.TimeCreated -gt $date } | Select-Object -Property *

foreach ($event in $Events){
$TaskDisplayName = $Event.TaskDisplayName
$Event_ID = $Event.ID
$RecordID = $Event.RecordID
$TimeCreated = $Event.TimeCreated
$MachineName = $Event.MachineName
$DisplayName = $Event.KeywordsDisplayNames[0]
$Message = $Event.Message




$Event_All = @{
TaskDisplayName = $TaskDisplayName
EventID = $Event_ID
RecordID = $RecordID
TimeCreated = $TimeCreated
MachineName = $MachineName
DisplayName = $DisplayName
Message = $Message
}


$Event_All 


}

}


#### Get User info 

function get-ADUsersData{

Get-ADUser -Filter * -properties * | Select-Object ObjectGUID, SAMAccountName, DisplayName, UserPrincipalName, whenchanged, whencreated, PasswordLastSet, Enabled

}



$events_data = get-events
$User_data = get-ADUsersData
$Info_data = get-info


### Get valid JWT using login by API key

function api_login{


$req = Invoke-WebRequest -Uri http://$APIhost/api/login/key -Method POST -Body ($LoginBody | ConvertTo-Json)  -ContentType "application/json"

$parsed = $req | ConvertFrom-Json

$token = $parsed.token


return $token

}


### Post data to endpoint with JWT in header 

function post_data{


$token = api_login


$headers = @{
 'Content-Type'='application/json'
 'x-access-token'=$token
 }

foreach ($JSONbody in $User_data){

$body = $JSONBody | ConvertTo-Json 

Try{
Invoke-WebRequest -Uri http://$APIhost/api/push/data/$domain -Method POST -Body $body -Headers $headers -ContentType "application/json; charset=utf-8"
}
Catch{
Log-Write -Text "Posting User data failed/ body: $body / host: $APIhost / domain: $domain"
}
}

}



function post_info{


$token = api_login


$headers = @{
 'Content-Type'='application/json'
 'x-access-token'=$token
 }



$body = $Info_data | ConvertTo-Json 

Try{
Invoke-WebRequest -Uri http://$APIhost/api/push/info -Method POST -Body $body -Headers $headers -ContentType "application/json; charset=utf-8"

}
Catch{
Log-Write -Text "Posting Domain Contollers info failed/ body: $body / host: $APIhost"
}



}

function post_events{


$token = api_login


$headers = @{
 'Content-Type'='application/json'
 'x-access-token'=$token
 }



$bodies = $events_data 

foreach ($body in $bodies){
if ($body)
{
    Try{
    Invoke-WebRequest -Uri http://$APIhost/api/push/events/$domain -Method POST -Body ($body | ConvertTo-Json) -Headers $headers -ContentType "application/json; charset=utf-8"
    }
    Catch{
    Log-Write -Text "Posting events failed / body: $body / host: $APIhost /domain: $domain"
    }
}
}





}



post_events
post_info
post_data


