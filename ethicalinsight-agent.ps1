function Show-Menu
{
    param (
        [string]$Title = ''
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
    Write-Host "1: Press '1' to enable scheduled task"
    Write-Host "2: Press '2' to disable scheduled task"
    Write-Host "3: Press '3' to store API Keys"
    Write-Host "4: Press '4' to enable Auditing on this Domain Controller"
    Write-Host "5: Press '5' to list AD Audit Agent enabled task."
    Write-Host "Q: Press 'Q' to quit."
    Write-Host " "
}




do
 {
     Show-Menu -Title 'AuditInsight'
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
         $APIhost = Read-Host "FQDN or IP of AuditInsight Server-side: "
         $script = "$pwd\ethicalinsight-tasks.ps1 -APIhost $APIhost -path $pwd"

         schtasks /create /tn "EthicalInsight_Agent_task" /tr "powershell.exe -windowstyle hidden -File $script"  /sc minute /mo 30 /f
         
         } '2' {
         
         schtasks /delete /tn "EthicalInsight_Agent_task" /f
         
         } '3' {
          $APIKey = Read-Host "Type your API Key from dashboard: " 
          $APIKey |  ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString |  Set-Content -Path .\EthicalInsight-apikeys.conf 
          
         
         } '4' {

         .\enable-auditing.ps1


         } '5' {
         Clear-Host
         Get-ScheduledTask -TaskName  "ADAuditAgent*"

         }

     }
     pause
 }
 until ($selection -eq 'q')



 