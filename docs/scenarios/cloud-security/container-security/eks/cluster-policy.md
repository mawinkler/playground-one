# Scenario: Migrate a Policy to a Cluster Policy including Runtime Rulesets

## Prerequisites

- Playground One Network
- Playground One EKS EC2 Cluster
- Vision One Container Security

Verify, that you have `Enable Container Security` enabled in your configuration including the Vision One API Key etc. Additionally, ensure that you have set an already existing Policy with optional Runtime Ruleset(s) attached to it.

```sh
pgo --config
```

```sh
...
Section: Vision One
Please set/update your Vision One configuration
API Key [eyJ0eXAiOi...]: 
Region Name [us-east-1]: 
...
Enable Container Security? [true]: 
Container Security Policy Name [PlaygroundOne]: 
Container Security Enable Policy Operator? [true]: 
...
```

The already existing policy will be used as the base for the cluster policy.

Have an EKS cluster or create one by running

```sh
pgo --apply network
pgo --apply eks-ec2
```

## About Cluster Policies

Official documentation [here](https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-cluster-managed-policies).

With cluster-managed policies, you can define the Container Security policies and runtime rulesets as custom resources in a yaml file. These custom resources can be managed with version control and deployed to the cluster with the CI/CD or GitOps workflow with other Kubernetes manifest files.

Cluster-managed policies are defined in their source code as Container Security policy and ruleset custom resources and are read-only to users in the Trend Vision One console after being created.

> ***Note:*** Allow policy drift enables you to modify the policy rules for your cluster-managed policies, which could potentially lead to policy inconsistencies. This option can only be enabled in the Trend Vision One console and should primarily be used in situations when an immediate policy adjustment is required. Enable Allow policy drift in Cloud Security → Container Security → Container Inventory → Kubernetes → [cluster name].

Cluster-managed policies are not enabled by default. To enable this policy type, add the following to your overrides.yaml file:

```yaml
cloudOne:
  policyOperator:
    enabled: true
    clusterPolicyName: <name of your policy custom resource>
```

> ***Note:*** The Playground One EKS and Kind clusters already have this feature enabled.

Cluster Policies and Runtime Rulesets are `yaml` files which can easily be managed by `kubectl`.

A Cluster Policy looks like this:

```yaml
apiVersion: visionone.trendmicro.com/v1alpha1
kind: ClusterPolicy
metadata:
  name: trendmicro-cluster-policy
spec:
  xdrEnabled: true
  rules:
    # Pod properties
    - type: hostNetwork
      action: log
      mitigation: log
...
  # Exceptions
  exceptions:
    - type: imageName
      properties:
        operator: equals
        values:
          - sampleImage
      namespaces: # exclude to apply to all namespaces
        - sample-namespace
    - type: imageRegistry
      properties:
        operator: equals
        values:
          - 198890578717.dkr.ecr.us-east-1.amazonaws.com/sample-registry
```

Runtime Rulesets look similar:

```yaml
apiVersion: visionone.trendmicro.com/v1alpha1
kind: RuntimeRuleset
metadata:
  labels:
    app.kubernetes.io/name: init
    app.kubernetes.io/managed-by: kustomize
  name: trendmicro-ruleset-sample
spec:
  definition:
    labels:
      - key: "app"
        value: "nginx"
    rules:
      - ruleID: TM-00000001
        mitigation: log
      - ruleID: TM-00000002
        mitigation: log
...
```

## Migrate your Cluster to use a Cluster Policy

Playground One makes this step very easy since it does provide a migration tool for this.

> ***Note:*** If you're using the Playground One Container you need to install the Python venv package to use the tool. I will package this into `pgoc` in one of the future releases.
>
> ```sh
> sudo apt update
> sudo apt install python3.10-venv
> ```

Run:

```sh
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

Now run the migration tool:

```sh
v1cs-migrate-policy2cluster
```

Depending on your configured policy and/or rule sets you will get an output like this:

```sh
2024-11-27 11:30:03 INFO (MainThread) [<module>] Vision One Region: us-east-1
2024-11-27 11:30:03 INFO (MainThread) [<module>] Vision One API Key: eyJ0eXAiOi
2024-11-27 11:30:03 INFO (MainThread) [<module>] Container Security Policy: PlaygroundOne
2024-11-27 11:30:03 INFO (MainThread) [main] Vision One URL: https://api.xdr.trendmicro.com/v3.0/containerSecurity
2024-11-27 11:30:06 INFO (MainThread) [main] Container Security Policy ID: PlaygroundOne-2dx8agPhRF3ccgh7gEeyBXWKe2j
2024-11-27 11:30:08 INFO (MainThread) [migrate_cluster_policy] Migrating 30 rules
2024-11-27 11:30:08 INFO (MainThread) [migrate_cluster_policy] Migrating 0 exceptions
2024-11-27 11:30:08 INFO (MainThread) [main] Writing Cluster Policy output file clusterpolicy-playgroundone.yaml
2024-11-27 11:30:08 INFO (MainThread) [main] Applying Cluster Policy clusterpolicy-playgroundone.yaml
clusterpolicy.visionone.trendmicro.com/pgo-cluster-policy created
2024-11-27 11:30:09 INFO (MainThread) [main] Container Security Runtime Ruleset IDs: ['PlaygroundOne-2dx8hOqRoClJlu7Brte9sylRB7y']
2024-11-27 11:30:13 INFO (MainThread) [migrate_runtime_ruleset] Migrating 1 label(s) with 66 rule(s) for ruleset PlaygroundOne
2024-11-27 11:30:13 INFO (MainThread) [main] Writing Runtime Security Ruleset output file runtimeruleset-playgroundone.yaml
2024-11-27 11:30:13 INFO (MainThread) [main] Applying Runtime Security Ruleset clusterpolicy-playgroundone.yaml
runtimeruleset.visionone.trendmicro.com/playgroundone created```

The above created two `yaml` files:

```sh
-rw-r--r--  1 pgo pgo  1523 Nov 25 15:37 clusterpolicy-playgroundone.yaml
-rw-r--r--  1 pgo pgo  3429 Nov 25 15:37 runtimeruleset-playgroundone.yaml
```

The script has automatically applied the policy and runtime ruleset to the cluster.

If you now review the policy on the Vision One console you will see a new policy, which is read only but applied to your cluster.

🎉 Success 🎉
