function Config-Change {
    <#
    .SYNOPSIS
        
        This script was made to help automate the setup of a Windows endpoint when using Cyb3rWard0g's HELK.
    
    .PARAMETER HELKIP
        
        The HELKIP paramter will configure the winlogbeat.yml file with the IP address of your HELK system.
    
    .Example
        
        .\Endpoint-HELK-Setup.ps1
        You will be prompted for the HELKIP after files are downloaded and installed.
    
    .NOTES
    
        Before building/executing this script I used the 1st option when installing HELK
        "1. KAFKA + KSQL + ELK + NGNIX"
        
        What this script does:
            1. Downloads winlogbeat from elastic.
            2. Downloads a modified version Cyb3rWard0g's winlogbeat.yml, feel free to point this to another yml file if needed.
            3. Will prompt you for the HELK IP.
            4. Downloads Sysmon, the config from Cyber3rWard0g, and installs Sysmon.
            5. Restarts the services
            6. After a few moments logs should be showing up in Kibana (you may have to setup the winlogbeat index, but they will show up in the default log-endpoint* index).     
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$HELKIP = $HELKIP

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
    Invoke-WebRequest -URI https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.11.0-windows-x86_64.zip -OutFile $env:USERPROFILE\Downloads\winlogbeat.zip
    Write-Host "Extracting Winlog files to 'C:\Program Files\'"
    Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\winlogbeat.zip" -DestinationPath "C:\Program Files\"
    Rename-Item "C:\Program Files\winlogbeat-7.11.0-windows-x86_64" "C:\Program Files\winlogbeat"
    Write-Host "Downloading a version of Cyb3rWard0g's winlogbeat.yml config from my repo."
    # If you want to use a different winlogbeat.yml file, just change url below.
    Invoke-WebRequest -URI https://raw.githubusercontent.com/ValcanK/HomeLab/main/Endpoints/winlogbeat.yml -OutFile "C:\Program Files\winlogbeat\winlogbeat.yml"
    Write-Host "Starting Sysmon download"
    Invoke-WebRequest -URI https://download.sysinternals.com/files/Sysmon.zip -OutFile $env:USERPROFILE\Downloads\Sysmon.zip
    Write-Host "Extracting Sysmon files to 'C:\Program Files\Sysmon'"
    Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\Sysmon.zip" -DestinationPath "C:\Program Files\Sysmon"
    Sysmon-Function
}
function Sysmon-Function {
    cd "C:\Program Files\Sysmon"
    Write-Host "Setting up Sysmon"
    .\sysmon.exe -i -accepteula -h md5,sha256,imphash -l -n
    .\sysmon.exe -c
    Write-Host "Downloading Cyb3rWard0g's Sysmon config file"
    Invoke-WebRequest -URI https://gist.githubusercontent.com/Cyb3rWard0g/136481552d8845e52962534d1a4b8664/raw/9a5011cd7609040fad446ff9970a379fd27cb2cf/StartLogging.xml -OutFile "C:\Program Files\Sysmon\StartLogging.xml"
    .\sysmon.exe -c .\StartLogging.xml
    Write-Host "Setting up Winlogbeat, you will be prompted for the HELK IP"
    Config-Change
}
function winlog-Install {
    cd "C:\Program Files\winlogbeat\"
    .\install-service-winlogbeat.ps1
    (Get-Content -Path "C:\Program Files\winlogbeat\winlogbeat.yml" -Raw) -replace '<HELK-IP>',$HELKIP | Set-Content -Path "C:\Program Files\winlogbeat\winlogbeat.yml"
    .\winlogbeat.exe config test -c .\winlogbeat.yml -e
    .\winlogbeat.exe setup -e
    Restart-Service winlogbeat

}

Download-Files
