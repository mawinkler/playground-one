# Bootstrapping PowerShell Script
data "template_file" "windows-dc-userdata" {
  template = <<EOF
<powershell>
Start-Transcript -Path 'C:/userdata.log'

$logfilepath="C:\agent.log"

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

net user Administrator "${var.windows_ad_safe_password}"
$Password = ConvertTo-SecureString "${var.windows_ad_safe_password}" -AsPlainText -Force;
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
