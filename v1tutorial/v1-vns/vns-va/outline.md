Storyline

- Hello and welcome to this video.
- If you're using Terraform to orchestrate your AWS environment and would like to inspect the network traffic of your EC2 instances you may have heard from AWS VPC Traffic Mirroring.

[PAUSE A MOMENT]

- In this video I will briefly introduce you to AWS VPC Traffic Mirroring.
- Afterwards, I will guide you through the orchestration of the Virtual Network Sensor which is part Vision One Network Security by the use of Terraform.
- We will also learn about attaching EC2 instances ENIs to the Virtual Network Sensor in an automated way.

[PAUSE A MOMENT]

- Workflow
  - AWS VPC Traffic Mirroring
    - AWS VPC Traffic Mirroring is a feature that allows you to capture and inspect network traffic in your Amazon VPC (Virtual Private Cloud). It's especially useful for monitoring, threat detection, deep packet inspection (DPI), troubleshooting, and performance analysis.
    - What It Does
      - It mirrors (copies) the network traffic from Elastic Network Interfaces (ENIs) in your VPC and sends that mirrored traffic to another ENI where it can be processed by tools like Security appliances (IDS/IPS) and Packet analyzers.
    - The main components involved in VPC Traffic Mirroring are:
      - Traffic Mirror Source (ENI)
        - This is the network interface from which traffic is being mirrored.
        - Can be attached to EC2 instances, ENIs of AWS services, etc.
      - Traffic Mirror Target
        - The destination ENI where mirrored traffic is sent.
        - Usually attached to an instance running a traffic analysis tool.
        - Can be in the same VPC or a different VPC (via Transit Gateway).
      - Traffic Mirror Filter
        - Defines the rules to control what traffic is mirrored (e.g., TCP only, port 443, etc.).
        - Supports allow and deny rules based on protocol, port, CIDR, etc.
      - Traffic Mirror Session
        - The binding between the source, target, and filter.
  - Vision One Virtual Network Sensor
    - Virtual Network Sensor is a lightweight network sensor that scans your network activity and feeds network activity data to Trend Vision One and allows you to discover unmanaged assets and gain a holistic view of your attack surface.
    - The Virtual Network Sensor, in short VNS, can be deployed in
      - AWS,
      - Google Cloud projects, 
      - Microsoft Azure and Hyper-V,
      - KVM, 
      - Nutanix AHV, 
      - VMware ESXi and vCenter.
    - It supports the following protocols (slide)
      - For the 13 mentioned protocols we're analysing the the full packets including the payload / application layer
      - For the other protocols, VNS captures the Five-Touple (Source, Destination, Source- and Destination Ports, Protocol) to send the telemetry information to Vision One.
    - In an on-premise environment you typically connect the VNS to a switches mirror port. Doing so does allow to get the full traffic from all devices connected to this switch. The challenge in the Clouds is, that there are no mirror ports. In the next chapters I will demonstrate how to overcome this limitation with using Cloud Orchestration based on Terraform.
  - Terraform
    - Terraforming VNS Deployment
      - local.tf
      - sg.tf
      - ami.tf
      - vms_va.tf
    - Terraforming AWS VPC Traffic Mirroring
      - traffic.tf
      - linux_server.tf
    - Demo
      - Apply
      - Attack
      - Results
  - Summary
    - Hopefully I was able to demonstrate how easy the usage of VNS is in the clouds when using Terraform. As it

Controls:

Source ENI

Target ENI

Filter

Session number (for prioritization if multiple sessions exist)

Packet length (optional truncation)

- What do we want to do?
  - Show Vision One Console with connected VNS

If you have followed any tutorial that contained a package that was not part of Python’s standard library, you may have heard of pip.

[PAUSE A MOMENT]

pip is the funny sounding name for Python’s [EMPHASIZE] package manager.

That means it’s a tool that allows you to install and manage libraries and dependencies that aren’t distributed as part of the standard library.

Oh, and if you’re wondering what pip stands for, [SHOW NEXT SLIDE] it’s short for “pip installs packages”

And in this course, you’ll learn how that works.
