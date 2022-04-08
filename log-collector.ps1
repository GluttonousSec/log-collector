<# 

Author: John Walsh
Title: Log Collector
Version: 1.0
Date Created: 4/7/2022
Last Modified: 4/7/2022

#>

using namespace System.Management.Automation.Host

#Function declerations for account activity event IDs.
#-----------------------------------------------------------------------------------------------------------------------------------------
function Get-AccountActivity {
    #Check if account activity folder exists. Create if it doesn't. 
    $local:Dir = "C:\collections\account_activity"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "account_activity" -ItemType Directory
    }
    
    #Find specific account event IDs and export them to CSV.
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4624} | Export-Csv "C:\collections\account_activity\successful_signins.csv"
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4634} | Export-Csv "C:\collections\account_activity\successful_logoffs.csv"
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4740} | Export-Csv "C:\collections\account_activity\account_lockouts.csv"
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4625} | Export-Csv "C:\collections\account_activity\failed_logins.csv"
}

function Get-SigninActivity {
    #Check if account activity folder exists. Create if it doesn't. 
    $local:Dir = "C:\collections\account_activity"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "account_activity" -ItemType Directory
    }
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4624} | Export-Csv "C:\collections\account_activity\successful_signins.csv"
}

function Get-SignoffActivity {
    #Check if account activity folder exists. Create if it doesn't. 
    $local:Dir = "C:\collections\account_activity"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "account_activity" -ItemType Directory
    }
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4634} | Export-Csv "C:\collections\account_activity\successful_logoffs.csv"
}

function Get-LockoutActivity {
    #Check if account activity folder exists. Create if it doesn't. 
    $local:Dir = "C:\collections\account_activity"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "account_activity" -ItemType Directory
    }
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4740} | Export-Csv "C:\collections\account_activity\account_lockouts.csv"
}

function Get-FailedActivity {
    #Check if account activity folder exists. Create if it doesn't. 
    $local:Dir = "C:\collections\account_activity"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "account_activity" -ItemType Directory
    }
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4625} | Export-Csv "C:\collections\account_activity\failed_logins.csv"
}
#-----------------------------------------------------------------------------------------------------------------------------------------


#Function declerations for scheduled tasks.
#-----------------------------------------------------------------------------------------------------------------------------------------
function Get-TaskActivity {
    #Check if scheduled tasks folder exists. Create if it doesn't.
    $local:Dir = "C:\collections\scheduled_tasks"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "scheduled_tasks" -ItemType Directory
    }
    #Find specific scheduled task event IDs and export them to CSV.
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4698} | Export-Csv "C:\collections\scheduled_tasks\task_created.csv"
    Get-EventLog -LogName Security | Where-Object {$_.EventID -eq 4699} | Export-Csv "C:\collections\scheduled_tasks\task_deleted.csv"
}
#-----------------------------------------------------------------------------------------------------------------------------------------


#Event Log Handling
#-----------------------------------------------------------------------------------------------------------------------------------------

#Export System logs
function Get-SystemLogs {
    $systemlog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'System' 
    $systemlog.BackupEventlog('c:\collections\event_logs\system.evtx')
    Compress-Logs
    Start-Cleanup
}

#Export Application logs
function Get-ApplicationLogs {
    $applicationlog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Application' 
    $applicationlog.BackupEventlog('c:\collections\event_logs\application.evtx')
    Compress-Logs
    Start-Cleanup
}

#Export Security logs
function Get-SecurityLogs {
    $securitylog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Security' 
    $securitylog.BackupEventlog('c:\collections\event_logs\security.evtx')
    Compress-Logs
    Start-Cleanup
}

function Get-AllLogs {
    $systemlog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'System' 
    $systemlog.BackupEventlog('c:\collections\event_logs\system.evtx')
    $applicationlog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Application' 
    $applicationlog.BackupEventlog('c:\collections\event_logs\application.evtx')
    $securitylog = Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Security' 
    $securitylog.BackupEventlog('c:\collections\event_logs\security.evtx')
    Compress-Logs
    Start-Cleanup
}


#Function Decleration for getting a specific event ID. Exports to CSV.
#-----------------------------------------------------------------------------------------------------------------------------------------
function Get-EventID{
    $local:Dir = "C:\collections\events"
    if (Test-Path -Path $local:Dir) {

    } else {
        New-Item -Path "c:\collections" -Name "events" -ItemType Directory
    }
    Clear-Host
    $local:location = Read-Host "Please enter the event log you would like to search. (System, Security, Application)"
    $local:eventID = Read-Host "Please enter the event ID you would like to export"
    Get-EventLog -LogName $local:location | Where-Object {$_.EventID -eq $local:eventID} | Export-Csv "C:\collections\events\$($eventID).csv"
}



#-----------------------------------------------------------------------------------------------------------------------------------------

#Compress event logs
function Compress-Logs {
    $compress = @{
        Path = "C:\collections\event_logs\*.evtx"
        CompressionLevel = "Fastest"
        DestinationPath = "C:\collections\event_logs\event_logs $(get-date -f yyyy-MM-dd).zip"
    }
    Compress-Archive @compress
}
#-----------------------------------------------------------------------------------------------------------------------------------------


#Cleanup
#-----------------------------------------------------------------------------------------------------------------------------------------
function Start-Cleanup {
    #Remove original event log files after compression.
    Get-ChildItem -Path 'C:\collections\event_logs\' *.evtx | ForEach-Object { Remove-Item -Path $_.FullName }
}
#-----------------------------------------------------------------------------------------------------------------------------------------

#Menus
#-----------------------------------------------------------------------------------------------------------------------------------------

#Main Menu
function Start-MainMenu {
    param (
        [string]$Title = 'Log Collector'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "The default working directory is: $($workingDir)"
    Write-host ""
    
    Write-Host "1: Press '1' to export account activity. (Logon/Logoff/Lockout)"
    Write-Host "2: Press '2' to export all event logs in their entirety. (Evtx)"
    Write-Host "3: Press '3' to export scheduled task logs. (Creation/Deletion)"
    Write-Host "4: Press '4' to export a specific event ID."
    Write-Host "Q: Press 'Q' to quit."
}

#Menu for event log exporting (Evtx).
function Start-EventMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Question
    )
    
    $all = [ChoiceDescription]::new('&All', 'Collects all event logs.')
    $system = [ChoiceDescription]::new('&System', 'Collects system event log.')
    $application = [ChoiceDescription]::new('&Application', 'Collects application event log.')
    $security = [ChoiceDescription]::new('&Security', 'Collects security event log.')
    

    $options = [ChoiceDescription[]]($system, $application, $security, $all)

    $result = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    switch ($result) {
        0 { Get-SystemLogs | Clear-Host}
        1 { Get-ApplicationLogs | Clear-Host}
        2 { Get-SecurityLogs | Clear-Host}
        3 { Get-AllLogs | Clear-Host}
    }

}

#Menu for handling account related activites.
function Start-AccountMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Question
    )
    
    $signonLogs = [ChoiceDescription]::new('&Logon', 'Collects all logon events.')
    $signoffLogs = [ChoiceDescription]::new('&Logoff', 'Collects all logoff events.')
    $failedLogs = [ChoiceDescription]::new('&Failed', 'Collects all failed logon events.')
    $lockoutLogs = [ChoiceDescription]::new('&Lockout', 'Collects all lockout events.')
    $allActivity = [ChoiceDescription]::new('&All', 'Collects all account related events.')

    

    $options = [ChoiceDescription[]]($signonLogs, $signoffLogs, $failedLogs, $lockoutLogs, $allActivity)

    $result = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    switch ($result) {
        0 { Get-SigninActivity }
        1 { Get-SignoffActivity | Clear-Host}
        2 { Get-FailedActivity | Clear-Host}
        3 { Get-LockoutActivity | Clear-Host}
        4 { Get-AccountActivity | Clear-Host}
    }

}

#-----------------------------------------------------------------------------------------------------------------------------------------

#Main Loop
#-----------------------------------------------------------------------------------------------------------------------------------------
function Start-MainLoop {
    $global:workingDir = "c:\collections"
    if (Test-Path -Path $workingDir) {
        "Working path exists. Continuing..."
    } else {
        "Working path does not exist. Creating path..."
        New-Item -Path "c:\" -Name "collections" -ItemType Directory
        New-Item -Path "c:\collections" -Name "event_logs" -ItemType Directory
        
    }
    

    do
    {
        Start-MainMenu
        $selection = Read-Host "Please make a selection"
        switch ($selection)
        {
        '1' {
            Start-AccountMenu -Title 'Account Logs' -Question 'Which account logs would you like to export?'
        } '2' {
            Start-EventMenu -Title 'Event Logs' -Question 'Which event log would you like to export?'
        } '3' {
            Get-TaskActivity
        } '4' {
            Get-EventID
        }
        }
        pause
    }
    until ($selection -eq 'q')
}
Start-MainLoop
#-----------------------------------------------------------------------------------------------------------------------------------------