# Bootstrapping PowerShell Script
data "template_file" "windows-dc-userdata" {
  template = <<EOF
<powershell>
Start-Transcript -Path 'C:/userdata.log'

$logfilepath="C:\agent.log"
$fqdn="$env:computername"
$port_winrm=5986 

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


net user Administrator "${var.windows_ad_safe_password}"
$Password = ConvertTo-SecureString "${var.windows_ad_safe_password}" -AsPlainText -Force;

# Configure WinRM service
Configure-WinRMService

# Configure WinRM listener
Configure-WinRMHttpsListener

# Add Firewall rules
Add-FirewallRule-WinRM

# List the listeners
Write-Verbose -Verbose "Listing the WinRM listeners:"

Write-Verbose -Verbose "Querying WinRM listeners by running command: winrm enumerate winrm/config/listener"
winrm enumerate winrm/config/listener

# Create Domain Forest
Add-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath C:\Windows\NTDS -DomainMode WinThreshold -DomainName ${var.windows_ad_domain_name} -DomainNetbiosName ${var.windows_ad_nebios_name} -ForestMode WinThreshold -InstallDns:$true -LogPath C:\Windows\NTDS -NoRebootOnCompletion:$true -SafeModeAdministratorPassword $Password -SysvolPath C:\Windows\SYSVOL -Force:$true;
Write-Log -message "Domain Forest created"

Restart-Computer -Force;

Stop-Transcript
</powershell>
EOF
}

# Create EC2 Instance
resource "aws_instance" "windows-server-dc" {
  ami                    = data.aws_ami.windows-server.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  source_dest_check      = false
  key_name               = var.key_name
  user_data              = data.template_file.windows-dc-userdata.rendered
  get_password_data      = true

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-windows-server-dc"
    Environment = var.environment
  }
}
