resource "aws_ssm_document" "server-agent-linux" {
  name            = "TrendMicroServerAgentLinuxDeploy"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = <<DOC
schemaVersion: "2.2"
description: Deploy Trend Micro Server Agent on Linux
parameters:
  Package:
    type: "String"
    description: "DeploymentPackage"
    default: "TMServerAgent_Linux.tar"
mainSteps:
- action: "aws:runShellScript"
  name: "InstallServerAgent"
  inputs:
    workingDirectory: /tmp
    runCommand:
      - echo "Waiting for AWS CLI" >> /tmp/ssm-debug.log
      - |
        i=1
        while [ $i -le 60 ]; do
          aws s3 cp s3://${var.s3_bucket}/download/{{Package}} . && break
          echo "Retrying $i/60..." >> /tmp/ssm-debug.log
          i=$((i + 1))
          sleep 5
        done
      - echo "Extracting package" >> /tmp/ssm-debug.log
      - tar xf TMServerAgent_Linux.tar >> /tmp/ssm-debug.log 2>&1
      - echo "Running installer" >> /tmp/ssm-debug.log
      - sudo ./tmxbc install >> /tmp/ssm-debug.log 2>&1
DOC

  tags = {
    Name          = "${var.environment}-ssm-document"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

resource "aws_ssm_document" "server-agent-windows" {
  name            = "TrendMicroServerAgentWindowsDeploy"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = <<DOC
schemaVersion: "2.2"
description: Deploy Trend Micro Server Agent on Windows
parameters:
  Package:
    type: "String"
    description: "DeploymentPackage"
    default: "TMServerAgent_Windows.zip"
mainSteps:
- action: "aws:runPowerShellScript"
  name: "InstallServerAgent"
  inputs:
    workingDirectory: C:\Windows\Temp
    runCommand:
      - Write-Host "Copying package from S3"
      - Read-S3Object -BucketName ${var.s3_bucket} -Key download/{{Package}} -File {{Package}}
      - Write-Host "Extracting package"
      - Expand-Archive -LiteralPath {{Package}} -DestinationPath . -Force
      - Write-Host "Running installer"
      - Start-Process -FilePath EndpointBasecamp.exe -NoNewWindow
DOC

  tags = {
    Name          = "${var.environment}-ssm-document"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

resource "aws_ssm_document" "sensor-agent-linux" {
  name            = "TrendMicroSensorAgentLinuxDeploy"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = <<DOC
schemaVersion: "2.2"
description: Deploy Trend Micro Sensor Agent on Linux
parameters:
  Package:
    type: "String"
    description: "DeploymentPackage"
    default: "TMSensorAgent_Linux.tar"
mainSteps:
- action: "aws:runShellScript"
  name: "InstallSensorAgent"
  inputs:
    workingDirectory: /tmp
    runCommand:
      - echo "Waiting for AWS CLI" >> /tmp/ssm-debug.log
      - |
        i=1
        while [ $i -le 60 ]; do
          aws s3 cp s3://${var.s3_bucket}/download/{{Package}} . && break
          echo "Retrying $i/60..." >> /tmp/ssm-debug.log
          i=$((i + 1))
          sleep 5
        done
      - echo "Extracting package" >> /tmp/ssm-debug.log
      - tar xf TMSensorAgent_Linux.tar >> /tmp/ssm-debug.log 2>&1
      - echo "Running installer" >> /tmp/ssm-debug.log
      - sudo ./tmxbc install >> /tmp/ssm-debug.log 2>&1
DOC

  tags = {
    Name          = "${var.environment}-ssm-document"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}

resource "aws_ssm_document" "sensor-agent-windows" {
  name            = "TrendMicroSensorAgentWindowsDeploy"
  document_format = "YAML"
  document_type   = "Command"
  target_type     = "/AWS::EC2::Instance"

  content = <<DOC
schemaVersion: "2.2"
description: Deploy Trend Micro Sensor Agent on Windows
parameters:
  Package:
    type: "String"
    description: "DeploymentPackage"
    default: "TMSensorAgent_Windows.zip"
mainSteps:
- action: "aws:runPowerShellScript"
  name: "InstallSensorAgent"
  inputs:
    workingDirectory: C:\Windows\Temp
    runCommand:
      - Write-Host "Copying package from S3"
      - Read-S3Object -BucketName ${var.s3_bucket} -Key download/{{Package}} -File {{Package}}
      - Write-Host "Extracting package"
      - Expand-Archive -LiteralPath {{Package}} -DestinationPath . -Force
      - Write-Host "Running installer"
      - Start-Process -FilePath EndpointBasecamp.exe -NoNewWindow
DOC

  tags = {
    Name          = "${var.environment}-ssm-document"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "ec2"
  }
}
