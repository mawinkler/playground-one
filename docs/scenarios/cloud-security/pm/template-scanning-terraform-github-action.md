# Scenario: Terraform IaC Scanning as GitHub Action

## Prerequisites

- Vision One API-Key with the following permissions:
    - Cloud Posture
        - View
- GitHub Account.
- Forked [playground-one-template-scanner](https://github.com/mawinkler/playground-one-template-scanner).

## About GitHub Actions

GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline on GitHub.

GitHub Actions goes beyond just DevOps and lets you run workflows when other events happen in your repository. For example, you can run a workflow to automatically add the appropriate labels whenever someone creates a new issue in your repository.

You can configure a GitHub Actions workflow to be triggered when an event occurs in your repository, such as a pull request being opened, an issue being created or a push happened. Your workflow contains one or more jobs which can run in sequential order or in parallel. Each job will run inside its own virtual machine runner, or inside a container, and has one or more steps that either run a script that you define or run an action, which is a reusable extension that can simplify your workflow.

Workflows are defined as YAML files in the .github/workflows directory in a repository, and a repository can have multiple workflows, each of which can perform a different set of tasks.

In this scenario we're going to create a workflow to automatically scan a Terraform configuration with Vision One Cloud Posture Template Scanning. The scan will check the configuration for misconfigurations.

The logic implemented in this Action template is as follows:

- Prepare the Terraform environment.
- Compute a plan for the Terraform configuration.
- Use the template scanner to scan for misconfigurations.
- Upload scan artifacts.
- Eventually fail the action if the findings threshold has been exceeded.

## Fork the Scenario Repo

The first step is to fork the scenarios GitHub repo. For this go to [github.com](https://github.com/) and sign in or create a free account if you need to.

Next, you want to create a Fork of the scenarios repo. A fork is basically a copy of a repository. Forking a repository allows you to freely experiment with changes without affecting the original project.

To do this navigate to the repo [playground-one-template-scanner](https://github.com/mawinkler/playground-one-template-scanner) and click on the `Fork`-button in the upper right.

On the next screen you change the name to something shorter like `action`. Then press `[Create fork]` which will bring you back to your account.

## The Repo

The repo containes a hidden directory `.github/workflows` with some `yaml`-files, a `cfn` and an `infra`-directory.

The `cfn` holds an example CloudFormation template for the scan, whereby the `infra` directory contains some Terraform modules which would create a VPC, subnets, security groups, etc.

### The Workflows

In the following section we'll review the different GitHub Actions of this repo.

#### Terraform Scan using Shell

The `terraform-template-scan-shell.yaml`-file in `.github/workflows` will run a scan on the provided Terraform infrastructure.

Important to understand is, that the scan will actually scan the Terraform plan which is effectively the execution plan Terraform would do when the configuration would be applied. It therefore requires valid authentication credentials to the cloud and will only contain the actions to match the desired state as defined in the configuration.

By default, when Terraform creates a plan it:

- Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
- Compares the current configuration to the prior state and noting any differences.
- Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

The plan command alone does not actually carry out the proposed changes, but the plan is what is scanned by Conformity.

Let's go through it.

```yaml
name: Terraform Scan Shell

# A push --tags on the repo triggers the workflow
on:
  push:
    tags: [ v* ]

env:
  # Vision One API Key
  API_KEY: ${{ secrets.API_KEY }}

  # Region in which Vision One serves your organisation
  REGION: ""  # Examples: "eu." "sg." Leave blank if running in us.

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
          
      # Install Terraform
      - name: Terraform Install
        run: |
          wget -O- https://apt.releases.hashicorp.com/gpg | \
            gpg --dearmor | \
            sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
          echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
            https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/hashicorp.list
          sudo apt-get update
          sudo apt-get install -y terraform

      # Terraform plan
      - name: Terraform Plan
        run: |
          # IaC code in
          iac=infra

          # Create template
          cd ${iac}
          terraform init
          terraform plan -var="account_id=${{ secrets.AWS_ACCOUNT_ID }}" -var="aws_region=${{ secrets.AWS_REGION }}" -out=plan.out
          terraform show -json plan.out > ../plan.json
          rm -f plan.out
          cd ..

      # Terraform scan
      - name: Terraform Scan
        run: |
          # Create scan payload
          contents=$(cat plan.json | jq '.' -MRs)
          payload="{\"type\":\"terraform-template\",\"content\":${contents}}"
          printf '%s' ${payload} > data.txt

          # Scan template
          curl -s -X POST \
              -H "Authorization: Bearer ${API_KEY}" \
              -H "Content-Type: application/json;charset=utf-8" \
              https://api.${REGION}xdr.trendmicro.com/beta/cloudPosture/scanTemplate \
              -d @data.txt > result.json

          # Extract findings risk-level
          risk_levels=$(cat result.json | jq -r '.scanResults[] | select(.status == "FAILURE") | .riskLevel')

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
          # rm -f data.txt plan.json

      # Upload Scan Result if available
      - name: Upload Scan Result Artifact
        uses: actions/upload-artifact@v4
        with:
          name: scan-result
          path: result.json
          retention-days: 30

      - name: Upload Scan Result Artifact
        uses: actions/upload-artifact@v4
        with:
          name: data
          path: data.txt
          retention-days: 30
          
      # Fail the workflow if theshold reached
      - name: Fail Scan
        run: |
          ls -l
          if [ -f "exceeded" ]; then exit 1; fi
```

#### Terraform Scan using Terraform plan action

This workflow is a variant of the above, simplifying the Terraform install and plan steps. All the rest is identical.

```yaml
...
jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
...
      # Terraform plan
      - name: Terraform Plan
        id: terraform_plan
        uses: dflook/terraform-plan@v1
        with:
          path: infra
          variables: |
            account_id="${{ secrets.AWS_ACCOUNT_ID }}"
            aws_region="${{ secrets.AWS_REGION }}"

      # Terraform scan
      - name: Terraform Scan
        run: |
          # Create scan payload
          contents=$(cat ${{ steps.terraform_plan.outputs.json_plan_path }} | jq '.' -MRs)
          payload="{\"type\":\"terraform-template\",\"content\":${contents}}"
          printf '%s' ${payload} > data.txt
...
```

The `Terraform Plan` step replaces the install and plan steps by using the plan action from [Daniel Flook](https://github.com/dflook/terraform-github-actions/tree/main/terraform-plan).

### Secrets

For simplicity, authentication to AWS is done via access and secret access key. Alternative and likely better variants are described [here](https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions).

The workflow requires a secret to be set. For that navigate to `Settings --> Security --> Secrets and variables --> Actions --> Secrets`.

Add the following secrets:

- API_KEY: `<Your Cloud One API Key>`
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

The included terraform configuration requires additionally:

- AWS_REGION
- AWS_ACCOUNT_ID

### Template

Adapt the environment variables in the `env:`-section as required.

Variable          | Purpose
----------------- | -------
`REGION`          | Vision One Region of choice (e.g. "eu." "sg." Leave blank if running in us).
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

Now, navigate to the tab `Actions` and review the actions output. Click on `Terraform Scan Shell` or `Terraform Scan TfAction`.

You should now see three main sections:

1. `terraform-template-scan-shell.yaml` or `terraform-template-scan-tfaction.yaml`: Clicking on `docker` reveals the output of the steps from the workflow (and where it failed).
2. Annotations: Telling you in this case that the process completed with exit code 1.
3. Artifacts: These are the artifacts created by the action. There should be a `scan-result`.

Feel free to review the scan results to find out why the action did fail.

🎉 Success 🎉
