# Playground One

Ultra fast and slim playground.

## Latest News

!!! ***Playground prepares for Vision One*** !!!

In a nutshell:

- Bootstrapping directly from the clouds. It will attempt to upgrade already installed tools to the latest available version.  

  ```sh
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/master/bin/pgo | bash && exit
  ```

- Management of the environment with the help of an easy to use command line interface `pgo`.
## Change Log

07/07/2023

- Initial release

## Currently Work in Progress

- Preparing the sub project `terraform-awsone` to integrate with V1ES for Server & Workload Protection (Windows & Linux)
- Enable ALB for Bottlerocket and Fargate cluster

## Requirements and Support Matrix

The Playground One is designed to work with AWS and is tested these operating systems

- Ubuntu Bionic and newer
- Cloud9 with Ubuntu


## CLI Commands of the Playground

Besides the obvious cli tools like `kubectl`, `docker`, etc. the Playground offers you additional commands shown in the table below (and more):

Command | Function
------- | --------
pgo | The command line interface for Playground One
stern | Tail logs from multiple pods simultaneously
syft | See [github.com/anchore/syft](https://github.com/anchore/syft)
grype | See [github.com/anchore/grype](https://github.com/anchore/grype)
k9s | See [k9scli.io](https://k9scli.io/)
