# Vision One Endpoint Security Server & Workload Protection

Three different instances are currently provided by the AWS One Playground with different configurations:

Instance Web1:

- Ubuntu Linux 20.04
- Nginx and Wordpress deployment
- Vision One Endpoint Security Basecamp agent for Server & Workload Protection

Instance Db1:

- Ubuntu Linux 20.04
- MySql databse
- Vision One Endpoint Security Basecamp agent for Server & Workload Protection

Instance Srv1:

- Windows Server 2022 Standalone Server
- Vision One Endpoint Security Basecamp agent for Server & Workload Protection

All instances are integrated with Vision One Endpoint Security for Server & Workload Protection and have access to the Attomic Launcher.

The instances are created within a public subnet of an automatically created VPC. They all get an EC2 instance role assigned providing them the ability to access installer packages stored within an S3 bucket.

All instances including the Windows Server are accessible via ssh and key authentication. RDP for Windows is supported as well.

## Optional: Drop Vision One Installer Packages

Next, you need to download the installer packages for Vision One Endpoint Security for Windows and Linux operating systems from your Vision One instance. You need to do this manually since these installers are specific to your environment. The downloaded files should be named `TMServerAgent_Linux_auto_64_Server_-_Workload_Protection_Manager.tar` respectively `TMServerAgent_Windows_auto_64_Server_-_Workload_Protection_Manager.zip` and are to be placed into the directory `$PGPATH/terraform-awsone/0-files`

Optionally, download the Atomic Launcher from [here](https://wiki.jarvis.trendmicro.com/display/GRTL/Atomic+Launcher#AtomicLauncher-DownloadAtomicLauncher) and store them in the  `$PGPATH/terraform-awsone/0-files` directory as well.

Your `$PGPATH/terraform-awsone/0-files`-directory should look like this:

```sh
-rw-rw-r-- 1 17912014 May 15 09:10 atomic_launcher_linux_1.0.0.1009.zip
-rw-rw-r-- 1 96135367 May 15 09:05 atomic_launcher_windows_1.0.0.1013.zip
-rw-rw-r-- 1        0 May 23 09:30 see_documentation
-rw-rw-r-- 1 27380224 Jul 11 07:39 TMServerAgent_Linux_auto_64_Server_-_Workload_Protection_Manager.tar
-rw-rw-r-- 1      130 Jul 17 10:12 TMServerAgent_Linux_deploy.sh
-rw-r--r-- 1  3303330 Jul  4 11:10 TMServerAgent_Windows_auto_64_Server_-_Workload_Protection_Manager.zip
-rw-rw-r-- 1     1102 Jul 14 14:06 TMServerAgent_Windows_deploy.ps1
```

## Optional: Server & Workload Protection Event-Based Tasks

Create Event-Based Tasks to automatically assign Linux or Windows server policies to the machines.

Agent-initiated Activation Linux

- *Actions:* Assign Policy: Linux Server
- *Conditions:* "Platform" matches ".\*Linux\*."

Agent-initiated Activation Windows

- *Actions:* Assign Policy: Windows Server
- *Conditions:* "Platform" matches ".\*Windows\*."

## Atomic Launcher

The Atomic Launcher is stored within the downloads folder of each of the instances.

The unzip password is `virus`.

You should disable Anti Malware protection und set the IPS module to detect only before using Atomic Launcher :-).
