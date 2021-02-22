function Config-Change {
    <#
    .SYNOPSIS
        Author: https://twitter.com/Valcan_K
        This script was made to help automate the setup of a Windows endpoint when using Cyb3rWard0g's HELK (https://github.com/Cyb3rWard0g/HELK).
            https://twitter.com/cyb3rward0g
        This script uses SwiftOnSecurity's Sysmon Config (https://github.com/SwiftOnSecurity/sysmon-config/blob/master/sysmonconfig-export.xml)
            https://twitter.com/SwiftOnSecurity
        This script also installs "Invoke-AtomicRedTeam" and the Atomic tests from Red Canary.
            Invoke-atomicredteam: https://github.com/redcanaryco/invoke-atomicredteam
            Atomic Red Team Tests: https://github.com/redcanaryco/atomic-red-team
            Red Canary: https://twitter.com/redcanary
    .PARAMETER HELKIP
        
        The HELKIP paramter will configure the winlogbeat.yml file with the IP address of your HELK system.
    
    .Example
        
        .\HELK-Endpoint-Atomic-Setup.ps1
        You will be prompted for the HELKIP after files are downloaded and installed.
    
    .NOTES
    
        Before building/executing this script I used the 1st option when installing HELK
        "1. KAFKA + KSQL + ELK + NGNIX"
        
        What this script does:
            1. Downloads winlogbeat from elastic.
            2. Downloads a modified version of Cyb3rWard0g's winlogbeat.yml, feel free to point this to another yml file if needed.
            3. Will prompt you for the HELK IP.
            4. Downloads Sysmon, the config from SwiftOnSecurity, and installs Sysmon.
            5. Restarts the services
            6. Logs should be shipping to HELK at this point.
            7. Installs Atomic Red Team and Prereqs
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$HELKIP = $HELKIP
        # Prompting for HELK IP address
    )
    Try {
        winlog-Install
    }
    Catch {
        Write-Host "Failed"
    }
}
function Download-Files {
    hostname
    Write-Host "Starting Winlog Download"
    # Downloading winlogbeat
    Invoke-WebRequest -URI https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.11.0-windows-x86_64.zip -OutFile $env:USERPROFILE\Downloads\winlogbeat.zip
    Write-Host "Extracting Winlog files to 'C:\Program Files\'"
    # Extracting contents of winlogbeat
    Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\winlogbeat.zip" -DestinationPath "C:\Program Files\"
    # Changing the Directory Name
    Rename-Item "C:\Program Files\winlogbeat-7.11.0-windows-x86_64" "C:\Program Files\winlogbeat"
    Write-Host "Downloading a version of Cyb3rWard0g's winlogbeat.yml config from my repo."
    # If you want to use a different winlogbeat.yml file, just change url below.
    Invoke-WebRequest -URI https://raw.githubusercontent.com/ValcanK/HomeLab/main/Endpoints/winlogbeat.yml -OutFile "C:\Program Files\winlogbeat\winlogbeat.yml"
    Write-Host "Starting Sysmon download"
    # Downloading sysmon
    Invoke-WebRequest -URI https://download.sysinternals.com/files/Sysmon.zip -OutFile $env:USERPROFILE\Downloads\Sysmon.zip
    Write-Host "Extracting Sysmon files to 'C:\Program Files\Sysmon'"
    # Extracting contents of sysmon to Program Files
    Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\Sysmon.zip" -DestinationPath "C:\Program Files\Sysmon"
    Sysmon-Function
}
function Sysmon-Function {
    # Setting sysmon up
    cd "C:\Program Files\Sysmon"
    Write-Host "Setting up Sysmon"
    .\sysmon.exe -i -accepteula -h md5,sha256,imphash -l -n
    .\sysmon.exe -c
    Write-Host "Downloading SwiftOnSecurtiy's Sysmon config file"
    Invoke-WebRequest -URI https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml -OutFile "C:\Program Files\Sysmon\sysmonconfig-export.xml"
    .\sysmon.exe -c .\sysmonconfig-export.xml
    Write-Host "Setting up Winlogbeat, you will be prompted for the HELK IP"
    Config-Change
}
function winlog-Install {
    # Setting winlogbeat up
    cd "C:\Program Files\winlogbeat\"
    .\install-service-winlogbeat.ps1
    (Get-Content -Path "C:\Program Files\winlogbeat\winlogbeat.yml" -Raw) -replace '<HELK-IP>',$HELKIP | Set-Content -Path "C:\Program Files\winlogbeat\winlogbeat.yml"
    .\winlogbeat.exe config test -c .\winlogbeat.yml -e
    .\winlogbeat.exe setup -e
    Restart-Service winlogbeat
    InstallAtomic
}
function InstallAtomic {
    cd "$env:USERPROFILE\Documents"
    # Installing NuGet
    Write-Host "Installing NuGet"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    # Downloading and Installing Invoke-AtomicRedTeam
    Write-Host "Downloading invoke-atomic and installing atomic tests."
    IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing); Install-AtomicRedTeam -getAtomics -Force
    # Importing the Atomic Module
    Write-Host "Importing the Invoke-Atomic Module"
    Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
    # Installing all of the Invoke-AtomicTest Prereqs
    Write-Host "Installing Prereqs for the Atomic Tests... this will take a few minutes."
    Invoke-AtomicTest All -GetPrereqs
    # Showing the details for all Atomics
    Write-Host "Listing details for each Atomic test."
    Invoke-AtomicTest All -ShowDetailsBrief
    Write-Host "Invoke-AtomicTest and the Atomics have been installed."
    Write-Host "To execute tests, simply use 'Invoke-AtomicTest T####' or refer to: https://github.com/redcanaryco/invoke-atomicredteam/wiki/Execute-Atomic-Tests-(Local)"
}
Download-Files
