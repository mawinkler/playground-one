# #############################################################################
# Linux userdata
# #############################################################################
data "template_file" "linux_userdata_amzn" {
  template = <<EOF
#!/bin/bash

# install essential packages
yum install -y unzip

# install aws cli
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -Rf /tmp/aws /tmp/awscliv2.zip

# download from s3
mkdir -p /home/${var.linux_username_amzn}/download
aws s3 cp s3://${var.s3_bucket}/download /home/${var.linux_username_amzn}/download --recursive
chown ${var.linux_username_amzn}.${var.linux_username_amzn} -R /home/${var.linux_username_amzn}/download

# Deep Security Agent
ACTIVATIONURL='dsm://10.0.0.100:4120/'
MANAGERURL='https://10.0.0.100:4119'
CURLOPTIONS='--silent --tlsv1.2'
linuxPlatform='';
isRPM='';

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo You are not running as the root user.  Please try again with root privileges.;
    logger -t You are not running as the root user.  Please try again with root privileges.;
    exit 1;
fi;

rm -f /tmp/PlatformDetection
rm -f /tmp/agent.*

if ! type curl >/dev/null 2>&1; then
    echo "Please install CURL before running this script."
    logger -t Please install CURL before running this script
    exit 1
fi

curl $MANAGERURL/software/deploymentscript/platform/linuxdetectscriptv1/ -o /tmp/PlatformDetection $CURLOPTIONS --insecure
curlRet=$?

if [[ $curlRet == 0 && -s /tmp/PlatformDetection ]]; then
    . /tmp/PlatformDetection
elif [[ $curlRet -eq 60 ]]; then
    echo "TLS certificate validation for the agent package download has failed. Please check that your Deep Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center."
    logger -t TLS certificate validation for the agent package download has failed. Please check that your Deep Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center.
    exit 1;
else
    echo "Failed to download the agent installation support script."
    logger -t Failed to download the Deep Security Agent installation support script
    exit 1
fi

platform_detect
if [[ -z "$linuxPlatform" ]] || [[ -z "$isRPM" ]]; then
    echo Unsupported platform is detected
    logger -t Unsupported platform is detected
    exit 1
fi

echo Downloading agent package...
if [[ $isRPM == 1 ]]; then package='agent.rpm'
    else package='agent.deb'
fi
curl -H "Agent-Version-Control: on" $MANAGERURL/software/agent/$runningPlatform$majorVersion/$archType/$package?tenantID= -o /tmp/$package $CURLOPTIONS --insecure
curlRet=$?
isPackageDownloaded='No'
if [ $curlRet -eq 0 ];then
    if [[ $isRPM == 1 && -s /tmp/agent.rpm ]]; then
        file /tmp/agent.rpm | grep "RPM";
        if [ $? -eq 0 ]; then
            isPackageDownloaded='RPM'
        fi
    elif [[ -s /tmp/agent.deb ]]; then
        file /tmp/agent.deb | grep "Debian";
        if [ $? -eq 0 ]; then
            isPackageDownloaded='DEB'
        fi
    fi
fi

echo Installing agent package...
rc=1
if [[ $isPackageDownloaded = 'RPM' ]]; then
    rpm -ihv /tmp/agent.rpm
    rc=$?
elif [[ $isPackageDownloaded = 'DEB' ]]; then
    dpkg -i /tmp/agent.deb
    rc=$?
else
    echo Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
    logger -t Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
    exit 1
fi
if [[ $rc != 0 ]]; then
    echo Failed to install the agent package
    logger -t Failed to install the agent package
    exit 1
fi

echo Install the agent package successfully

sleep 15
/opt/ds_agent/dsa_control -r
/opt/ds_agent/dsa_control -a $ACTIVATIONURL "policyid:${var.linux_policy_id}"
  EOF
}

data "template_file" "linux_userdata_deb" {
  template = <<EOF
#!/bin/bash

# install essential packages
apt-get update
apt-get install -y unzip

# install aws cli
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
rm -Rf /tmp/aws /tmp/awscliv2.zip

# download from s3
mkdir -p /home/${var.linux_username_ubnt}/download
aws s3 cp s3://${var.s3_bucket}/download /home/${var.linux_username_ubnt}/download --recursive
chown ${var.linux_username_ubnt}.${var.linux_username_ubnt} -R /home/${var.linux_username_ubnt}/download

# Deep Security Agent
ACTIVATIONURL='dsm://10.0.0.100:4120/'
MANAGERURL='https://10.0.0.100:4119'
CURLOPTIONS='--silent --tlsv1.2'
linuxPlatform='';
isRPM='';

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo You are not running as the root user.  Please try again with root privileges.;
    logger -t You are not running as the root user.  Please try again with root privileges.;
    exit 1;
fi;

rm -f /tmp/PlatformDetection
rm -f /tmp/agent.*

if ! type curl >/dev/null 2>&1; then
    echo "Please install CURL before running this script."
    logger -t Please install CURL before running this script
    exit 1
fi

curl $MANAGERURL/software/deploymentscript/platform/linuxdetectscriptv1/ -o /tmp/PlatformDetection $CURLOPTIONS --insecure
curlRet=$?

if [[ $curlRet == 0 && -s /tmp/PlatformDetection ]]; then
    . /tmp/PlatformDetection
elif [[ $curlRet -eq 60 ]]; then
    echo "TLS certificate validation for the agent package download has failed. Please check that your Deep Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center."
    logger -t TLS certificate validation for the agent package download has failed. Please check that your Deep Security Manager TLS certificate is signed by a trusted root certificate authority. For more information, search for \"deployment scripts\" in the Deep Security Help Center.
    exit 1;
else
    echo "Failed to download the agent installation support script."
    logger -t Failed to download the Deep Security Agent installation support script
    exit 1
fi

platform_detect
if [[ -z "$linuxPlatform" ]] || [[ -z "$isRPM" ]]; then
    echo Unsupported platform is detected
    logger -t Unsupported platform is detected
    exit 1
fi

echo Downloading agent package...
if [[ $isRPM == 1 ]]; then package='agent.rpm'
    else package='agent.deb'
fi
curl -H "Agent-Version-Control: on" $MANAGERURL/software/agent/$runningPlatform$majorVersion/$archType/$package?tenantID= -o /tmp/$package $CURLOPTIONS --insecure
curlRet=$?
isPackageDownloaded='No'
if [ $curlRet -eq 0 ];then
    if [[ $isRPM == 1 && -s /tmp/agent.rpm ]]; then
        file /tmp/agent.rpm | grep "RPM";
        if [ $? -eq 0 ]; then
            isPackageDownloaded='RPM'
        fi
    elif [[ -s /tmp/agent.deb ]]; then
        file /tmp/agent.deb | grep "Debian";
        if [ $? -eq 0 ]; then
            isPackageDownloaded='DEB'
        fi
    fi
fi

echo Installing agent package...
rc=1
if [[ $isPackageDownloaded = 'RPM' ]]; then
    rpm -ihv /tmp/agent.rpm
    rc=$?
elif [[ $isPackageDownloaded = 'DEB' ]]; then
    dpkg -i /tmp/agent.deb
    rc=$?
else
    echo Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
    logger -t Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
    exit 1
fi
if [[ $rc != 0 ]]; then
    echo Failed to install the agent package
    logger -t Failed to install the agent package
    exit 1
fi

echo Install the agent package successfully

sleep 15
/opt/ds_agent/dsa_control -r
/opt/ds_agent/dsa_control -a $ACTIVATIONURL "policyid:${var.linux_policy_id}"
  EOF
}

data "template_file" "windows_userdata" {
    template = <<EOF
<powershell>
Start-Transcript -Path 'C:/userdata.log'

$logfilepath="C:\agent.log"
$fqdn="$env:computername"
$port_winrm=5986 
$port_ssh=22
$username = '${var.windows_username}'
$password = ConvertTo-SecureString '${random_password.windows_password.result}' -AsPlainText -Force 

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force -ErrorAction Ignore
$ErrorActionPreference = "stop"


function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO","WARN","ERROR")]
        [string] $level = "INFO"
    )
    # Create timestamp
    $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    # Append content to log file
    Add-Content -Path $logfilepath -Value "$timestamp [$level] - $message"
}


function Create-LocalAdmin {
    process {
        try {
            # Create new local user
            New-LocalUser "$username" -Password $password -FullName "$username" -Description "local admin" -ErrorAction stop
            Write-Log -message "$username local user created"

            # Add user to administrator group
            Add-LocalGroupMember -Group "Administrators" -Member "$username" -ErrorAction stop
            Write-Log -message "$username added to the Administrators group"

        } catch{ Write-log -message $_.Exception.message -level "ERROR"}
    }    
}


function Delete-WinRMListener {
    process {
        $config = winrm enumerate winrm/config/listener
        foreach($conf in $config) {
            Write-Log -message "verifying listener configuration"
            if($conf.Contains("HTTPS")) {
                try {
                    Write-Log -message "HTTPS is already configured. Deleting the exisiting configuration"
                    Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
                } catch { Write-log -message "Remove HTTPS listener - " + $_.Exception.message -level "ERROR"}
                break
            }
        }
    }
}


function Configure-WinRMHttpsListener {
    
    Delete-WinRMListener
    
    try {
        Write-Log -message "creating self-signed certificate"
        $Cert = (New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -dnsname $fqdn -NotAfter (Get-Date).AddMonths(36)).Thumbprint
        
        if(-not $Cert) {
            throw "Failed to create the test certificate."
            Write-Log -message "failed to create certificate" -level "ERROR"
        }
        $WinrmCreate= "winrm create --% winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=`"$fqdn`";CertificateThumbprint=`"$Cert`"}"
        invoke-expression $WinrmCreate
        winrm set winrm/config/service/auth '@{Basic="true"}'
    } catch { Write-log -message "Create certificate - "+ $_.Exception.message -level "ERROR"}
    
}


function Add-FirewallRule-WinRM {
    
    try {
        # Delete an exisitng rule
        Write-Log -message "Deleting the existing firewall rule for port $port_winrm"
        netsh advfirewall firewall delete rule name="Windows Remote Management (HTTPS-In)" dir=in protocol=TCP localport=$port_winrm | Out-Null

        # Add a new firewall rule
        Write-Log -message "Adding the firewall rule for port $port_winrm"
        netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=$port_winrm | Out-Null
    } catch { Write-log -message "Add/Remove firewall rule - "+ $_.Exception.message -level "ERROR"}
    
}


function Add-FirewallRule-SSH {
    
    try {
        # Delete an exisitng rule
        Write-Log -message "Deleting the existing firewall rule for port $port_ssh"
        netsh advfirewall firewall delete rule name="SSH Daemon (SSH-In)" dir=in protocol=TCP localport=$port_ssh | Out-Null

        # Add a new firewall rule
        Write-Log -message "Adding the firewall rule for port $port_ssh"
        netsh advfirewall firewall add rule name="SSH Daemon (SSH-In)" dir=in action=allow protocol=TCP localport=$port_ssh | Out-Null
    } catch { Write-log -message "Add/Remove firewall rule - "+ $_.Exception.message -level "ERROR"}
    
}


function Configure-WinRMService {

    try {
        Write-Log -message "Configuring winrm service"
        netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
        cmd.exe /c winrm quickconfig -q
        cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
        cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'
        cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="false"}'
        cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="false"}'
        cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
        cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
        cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
    } catch  { Write-log -message "configure winrm service - "+ $_.Exception.message -level "ERROR"}
}


function Configure-OpenSSHService {

    try {
        Write-Log -message "Adding OpenSSH.Server"
        Add-WindowsCapability -Online -Name OpenSSH.Server
        Add-WindowsCapability -Online -Name OpenSSH.Client

        Write-Log -message "Enabling automatic startup for OpenSSH.Server"
        Get-Service sshd | Set-Service -StartupType Automatic

        Write-Log -message "Starting OpenSSH.Server"
        Start-Service sshd

        # Write-Log -message "Setting default shell for OpenSSH.Server"
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value (Get-Command powershell.exe).Path -PropertyType String -Force

        # Get the public key 
        $authorizedKey = "${var.public_key}"
        # New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $authorizedKey
        # New-Item -Force -ItemType Directory -Path C:\Users\${var.windows_username}\.ssh; Add-Content -Force -Path C:\Users\${var.windows_username}\.ssh\authorized_keys -Value $authorizedKey
        New-Item -Force -ItemType File -Path C:\ProgramData\ssh\administrators_authorized_keys
        Add-Content -Force -Path C:\ProgramData\ssh\administrators_authorized_keys -Value $authorizedKey

        # Set the config to allow the pubkey auth
        $sshd_config="C:\ProgramData\ssh\sshd_config"
        (Get-Content $sshd_config) -replace '#PubkeyAuthentication', 'PubkeyAuthentication' | Out-File -encoding ASCII $sshd_config
        (Get-Content $sshd_config) -replace 'AuthorizedKeysFile	.ssh/authorized_keys', '#AuthorizedKeysFile	.ssh/authorized_keys' | Out-File -encoding ASCII $sshd_config
        # (Get-Content $sshd_config) -replace 'AuthorizedKeysFile __PROGRAMDATA__', 'AuthorizedKeysFile __PROGRAMDATA__' | Out-File -encoding ASCII $sshd_config
        # (Get-Content $sshd_config) -replace 'Match Group administrators', '#Match Group administrators' | Out-File -encoding ASCII $sshd_config

        # Set proper permissions on administrators_authorized_keys
        icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

        Get-Content C:\ProgramData\ssh\sshd_config

        # Reload the config
        Write-Log -message "Reload the config"
        Restart-Service sshd

        Write-Log -message "OpenSSH.Server running"
    } catch  { Write-log -message "configure openssh service - "+ $_.Exception.message -level "ERROR"}
}


function Configure-AWS-Tools {

    $ListofModulesInstalled = (Get-InstalledModule).Name
    Write-Log -message "Ckecking if AWS.Tools.Installer is installed on this instance."
    
    if ($ListofModulesInstalled -contains "AWS.Tools.Installer") { 
        Write-Log -message "AWS.Tools.Installer module exists."
    } else { 
        Write-Log -message "AWS.Tools.Installer module does not exist and needs to be installed."
        $ListofPackagesInstalled = (Get-PackageProvider -ListAvailable).Name
        Write-Log -message "AWS.Tools.Installer requires nuget package version 2.8.5.201 or above to be installed. Checking if correct version of nuget package is installed."
        if ($ListofPackagesInstalled -contains "Nuget")
        {
            Write-Log -message "Nuget package exists. Ckecking version."
            $CheckNugetVersion=(get-PackageProvider -Name NuGet).Version
            if($CheckNugetVersion -ge "2.8.5.201")
            {
                Write-Log -message "Nuget version is $CheckNugetVersion and that is acceptable."
            }else {
                Write-Log -message "Nuget version is $CheckNugetVersion and a newer package will be installed."
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
            }
        } else {
            Write-Log -message "Nugest package does not exists and will be installed."
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        }
        Install-Module -Name AWS.Tools.Installer -Force
        Write-Log -message "AWS.Tools.Installer was installed successfully."
    }
}


# Create local admin user
Create-LocalAdmin 

# Configure WinRM service
Configure-WinRMService

# Configure WinRM listener
Configure-WinRMHttpsListener

# Add Firewall rules
Add-FirewallRule-WinRM
Add-FirewallRule-SSH

# List the listeners
Write-Verbose -Verbose "Listing the WinRM listeners:"

Write-Verbose -Verbose "Querying WinRM listeners by running command: winrm enumerate winrm/config/listener"
winrm enumerate winrm/config/listener

# Add OpenSSH.Server
Configure-OpenSSHService

# Add AWS Tools
Configure-AWS-Tools


if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   Write-Warning "You are not running as an Administrator. Please try again with admin privileges."
   exit 1
}

$managerUrl="https://10.0.0.100:4119/"

$env:LogPath = "$env:appdata\Trend Micro\Deep Security Agent\installer"
New-Item -path $env:LogPath -type directory
Start-Transcript -path "$env:LogPath\dsa_deploy.log" -append

echo "$(Get-Date -format T) - DSA download started"
if ( [intptr]::Size -eq 8 ) { 
   $sourceUrl=-join($managerUrl, "software/agent/Windows/x86_64/agent.msi") }
else {
   $sourceUrl=-join($managerUrl, "software/agent/Windows/i386/agent.msi") }
echo "$(Get-Date -format T) - Download Deep Security Agent Package" $sourceUrl

$ACTIVATIONURL="dsm://10.0.0.100:4120/"

$WebClient = New-Object System.Net.WebClient

# Add agent version control info
$WebClient.Headers.Add("Agent-Version-Control", "on")
$WebClient.QueryString.Add("tenantID", "")
$WebClient.QueryString.Add("windowsVersion", (Get-CimInstance Win32_OperatingSystem).Version)
$WebClient.QueryString.Add("windowsProductType", (Get-CimInstance Win32_OperatingSystem).ProductType)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$WebClient.DownloadFile($sourceUrl,  "$env:temp\agent.msi")

if ( (Get-Item "$env:temp\agent.msi").length -eq 0 ) {
    echo "Failed to download the Deep Security Agent. Please check if the package is imported into the Deep Security Manager. "
 exit 1
}
echo "$(Get-Date -format T) - Downloaded File Size:" (Get-Item "$env:temp\agent.msi").length

echo "$(Get-Date -format T) - DSA install started"
echo "$(Get-Date -format T) - Installer Exit Code:" (Start-Process -FilePath msiexec -ArgumentList "/i $env:temp\agent.msi /qn ADDLOCAL=ALL /l*v `"$env:LogPath\dsa_install.log`"" -Wait -PassThru).ExitCode 
echo "$(Get-Date -format T) - DSA activation started"

Start-Sleep -s 50
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -r
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -a $ACTIVATIONURL "policyid:${var.windows_policy_id}"
echo "$(Get-Date -format T) - DSA Deployment Finished"

Stop-Transcript
</powershell>
    EOF
}
