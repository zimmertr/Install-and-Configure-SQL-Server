clear
$ErrorActionPreference = "Stop" #Automatically exit script in the event of an unhandled exception.
Write-Host "Welcome to the SQL Server Installation Script. - $(Get-Date -Format T)" -ForegroundColor "Green"


#If installation media isn't already present on the desktop, prompt user to download and copy it there. Offer to install chrome and auto-launch visualstudio.com to the product download page.
if (![System.IO.File]::Exists("C:\Users\$env:UserName\Desktop\sql_installer.iso")){
    
    Write-Host; Write-Host -NoNewline "Please download the "; Write-Host -NoNewline "SQL Server 2012 Enterprise Edition with Service Pack 4" -ForegroundColor Cyan; Write-Host -NoNewline " installation media from VisualStudio.com, copy it to "; Write-Host -NoNewline "C:\Users\$env:UserName\Desktop" -ForegroundColor Cyan ; Write-Host -NoNewline ", and name it "; Write-Host "sql_installer.iso." -ForegroundColor Cyan

    if (![System.IO.File]::Exists("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")){
    
        Write-Host; $downloadChrome = Read-Host -Prompt "Would you like to download and install Google Chrome? (ex: Yes|No)"
        while ("Yes","No" -notcontains $downloadChrome){
            $twoNic = Read-Host "Invalid Input! Would you like to download Google Chrome and launch the SQL Server Download Page? (ex: Yes|No)"
        }
    
        if ($downloadChrome -eq "Yes"){
            Write-Host; Write-Host "-Installing Google Chrome now." -ForegroundColor Cyan

            $Path = $env:TEMP
            $Installer = "chrome_installer.exe"
            Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer
            Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait
            Remove-Item $Path\$Installer

            Write-Host; Write-Host "-Google Chrome has been installed. Launching browser now." -ForegroundColor Cyan
            & "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" https://my.visualstudio.com/Downloads?q=SQL%20Server%202012%20enterprise%20edition
        }
    
        else{
            Write-Host; Write-Host "-Google Chrome will not be installed. Download Link: https://my.visualstudio.com/Downloads"
        }
    }
    
    Write-Host; Write-Host "The script will automatically continue when the installation media has been detected."

}


#Wait until installation media appears to continue
While (![System.IO.File]::Exists("C:\Users\$env:UserName\Desktop\sql_installer.iso")){
    Start-Sleep -Seconds 1
}
Write-Host; Write-Host "Installation Media has been detected. Mounting ISO now. - $(Get-Date -Format T)" -ForegroundColor Yellow


#Mount iso on system
$sqlVolume = Mount-DiskImage -ImagePath "C:\Users\$env:UserName\Desktop\sql_installer.iso"  -PassThru | Get-Volume
Write-Host; Write-Host "Disk Image has been mounted. - $(Get-Date -Format T)" -ForegroundColor Yellow


#If response file isn't already present...
if (![System.IO.File]::Exists("C:\Users\$env:UserName\Desktop\sql_server_response_file.ini")){
    #Wait until response file appears to continue
    Write-Host; Write-Host -NoNewline "Please download the "; Write-Host -NoNewline "sql_server_response_file.ini " -ForegroundColor Cyan; Write-Host -NoNewline "and copy it to "; Write-Host -NoNewline "C:\Users\$env:UserName\Desktop " -ForegroundColor Cyan ; Write-Host "alongside the SQL Server Installation disk image."
    Write-Host; Write-Host "The script will automatically continue when the Response File has been detected."
    While (![System.IO.File]::Exists("C:\Users\$env:UserName\Desktop\sql_server_response_file.ini")){
        Start-Sleep -Seconds 1
    }
    Write-Host; Write-Host "Reponse File has been detected. Continuing installation now. - $(Get-Date -Format T)" -ForegroundColor Yellow
}

#Configure response file fields manually if necessary
Write-Host; $configureInstall = Read-Host -Prompt "Would you like to configure the installation? (ex: Yes|No)"
while ("Yes","No" -notcontains $configureInstall){
            $configureInstall = Read-Host "Invalid Input! Would you like to configure the installation? (ex: Yes|No)"
}
if ($configureInstall -eq "Yes"){
    $instanceName = Read-Host -Prompt "Enter Instance Name"
    $instanceID = Read-Host -Prompt "Enter Instance ID"
    $saPassword = Get-Credential -Message "Enter SA password" -UserName No_Username
    $sqlAdmins = Read-Host -Prompt "Enter AD SQL Admins"
    $installSharedDir = Read-Host -Prompt "Enter Installation Directory (ex: C:\Program Files\Microsoft SQL Server)"
    $installSharedWowDir = Read-Host -Prompt "Enter Installation Directory (x86) (ex: C:\Program Files (x86)\Microsoft SQL Server)"
    $instanceDir = Read-Host -Prompt "Enter Instance Directory (ex: F:\Program Files\Microsoft SQL Server)"
    $sqlBackupDir = Read-Host -Prompt "Enter Backup Directory (ex: K:\Program Files\Microsoft SQL Server\MSSQL.11.$instanceName\MSSQL\Backup)"
    $sqlUserDbLogDir = Read-Host -Prompt "Enter Database Log Directory (ex: G:\Program Files\Microsoft SQL Server\MSSQL.11.$instanceName\MSSQL\DATA)"
    $sqlTempDbDir = Read-Host -Prompt "Enter Temp Database Directory (ex: H:\Program Files\Microsoft SQL Server\MSSQL.11.$instanceName)"
    $sqlTempDbLogDir = Read-Host -Prompt "Enter Temp Database Log Directory (ex: I:\Program Files\Microsoft SQL Server\MSSQL.11.$instanceName)"
    $quietMode = Read-Host -Prompt "Would you like the SQL Server installer to be Verbose or Silent? (ex: Verbose|Silent)"
    while ("Verbose","Silent" -notcontains $quietMode){
        $quietMode = Read-Host "Invalid Input! Would you like the SQL Server installer to be Verbose or Silent? (ex: Verbose|Silent)"
    }

    
    Write-Host; Write-Host "Your configuration paramaters have been gathered. Modifying the configuration file now. - $(Get-Date -Format T)" -ForegroundColor Yellow
    
    if ($quietMode -eq 'Verbose'){
        (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('INDICATEPROGRESS="False"', 'INDICATEPROGRESS="True"') | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    }
    else{
        (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('INDICATEPROGRESS="True"', 'INDICATEPROGRESS="False"') | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    }
    
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('SAPASSWORD', $saPassword.GetNetworkCredential().password) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('DOMAIN\SQL ADMIN GROUP" "USERNAME', $sqlAdmins) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('C:\Program Files\Microsoft SQL Server', $installSharedDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('C:\Program Files (x86)\Microsoft SQL Server', $installSharedWowDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('F:\Program Files\Microsoft SQL Server', $instanceDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('K:\Program Files\Microsoft SQL Server\MSSQL11.INSTANCEID\MSSQL\Backup', $sqlBackupDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('G:\Program Files\Microsoft SQL Server\MSSQL11.INSTANCEID\MSSQL\Data', $sqlUserDbLogDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('H:\Program Files\Microsoft SQL Server\MSSQL11.INSTANCEID\MSSQL\Data', $sqlTempDbDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('I:\Program Files\Microsoft SQL Server\MSSQL11.INSTANCEID\MSSQL\Data', $sqlTempDbLogDir) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('INSTANCENAME', $instanceName) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    (Get-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini).replace('INSTANCEID', $instanceID) | Set-Content C:\Users\$env:UserName\Desktop\sql_server_response_file.ini
    Write-Host; Write-Host "Installation has been successfully configured. - $(Get-Date -Format T)" -ForegroundColor Yellow

}
else{
    Write-Host; Write-Host "Default configuration will be used. - $(Get-Date -Format T)" -ForegroundColor Yellow
}

if ((get-windowsfeature -Name NET-Framework-Features).InstallState -eq 'Available'){
    Write-Host; Write-Host "-Installing .NET Framework 3.5 now. - $(Get-Date -Format T)" -ForegroundColor Cyan
    
    try{
        Install-WindowsFeature -Name NET-Framework-Features -IncludeAllSubFeature > $null
    }
    catch{
        Write-Host; Write-Host "Not able to automatically install .NET Framework. This means that Windows cannot find the required source files. Please download and mount Windows Installation Media and follow these instructions before running this script again. - $(Get-Date -Format T)" -ForegroundColor Red
        Write-Host "https://support.microsoft.com/en-us/help/2913316/you-can-t-install-features-in-windows-server-2012-r2" -ForegroundColor Magenta
        exit
    }
}
if ((get-windowsfeature -Name NET-Framework-Features).InstallState -eq 'Installed'){
    Write-Host; Write-Host "-.NET Framework 3.5 has been installed. - $(Get-Date -Format T)" -ForegroundColor Cyan
}
else{
    Write-Host; Write-Host ".NET Framework 3.5 might not be installed. Please try again. - $(Get-Date -Format T)" -ForegroundColor Red
    exit
}


#Install SQL Server
Write-Host; Write-Host "Installing SQL Server now. - $(Get-Date -Format T)" -ForegroundColor Yellow; Write-Host
$driveLetter = $sqlVolume.DriveLetter + ":"
$installExec="$driveLetter\setup.exe"
& "$installExec" "/ConfigurationFile=C:\Users\$env:UserName\Desktop\sql_server_response_file.ini" "/IAcceptSQLServerLicenseTerms" 

$sqlInstances = [System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()
if ($sqlInstances.InstanceName){
    Write-Host; Write-Host "SQL Server has been successfully installed. - $(Get-Date -Format T)" -ForegroundColor Yellow
}
else{
    Write-Host; Write-Host "SQL Server installation failed. Please check logs found at: C:\Program Files\Microsoft SQL Server" -ForegroundColor Red    
    exit
}


#See if user would like to customize tcp/ip ports.
if ($sqlInstances.InstanceName){
    Write-Host; $enableAllIps = Read-Host -Prompt "Would you like to enable listening on all IP Protocols? (ex: Yes|No)"
    while ("Yes","No" -notcontains $enableAllIps){
            $enableAllIps = Read-Host "Invalid Input! Would you like to enable listening on all IP Protocols? (ex: Yes|No)"
    }
    if ($enableAllIps -eq "Yes"){
        Write-Host; Write-Host "Configuring SQL Server to listen on all available IP Protocols. - $(Get-Date -Format T)" -ForegroundColor Yellow
        $SQLInstancePath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11." + $sqlInstances.InstanceName
        $SQLTcpPath = "$SQLInstancePath\MSSQLServer\SuperSocketNetLib\Tcp"
        
        (Get-ItemProperty "$SQLInstancePath\MSSQLServer\SuperSocketNetLib\Tcp").ListenOnAllIPs > $null
        Set-ItemProperty -Path "$SQLInstancePath\MSSQLServer\SuperSocketNetLib\Tcp" -Name "ListenOnAllIPs" -Value $Enabled
        (Get-ItemProperty "$SQLInstancePath\MSSQLServer\SuperSocketNetLib\Tcp").ListenOnAllIPs > $null
    }
    else{
        Write-Host; Write-Host "IP Protocol listening status will not be customized. - $(Get-Date -Format T)" -ForegroundColor Yellow
    }
    

    Write-Host; $customizePort = Read-Host -Prompt "Would you like to customize the TCP/IP Ports that SQL Server uses? (ex: Yes|No)"
    while ("Yes","No" -notcontains $customizePort){
            $customizePort = Read-Host "Invalid Input! Would you like to customize the TCP/IP Ports that SQL Server uses? (ex: Yes|No)"
    }
    
    
    if ($customizePort -eq "Yes"){
        $staticPort = Read-Host -Prompt "Enter Static Port Number to be used by SQL Server (ex: 46123)"
        $dynamicPort = Read-Host -Prompt "Enter Dynamic Port Number. Null if N/A. (ex: 46123)"
        $ipProtocol="IP1","IP2","IP3","IP4","IP5","IP6","IP7","IP8","IPALL"
        $protocolEnabled = "1"            # 0: Disabled; 1: Enabled
        $protocolActive = "1"             # 0: Disabled; 1: Enabled

        Write-Host; Write-Host "All required information has been gathered. Modifying default ports now. - $(Get-Date -Format T)" -ForegroundColor Yellow
        #Write changes to SQL Server
        foreach ($ip in $ipProtocol){
            try{
                Set-ItemProperty -Path "$SQLTcpPath\$IP" -Name "Enabled" -Value $protocolEnabled
                Set-ItemProperty -Path "$SQLTcpPath\$IP" -Name "Active" -Value $protocolActive
                Set-ItemProperty -Path "$SQLTcpPath\$IP" -Name "TcpPort" -Value $staticPort
                Set-ItemProperty -Path "$SQLTcpPath\$IP" -Name "TcpDynamicPorts" -Value $dynamicPort
            }
            catch{
                #empty catch block added so that try could exist. 
                #try exists becuase in event VM provisioned with one NIC instead of TWO, IP5 will not exist and thus cannot be configured. Script would crash otherwise. 
                #Logic could be added in the future to build list of available IP Protocols instead of a hardcoded array.
                #Possible to add more than one extra NIC? Probably? Rare case, but would cause additional IP Protocol to not be configured correctly.
            }
        }

        Write-Host; Write-Host "Default ports were successfully altered. - $(Get-Date -Format T)" -ForegroundColor Yellow
        Write-Host; $restartSql = Read-Host -Prompt "Would you like to restart SQL Server now? (ex: Yes|No)"
        while ("Yes","No" -notcontains $restartSql){
            $restartSql = Read-Host "Invalid Input! Would you like to restart SQL Server now? (ex: Yes|No)"
        }

        if ($restartSql -eq "Yes"){
            Write-Host; Write-Host "Restarting SQL Server now. - $(Get-Date -Format T)" -ForegroundColor Yellow
            Restart-Service -Force ("SQLAgent$" + $sqlInstances.InstanceName) -WarningAction SilentlyContinue
            Write-Host; Write-Host "SQL Server has been successfully restarted - $(Get-Date -Format T)" -ForegroundColor Yellow
        }
        else{
            Write-Host; Write-Host "SQL Server will not be restarted. It is necessary to restart it to load your configurations. - $(Get-Date -Format T)" -ForegroundColor Yellow
        }
    }
    else{
        Write-Host; Write-Host "SQL Server Ports will not be customized. - $(Get-Date -Format T)" -ForegroundColor Yellow
    }
}

else
{
    Write-Host; Write-Host "Something must have gone wrong. No SQL Server instances were detected on this machine. Please attempt installation again. if you chose to customize the installation, please replace the response file on the desktop with a vanilla one. - $(Get-Date -Format T)" -ForegroundColor Red
    exit
}


#See if user would like to customize memory allocation
#Determine physical memory present in server
$physicalMemory = $((Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum /1MB)


#Create new PS object based on SMO. Connect to new SQL Server instance on localhost. 
[System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’) | out-null
$s = New-Object (‘Microsoft.SqlServer.Management.Smo.Server’) “localhost\$($sqlInstances.InstanceName)”


#Start interaction with user
Write-Host; Write-Host -NoNewline "This virtual machine has "; Write-Host -NoNewline $($physicalMemory) "MB" -ForegroundColor Cyan; Write-Host " of physical memory."
Write-Host; Write-Host "The current maximum and minimum memory allocation for SQL Server are:"

Write-Host "  Max: " $s.Configuration.MaxServerMemory.RunValue "MB" -ForegroundColor Cyan
Write-Host "  Min: " $s.Configuration.MinServerMemory.RunValue "MB" -ForegroundColor Cyan

Write-Host; $configureSQLMemory = Read-Host -Prompt "Would you like to configure the memory allocations? (ex: Yes|No)"
while ("Yes","No" -notcontains $configureSQLMemory){
    $configureSQLMemory = Read-Host "Invalid Input! Would you like to configure the memory allocations? (ex: Yes|No)"
}


if ($configureSQLMemory -eq "Yes"){
    Write-Host; Write-Host "WARNING! SQL Server should leave at least 10240MB of memory available for the OS. Since your system has $($physicalMemory) MB, I recommend: $($physicalMemory - 10240) MB as the maximum." -ForegroundColor Magenta
    Write-Host; [int]$desiredMaxMem = Read-Host -Prompt "Enter Maximum Memory in MB: (ex: 25476)"
    
    #gather max mem
    while (($desiredMaxMem -gt $physicalMemory) -or ($desiredMaxMem -lt 4096)){
        Write-Host $desiredMaxMem "is not an acceptable integer. Please enter an amount between 4096 and" $physicalMemory "MB." -ForegroundColor Red; write-host
        [int]$desiredMaxMem = Read-Host -Prompt "Enter Maximum Memory in MB: (ex: 25476)"
    }

    #gather min mem
    Write-Host; [int]$desiredMinMem = Read-Host -Prompt "Enter Minimum Memory in MB: (ex 0)"

    while (($desiredMinMem -gt $desiredMaxMem) -or ($desiredMinMem -lt 0)){
        Write-Host $desiredMinMem "is not an acceptable integer. Please enter an amount between 0 and" $desiredMaxMem "MB." -ForegroundColor Red; write-host
        [int]$desiredMinMem = Read-Host -Prompt "Enter Minimum Memory in MB: (ex: 25476)"
    }
        
    #set max and min mem
    $s.Configuration.MinServerMemory.ConfigValue = $desiredMinMem
    $s.Configuration.MaxServerMemory.ConfigValue = $desiredMaxMem
    $s.Configuration.Alter()

    if (($s.Configuration.MinServerMemory.ConfigValue -eq $desiredMinMem) -and ($s.Configuration.MaxServerMemory.ConfigValue -eq $desiredMaxMem)){
        Write-Host; Write-Host "Memory configuration was succesfully updated. - $(Get-Date -Format T)" -ForegroundColor Yellow
    }
    else{
        Write-Host "Failed to update memory configuration. Please try again. - $(Get-Date -Format T)" -ForegroundColor Red; Write-Host
    }
    
}
else{
    Write-Host; Write-Host "SQL Server memory allocation will not be modified."
}


Write-Host; $createBackupDirs = Read-Host -Prompt "Would you like to create the directories on the Backup volume automatically? (ex: Yes|No)"
while ("Yes","No" -notcontains $createBackupDirs){
    $createBackupDirs = Read-Host "Invalid Input! Would you like to create the directories on the Backup volume automatically? (ex: Yes|No)"
}
if ($createBackupDirs -eq "Yes"){
    Write-Host; Write-Host "Creating Backup Directories now. - $(Get-Date -Format T)" -ForegroundColor Yellow

        while (!$sqlBackupDir){
            Write-Host; Write-Host "The installation was not customized or the installer was restarted after customization. Please provide information to detect the proper destination."
            $sqlBackupDir = Read-Host -Prompt "Enter Backup Directory"
        }

    New-Item -ItemType Directory -Path $sqlBackupDir"\MSSQL\Backup\Daily" > $null
    New-Item -ItemType Directory -Path $sqlBackupDir"\MSSQL\Backup\UI" > $null                                                                                                                                                           
    New-Item -ItemType Directory -Path $sqlBackupDir"\MSSQL\Backup\Weekly" > $null

    if ([System.IO.Directory]::Exists($sqlBackupDir + "\MSSQL\Backup\Weekly")){
        Write-Host; Write-Host "Backup Directories were succesfully created. - $(Get-Date -Format T)" -ForegroundColor Yellow    
    }
    else{
        Write-Host; Write-Host "Backup Directories were not succesfully created. Please try again.- $(Get-Date -Format T)" -ForegroundColor Red
    }    
}
else{
    Write-Host; Write-Host "Backup directories will not automatically be created. - $(Get-Date -Format T)" -ForegroundColor Yellow
}


Write-Host; Write-Host "Configuring MSSQL and SQLAgent services to startup as Automatic (Delayed) instead of Automatic to allow time for NETLOGON service to start. - $(Get-Date -Format T)" -ForegroundColor Yellow
$sqlAgentServiceName = "SQLAgent$" + $($sqlInstances.InstanceName) 
$sqlServerServiceName = "MSSQL$" + $($sqlInstances.InstanceName) 
Set-ItemProperty -Path "Registry::HKLM\System\CurrentControlSet\Services\$sqlAgentServiceName" -Name "DelayedAutostart" -Value 1 -Type DWORD
Set-ItemProperty -Path "Registry::HKLM\System\CurrentControlSet\Services\$sqlServerServiceName" -Name "DelayedAutostart" -Value 1 -Type DWORD
Write-Host; Write-Host "Services have been successfully configured to have a 2 minute delayed start. This will not take effect until the next time the registry is loaded. - $(Get-Date -Format T)" -ForegroundColor Yellow


#print deployment summary
if ($sqlInstances.InstanceName){
    Start-Sleep -Seconds 2
    Write-Host; Write-Host "All steps have completed successfully. Printing a deployment summary now. - $(Get-Date -Format T)" -ForegroundColor Green; Write-Host
    Write-Host "*************************************************" -ForegroundColor Green
    Write-Host; Write-Host "Instance Name   : " $sqlInstances.InstanceName
    Write-Host "Instance Version: " $sqlInstances.Version
    
    $service = Get-Service -ComputerName $env:COMPUTERNAME | where {($_.name -like "MSSQL$*" -or $_.name -like "MSSQLSERVER" -or $_.name -like "SQL Server (*")}
    Write-Host "Instance Status : " $service.Status
    
    Write-Host -NoNewline "Minimum Memory  :  "; Write-Host  $($s.Configuration.MinServerMemory.ConfigValue) "MB"
    Write-Host -NoNewline "Maximum Memory  :  "; Write-Host  $($s.Configuration.MaxServerMemory.ConfigValue) "MB"

    $portSummary = (Get-ChildItem $SQLTcpPath | ForEach-Object {Get-ItemProperty $_.pspath} | Format-Table -Autosize -Property @{N='IPProtocol';E={$_.PSChildName}}, IpAddress, Enabled, Active, TcpPort, TcpDynamicPorts)
    Write-Host "Instance Ports  : "; Write-Host -NoNewline ($portSummary | Out-String) -ForegroundColor Cyan
    Write-Host -NoNewline "*************************************************" -ForegroundColor Green
}
else
{
    Write-Host; Write-Host "Something must have gone wrong. No SQL Server instances were detected on this machine. Please attempt installation again. if you chose to customize the installation, please replace the response file on the desktop with a vanilla one. - $(Get-Date -Format T)" -ForegroundColor Red
}

Write-Host; Read-Host -Prompt "Press Enter to exit"
