# Bootstrapping PowerShell Script
data "template_file" "windows-member-userdata" {
  template = <<EOF
<powershell>
Start-Transcript -Path 'C:/userdata.log'

$logfilepath="C:\agent.log"

Set-ExecutionPolicy unrestricted -Force

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
$domain = (Get-WmiObject win32_computersystem).Domain
$hostname = hostname
$domain_username = "${var.windows_ad_domain_name}\${var.windows_ad_user_name}"
$domain_password = ConvertTo-SecureString "${var.windows_ad_safe_password}" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($domain_username,$domain_password)
Write-Log -message "Administrator password set"

if ($domain -ne '${var.windows_ad_domain_name}') {
  Write-Log -message "Joining domain in 300 seconds" -level "INFO"
  Start-Sleep -Seconds 300

  # Comment
  $Stoploop = $false
  [int]$Retrycount = "0"
    
  do {
    try {
      Add-Computer -DomainName ${var.windows_ad_domain_name} -Credential $credential -Passthru -Verbose -Force 
      # -Restart
      Write-Log -message "Domain join successful" -level "INFO"
      $Stoploop = $true
      Restart-Computer -Force;
    } catch {
      Write-log -message $_.Exception.message -level "ERROR"
      if ($Retrycount -gt 20) {
        Write-Log -message "Domain join failed after 20 retrys" -level "ERROR"
        $Stoploop = $true
      } else {
        Write-Log -message "Could not join domain, retrying in 60 seconds..." -level "WARN"
        Start-Sleep -Seconds 60
        $Retrycount = $Retrycount + 1
      }
    }
  } While ($Stoploop -eq $false)
}

Start-Sleep -Seconds 5

Stop-Transcript
</powershell>
<persist>true</persist>
EOF
}

# Create EC2 Instance
resource "aws_instance" "windows-server-member" {
  count                  = var.windows_domain_member_count
  ami                    = data.aws_ami.windows-server.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  source_dest_check      = false
  key_name               = var.key_name
  user_data              = data.template_file.windows-member-userdata.rendered

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-windows-server-member"
    Environment = var.environment
  }
}

#resource "aws_network_interface" "windows-server-member-private" {
#  subnet_id       = aws_subnet.private-subnet.id
#  attachment {
#    device_index = 1
#    instance   = "${element(aws_instance.windows-server-member.*.id,count.index)}"
#  }
#  private_ips_count = 2
#  security_groups = [ aws_security_group.aws-windows-private-sg.id ]
#  count = "${var.windows_domain_member_count}"
#}
