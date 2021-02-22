# The HELK Endpoint + Atomic Script
This script was created to help you automate the process of setting up a Windows endpoint when using HELK or an ELK stack.

## Usage:
- Disable Windows Defender (You'll be downloading tools from Atomic Red Team, this will trigger some detections). 
- Run PowerShell as Admin
- Allow unsigned scripts to run / change the execution policy ```powershell -exec bypass```
- Execute the script: ```.\HELK-Endpoint-Atomic-Setup.ps1```

## Here's what it does:
    1. Downloads winlogbeat from elastic.
    2. Downloads a modified version of Cyb3rWard0g's winlogbeat.yml (feel free to point this to another yml file if needed).
    3. Will prompt you for the HELK IP.
    4. Downloads Sysmon, the config from SwiftOnSecurity, and installs Sysmon.
    5. Restarts the services.
    6. Starts shipping logs to your HELK/ELK stack.
    7. Installs Atomic Red Team and Prereqs

### Screenshots:
Starting the Script:

![Starting Script](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Starting-Install.png)

Prompting you for HELK IP:

![Prompt](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Second-Script-UserPrompt.png)

Shipping Logs to HELK:

![Shipping Logs](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/HELK-Endpoint-Sysmon-Logs-Shipping.png)

Installing NuGet:

![NuGet](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Installing-NuGet.png)

Downloading and Installing Invoke-AtomicRedTeam and Atomics:

![Atomic](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Invoke-AtomicRedTeam-Installed.png)

Importing Invoke-Atomic and the Prereqs for the Atomics:

![Import And Prereqs](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/import-install.png)

Listing Details for the installed Atomics:

![Details](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Listing-Details.png)

Script Complete!

![Complete](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Install-Complete.png)

Testing the ```Invoke-AtomicTest T1003```

![Test](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Invoke-Test2.png)

Logs!

![Logs](/Endpoint-HELK-Winlog-Sysmon-Atomic/images/Invoke-mimi.png)
