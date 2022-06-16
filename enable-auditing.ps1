
### Show Menu

function Show-Menu
{
    param (
        [string]$Title = 'AuditInsight'
    )
$author = "Author: github.com/AlchemiistCreative"


$figlet = {
"====================================================================================================
                                                                                                                            
 ____    __    __                           ___   ______                              __      __      
/\  _`\ /\ \__/\ \      __                 /\_ \ /\__  _\                  __        /\ \    /\ \__   
\ \ \L\_\ \ ,_\ \ \___ /\_\    ___     __  \//\ \\/_/\ \/     ___     ____/\_\     __\ \ \___\ \ ,_\  
 \ \  _\L\ \ \/\ \  _ `\/\ \  /'___\ /'__`\  \ \ \  \ \ \   /' _ `\  /',__\/\ \  /'_ `\ \  _ `\ \ \/  
  \ \ \L\ \ \ \_\ \ \ \ \ \ \/\ \__//\ \L\.\_ \_\ \_ \_\ \__/\ \/\ \/\__, `\ \ \/\ \L\ \ \ \ \ \ \ \_ 
   \ \____/\ \__\\ \_\ \_\ \_\ \____\ \__/.\_\/\____\/\_____\ \_\ \_\/\____/\ \_\ \____ \ \_\ \_\ \__\
    \/___/  \/__/ \/_/\/_/\/_/\/____/\/__/\/_/\/____/\/_____/\/_/\/_/\/___/  \/_/\/___L\ \/_/\/_/\/__/
                                                                                   /\____/            
                                                                                   \_/__/                    
                                     
====================================================================================================="}








    Clear-Host
    Write-Host -ForegroundColor DarkGreen $figlet
    Write-Host " "
    Write-Host $author
    Write-Host " "
    Write-Host "1: Press '1' to enable Account Management Auditing."
    Write-Host "2: Press '2' to disable Account Management Auditing."
    Write-Host "3: Press '3' to enable Account Logon Auditing."
    Write-Host "4: Press '4' to disable Account Logon Auditing."
    Write-Host "5: Press '5' to list Audit categories."
    Write-Host "6: Press '6' to go back."
    Write-Host "Q: Press 'Q' to quit."
    Write-Host " "
}




## Enable Account Management Auditing

function enable-AM-auditing{

 auditpol /set /category:"Account Management" /failure:enable /success:enable     



}

## Disable Account Management Auditing 
function disable-AM-auditing{

 auditpol /set /category:"Account Management" /failure:disable /success:disable 


}

## Enable Account Logon Auditing 
function enable-AL-auditing{

 auditpol /set /category:"Account Logon" /failure:enable /success:enable 


}

## Disable Account Logon Auditing 
function disable-AL-auditing{

 auditpol /set /category:"Account Logon" /failure:disable /success:disable 


}

## Show categories

function show-categories{

 auditpol /get /category:"Account Management","Account Logon"


}





### Selections

do
 {
     Show-Menu -Title 'AuditInsight'
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
            enable-AM-auditing
        
         
         } '2' {
            disable-AM-auditing
       
         
         } '3' {
            enable-AL-auditing
          
         
         } '4' {

            enable-AL-auditing
         
         } '5' {

            show-categories
         

         } '6' {

            .\auditinsight-agent.ps1

         }


     }
     pause
 }
 until ($selection -eq 'q')