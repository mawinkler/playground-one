# Bootstrapping PowerShell Script
data "template_file" "windows-ca-userdata" {
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

if ($domain -ne '${var.windows_ad_domain_name}'){
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

Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Write-Log -message "Certification Authority installed" -level "INFO"

Add-WindowsFeature Adcs-Web-Enrollment
Write-Log -message "Certification Authority Web Enrollment installed" -level "INFO"

Install-ADcsCertificationAuthority -Credential $credential -CAType EnterpriseRootCa -Force
Install-AdcsWebEnrollment -Credential $credential -Force
Write-Log -message "Certification Authority set as root CA" -level "INFO"

#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-Module -Name PSPKI -Force
#Get-CertificateTemplate -Name WebServer | Get-CertificateTemplate | Add-CertificateTemplateAcl -Identity "Authenticated Users" -AccessType Allow -AccessMask Read, Enroll | Set-CertificateTemplateAcl

Start-Sleep -Seconds 5

Stop-Transcript
</powershell>
<persist>true</persist>
EOF
}

# Create EC2 Instance
resource "aws_instance" "windows-server-ca" {
  ami                    = data.aws_ami.windows-server.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  source_dest_check      = false
  key_name               = var.key_name
  user_data              = data.template_file.windows-ca-userdata.rendered

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-windows-server-ca"
    Environment = var.environment
  }
}