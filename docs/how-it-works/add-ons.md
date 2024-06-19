# Playground One Add-Ons

There are currently two not Terraform related add-ons included in the Playground One.

- Cloud Security Posture Management

  - Located in the Playground One home directury as `cspm`.

  - The intention of this add-on is to provide a RESTful Api driven exception handling mechanism with Terraform template scanning support. The Python scripts included here implement the following functionality:

    - Create Terrafrom Plan of Configuration and run Conformity Template Scan
    - Set Exceptions in Scan Profile based on Name-Tags or unique Tags assigned to the resource
    - Create Terraform Apply of Configuration
    - Create Terraform Destroy of Configuration
    - Remove Exceptions in Scan Profile or reset the Scan Profile
    - Suppress Findings in Account Profile
    - Expire Findings in Account Profile
    - Run Conformity Bot and request status
    - Download latest Report

  - Consult the documentation within the Python scripts `scanner_c1_uuid.py` and/or `scanner_c1_name.py` on how to play with this.

- Container Stacks for Third-Party integrations.

  - Located in the Playground One home directury as `stacks`.

  - Splunk - Spins up a local Splunk which can be used individually or in conjunction with some scenarios of Playground One. These are

    - [Setup Splunk](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/splunk-setup/)
    - [Integrate Vision One with Splunk](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/splunk-integrate-vision-one-xdr/)
    - [Integrate V1CS Customer Runtime Security Rules with Splunk](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/splunk-integrate-vision-one-custom-rules/)
    - ![alt text](images/splunk-app-v1xdr-09.png "Splunk")

  - Elastic - Creates a local ELK stack to play with.

    - [Setup Elastic (ELK Stack)](https://mawinkler.github.io/playground-one-pages/scenarios/bigdata/elastic-stack/)
    - ![alt text](images/elastic-app-setup-02.png "App")

