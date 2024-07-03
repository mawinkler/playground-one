# Scenario: CloudFormation IaC Scanning as GitHub Action

!!! danger "Warning!"

    This scenario does use Cloud One Conformity!

## Prerequisites

- Clouud One API-Key with the following permissions:
    - Conformity
        - PowerUser
- GitHub Account.
- Forked [playground-one-template-scanner](https://github.com/mawinkler/playground-one-template-scanner).

## About GitHub Actions

GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline on GitHub.

GitHub Actions goes beyond just DevOps and lets you run workflows when other events happen in your repository. For example, you can run a workflow to automatically add the appropriate labels whenever someone creates a new issue in your repository.

You can configure a GitHub Actions workflow to be triggered when an event occurs in your repository, such as a pull request being opened, an issue being created or a push happened. Your workflow contains one or more jobs which can run in sequential order or in parallel. Each job will run inside its own virtual machine runner, or inside a container, and has one or more steps that either run a script that you define or run an action, which is a reusable extension that can simplify your workflow.

Workflows are defined as YAML files in the .github/workflows directory in a repository, and a repository can have multiple workflows, each of which can perform a different set of tasks.

In this scenario we're going to create a workflow to automatically build, push and scan a container image with Trend Micro Artifact Scanning. The scan will check the image for vulnerabilities and malware and eventually push it to the registry.

The logic implemented in this Action template is as follows:

- Prepare the Docker Buildx environment.
- Build the image and save it as a tar ball.
- Scan the built image for vulnerabilities and malware using Vision One Container Security.
- Upload Scan Result and SBOM Artifact if available. Artifacts allow you to share data between jobs in a workflow and store data once that workflow has completed, in this case saving the scan result and the container image SBOM as an artifact allow you to have proof on what happened on past scans.
- Optionally fail the workflow if malware and/or the vulnerability threshold was reached. Failing the workflow at this stage prevents the registry to get polluted with insecure images.
- Authenticate to the deployment registry.
- Rebuild the image from cache for the desired architectures.
- Push the image to the registry.
- Rescan the image in the registry to allow proper admission control integration.

## Fork the Scenario Repo

The first step is to fork the scenarios GitHub repo. For this go to [github.com](https://github.com/) and sign in or create a free account if you need to.

Next, you want to create a Fork of the scenarios repo. A fork is basically a copy of a repository. Forking a repository allows you to freely experiment with changes without affecting the original project.

To do this navigate to the repo [playground-one-template-scanner](https://github.com/mawinkler/playground-one-template-scanner) and click on the `Fork`-button in the upper right.

On the next screen you change the name to something shorter like `action`. Then press `[Create fork]` which will bring you back to your account.

## The Repo

The repo containes a hidden directory `.github/workflows` with some `yaml`-files, a `cfn` and an `infra`-directory.

The `cfn` holds an example CloudFormation template for the scan, whereby the `infra` directory contains some Terraform modules which would create a VPC, subnets, security groups, etc.

### The Workflow

In the following section we'll review the different GitHub Actions for CloudFormation scanning of this repo.

Let's go through it.

```yaml
name: CloudFormation Scan

# A push --tags on the repo triggers the workflow
on:
  push:
    tags: [ v* ]

env:
  # Conformity API Key
  CLOUD_ONE_API_KEY: ${{ secrets.API_KEY }}

  # Region in which Cloud Conformity serves your organisation
  CLOUD_ONE_REGION: eu-central-1

  # Scan result threshold (fail on risk-level or higher)
  # THRESHOLD: any
  # THRESHOLD: critical
  THRESHOLD: high
  # THRESHOLD: medium
  # THRESHOLD: low

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      # Prepare and authenticate to AWS using the given credentials
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
          
      # CloudFormation scan
      - name: CloudFormation Scan
        run: |
          contents=$(cat cfn/template.json | jq '.' -MRs)
          payload="{\"data\":{\"attributes\":{\"type\":\"cloudformation-template\",\"contents\":${contents}}}}"
          printf '%s' ${payload} > data.txt

          # # Scan template
          curl -s -X POST \
              -H "Authorization: ApiKey ${CLOUD_ONE_API_KEY}" \
              -H "Content-Type: application/vnd.api+json" \
              https://${CLOUD_ONE_REGION}-api.cloudconformity.com/v1/template-scanner/scan \
              -d @data.txt > result.json

          # Extract findings risk-level
          risk_levels=$(cat result.json | jq -r '.data[] | select(.attributes.status == "FAILURE") | .attributes."risk-level"')

          fail=0
          [ "${THRESHOLD}" = "any" ] && \
            [ ! -z "${risk_levels}" ] && fail=1

          [ "${THRESHOLD}" = "critical" ] && \
            [[ ${risk_levels} == *CRITICAL* ]] && fail=2

          [ "${THRESHOLD}" = "high" ] && \
            ([[ ${risk_levels} == *CRITICAL* ]] || [[ ${risk_levels} == *HIGH* ]]) && fail=3

          [ "${THRESHOLD}" = "medium" ] && \
            ([[ ${risk_levels} == *CRITICAL* ]] || [[ ${risk_levels} == *HIGH* ]] || [[ ${risk_levels} == *MEDIUM* ]]) && fail=4

          [ "${THRESHOLD}" = "low" ] && \
            ([[ ${risk_levels} == *CRITICAL* ]] || [[ ${risk_levels} == *HIGH* ]] || [[ ${risk_levels} == *MEDIUM* ]] || [[ ${risk_levels} == *LOW* ]]) && fail=5

          [ $fail -ne 0 ] && echo !!! Threshold exceeded !!! > exceeded || true
          rm -f data.txt

      # Upload Scan Result if available
      - name: Upload Scan Result Artifact
        uses: actions/upload-artifact@v3
        with:
          name: scan-result
          path: result.json
          retention-days: 30

      # Fail the workflow if theshold reached
      - name: Fail Scan
        run: |
          ls -l
          if [ -f "exceeded" ]; then exit 1; fi
```

### Secrets

For simplicity, authentication to AWS is done via access and secret access key. Alternative and likely better variants are described [here](https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions).

The workflow requires a secret to be set. For that navigate to `Settings --> Security --> Secrets and variables --> Actions --> Secrets`.

Add the following secrets:

- API_KEY: `<Your Cloud One API Key>`
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

### Template

Adapt the environment variables in the `env:`-section as required.

Variable          | Purpose
----------------- | -------
`CLOUD_ONE_REGION`| Cloud One Region of choice (e.g. eu-central-1, us-west-2, etc.).
`THRESHOLD`       | Defines the fail condition of the action in relation to discovered vulnerabilities. A threshold of `critical` does allow any number of vulnerabilities up to the criticality `high`. 

Allowed values for the `THRESHOLD` are:

- `any`: No vulnerabilities allowed.
- `critical`: Max risk-level of discovered findings is `high`.
- `high`: Max risk-level of discovered findings is `medium`.
- `medium`: Max risk-level of discovered findings is `low`.
- `low`: Max risk-level of discovered findings is `negligible`.

If the `THRESHOLD` is not set, vulnerabilities will not fail the pipeline.

The workflow will trigger on `git push --tags`.

### Actions

Navigate to `Actions` and enable Workflows for the forked repository.

## Test it

### Create a Tag

To trigger the action we simply create a tag.

Navigate to `Releases` on the right and then click on `[Draft a new release]`.

Next, click on `[Choose a tag]` and type `v0.1`. A new button called `[Create new tag]` should get visible. Click on it.

Leave the rest as it is and finally click on the green button `[Publish release]`. This will trigger the action workflow.

> ***CLI:*** `git tag v0.1 && git push --tags`

### Check the Action

Now, navigate to the tab `Actions` and review the actions output. Click on `CloudFormation Scan`.

You should now see three main sections:

1. `cloudformation-template-scan-shell.yaml`: Clicking on `docker` reveals the output of the steps from the workflow (and where it failed).
2. Annotations: Telling you in this case that the process completed with exit code 1.
3. Artifacts: These are the artifacts created by the action. There should be a `scan-result`.

Feel free to review the scan results to find out why the action did fail.

🎉 Success 🎉
