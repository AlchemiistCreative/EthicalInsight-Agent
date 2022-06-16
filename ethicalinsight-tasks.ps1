﻿<#

EthicalInsight Task Script

Author: github.com/AlchemiistCreative

#>


param(
    [string]$APIhost,
    [string]$path
)



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


$date_ = (Get-Date).AddMinutes(-10)
$date = (Get-Date).addhours(-1)


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


return $Event_All 


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

Invoke-WebRequest -Uri http://$APIhost/api/push/data/$domain -Method POST -Body $body -Headers $headers -ContentType "application/json; charset=utf-8"
}

}



function post_info{


$token = api_login


$headers = @{
 'Content-Type'='application/json'
 'x-access-token'=$token
 }



$body = $Info_data | ConvertTo-Json 

Invoke-WebRequest -Uri http://$APIhost/api/push/info -Method POST -Body $body -Headers $headers -ContentType "application/json; charset=utf-8"


}

function post_events{


$token = api_login


$headers = @{
 'Content-Type'='application/json'
 'x-access-token'=$token
 }



$body = $events_data | ConvertTo-Json 
if ($body)
{
    Invoke-WebRequest -Uri http://$APIhost/api/push/events/$domain -Method POST -Body $body -Headers $headers -ContentType "application/json; charset=utf-8"
}






}



post_events
post_info
post_data
