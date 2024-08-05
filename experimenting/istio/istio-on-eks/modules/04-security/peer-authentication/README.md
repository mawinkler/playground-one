# Security - Peer Authentication

This sub-module focuses on enforcing mutual TLS with Istio using AWS Private CA for **Peer Authentication** on Amazon EKS. Before we go into Istio configuration and validation, we will start with certificate management.

## Peer Authentication Certificate Management

Istio certificate management is achieved through [`cert-manager`](https://cert-manager.io/) integrations.

The below projects are used to integrate Istio with AWS Private CA:

  * [`aws-privateca-issuer`](https://github.com/cert-manager/aws-privateca-issuer/tree/main) - addon for cert-manager that issues certificates using AWS ACM PCA
  * [`istio-csr`](https://github.com/cert-manager/istio-csr) - an agent that allows for Istio workload and control plane components to be secured using cert-manager

It is recommended to install all the dependencies for certificate management like `cert-manager`, `aws-privateca-issuer` and `istio-csr` before installing Istio control plane to avoid issues with CA migration. Refer to [Installing istio-csr After Istio](https://cert-manager.io/docs/usage/istio-csr/#installing-istio-csr-after-istio) for more details.


### AWS Private CA

The peer authentication section uses AWS Private CA in short-lived mode to issue certificates to the mesh workloads for mutual TLS. Refer [Short-Lived CA Mode for Mutual TLS Between Workloads](https://aws.github.io/aws-eks-best-practices/security/docs/network/#short-lived-ca-mode-for-mutual-tls-between-workloads).

Note that your account is charged a monthly price for each private CA starting from the time that you create it. You are also charged for each certificate that is issued by the Private CA. Refer to [AWS Private CA Pricing](https://aws.amazon.com/private-ca/pricing/) for more details.

### Istio Mutual TLS Certificate Workflow

#### Default Behavior

By default, Istio creates its own CA to issue control plane and workload certificates that identify workload proxies. When a workload starts its envoy proxy requests a certificate from the istio control plane via `istio-agent`.

![Default certificate signing workflow in Istio](https://aws.github.io/aws-eks-best-practices/security/docs/images/default-istio-csr-flow.png)

*Figure: [How Certificate Signing Works in Istio (Default)](https://aws.github.io/aws-eks-best-practices/security/docs/network/#how-certificate-signing-works-in-istio-default)*

#### Integrated with AWS PCA

For this module the default Istio CA is disabled. The control plane and the proxy agents are configured to forward all certificate requests to `istio-csr`. `istio-csr` in turn forwards the request to `cert-manager` to issue the certificates from AWS Private CA via `aws-privateca-issuer`.

![How Certificate Signing Works in Istio with ACM Private CA](https://aws.github.io/aws-eks-best-practices/security/docs/images/istio-csr-with-acm-private-ca.png)

*Figure: [How Certificate Signing Works in Istio with ACM Private CA](https://aws.github.io/aws-eks-best-practices/security/docs/network/#how-certificate-signing-works-in-istio-with-acm-private-ca)*

## Validate Environment Setup

## Prerequisites

**Note:** Make sure that the required resources have been created following the [setup instructions](../README.md#setup).

**:warning: WARN:** Some of the commands shown in this section refer to relative file paths that assume the current directory is `istio-on-eks/modules/04-security/terraform`. If your current directory does not match this path, then either change to the above directory to execute the commands or if executing from any other directory, then adjust the file paths like `../scripts/helpers.sh` and `../lb_ingress_cert.pem` accordingly.

**Verify that all pods are running:**

```bash
kubectl get pods -n cert-manager
kubectl get pods -n aws-privateca-issuer
kubectl get pods -n istio-system
kubectl get pods -n istio-ingress
```

Make sure that the output shows all pods are in `Running` status.

```
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d988558d6-tgwrc              1/1     Running   0          3m32s
cert-manager-cainjector-6976895488-m5sht   1/1     Running   0          3m32s
cert-manager-csi-driver-76jtg              3/3     Running   0          3m
cert-manager-csi-driver-zx68p              3/3     Running   0          3m
cert-manager-istio-csr-f87db45fb-78czj     1/1     Running   0          2m39s
cert-manager-webhook-fcf48cc54-g7d5t       1/1     Running   0          3m32s
NAME                                   READY   STATUS    RESTARTS   AGE
aws-privateca-issuer-776554d88-72jjq   1/1     Running   0          3m55s
NAME                         READY   STATUS    RESTARTS   AGE
grafana-b8bbdc84d-46hvm      1/1     Running   0          50s
istiod-84d6bb5f7d-krkgp      1/1     Running   0          97s
jaeger-7d7d59b9d-k95f5       1/1     Running   0          60s
kiali-545878ddbb-ptsdn       1/1     Running   0          62s
prometheus-db8b4588f-d6g98   2/2     Running   0          54s
NAME                             READY   STATUS    RESTARTS   AGE
istio-ingress-845d676c6b-rsh8c   1/1     Running   0          83s
```

**Verify that AWS PrivateCA Issuer named `root-ca` is `Ready`**

```bash
kubectl get awspcaclusterissuer/root-ca \
  -o custom-columns='NAME:.metadata.name,CONDITION_MSG:.status.conditions[*].message,CONDITION_REASON:.status.conditions[*].reason,CONDITION_STATUS:.status.conditions[*].status,CONDITION_TYPE:.status.conditions[*].type'
```

The output should look similar to below sample output.

```
NAME      CONDITION_MSG     CONDITION_REASON   CONDITION_STATUS   CONDITION_TYPE
root-ca   Issuer verified   Verified           True               Ready
```

**Verify that the intermediate CA certificate issuer `istio-ca`, CA certificate `istio-ca` and `istiod` certificate are all created and all report `READY=True`:**

```bash
kubectl get issuers,certificates -n istio-system
```

The output should be similar to the below sample output.

```
NAME                              READY   AGE
issuer.cert-manager.io/istio-ca   True    4m36s

NAME                                   READY   SECRET       AGE
certificate.cert-manager.io/istio-ca   True    istio-ca     4m36s
certificate.cert-manager.io/istiod     True    istiod-tls   4m19s
```

**Verify that a secret containing the intermediate CA certificate named `istio-ca` has been created and chains up to the root CA certificate from AWS Private CA.**

```bash
kubectl get secret/istio-ca -n istio-system -o jsonpath='{.data.tls\.crt}' \
  | base64 -d \
  | openssl x509 -text -noout
```

Output should be similar to below.

```
Certificate:
    Data:
        ...
        Signature Algorithm: sha512WithRSAEncryption
        Issuer: CN = istio-on-eks-04-security
        Validity
            Not Before: Apr 22 09:18:48 2024 GMT
            Not After : Apr 29 10:18:47 2024 GMT
        Subject: O = cert-manager, CN = istio-ca
        ...
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            ...
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
    Signature Algorithm: sha512WithRSAEncryption
    ...
```

In the output, note that the certificate is a CA certificate and the Organization (`O`) shows as `cert-manager` and common name (`CN`) shows as `istio-ca`. This will be validated later when inspecting the workload certificates. The issuer `CN` should match the AWS PrivateCA certificate CN value.

**Setup environment variables to inspect the workload TLS settings**

```bash
export NAMESPACE=workshop
export APP=frontend
```

**Get logs for cert-manager**

In a separate terminal window follow the `cert-manager` logs for certificate requests being approved and issued by `cert-manager`. The below command follows the log since the previous two minutes.

```bash
kubectl logs -n cert-manager $(kubectl get pods -n cert-manager -o jsonpath='{.items..metadata.name}' --selector app=cert-manager) --since 2m -f
```

**Get certificate requests**

In another separate terminal window start a watch on the certificate requests being generated in the `istio-system` namespace by running the below command.

```bash
kubectl get certificaterequests.cert-manager.io -n istio-system -w
```

**Enable proxy debug logs** 

Now in the original terminal window where you have created the environment variables patch the frontend deployment to enable proxy debug logs.

```bash
kubectl patch deployment/$APP -n $NAMESPACE --type=merge --patch='{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/logLevel":"debug"}}}}}'
```

In a few seconds you should see events similar to the output here for `certificaterequests` as the application pod is materialized.

```
NAME         APPROVED   DENIED   READY   ISSUER     REQUESTOR                                         AGE
istio-ca-1   True                True    root-ca    system:serviceaccount:cert-manager:cert-manager   71m
istiod-3     True                True    istio-ca   system:serviceaccount:cert-manager:cert-manager   11m
istio-csr-pld72                               istio-ca   system:serviceaccount:cert-manager:cert-manager-istio-csr   0s
istio-csr-pld72   True                        istio-ca   system:serviceaccount:cert-manager:cert-manager-istio-csr   0s
istio-csr-pld72   True                True    istio-ca   system:serviceaccount:cert-manager:cert-manager-istio-csr   0s
istio-csr-pld72   True                True    istio-ca   system:serviceaccount:cert-manager:cert-manager-istio-csr   0s
```

The key events are related to the certificate request named `istio-csr-pld72` corresponding to the `frontend` pod in the example output.

The `cert-manager` log output should show two log lines for each request being "Approved" and "Ready":

```
I0422 11:32:12.017941       1 conditions.go:263] Setting lastTransitionTime for CertificateRequest "istio-csr-pld72" condition "Approved" to 2024-04-22 11:32:12.017929879 +0000 UTC m=+4483.188998549
I0422 11:32:12.062274       1 conditions.go:263] Setting lastTransitionTime for CertificateRequest "istio-csr-pld72" condition "Ready" to 2024-04-22 11:32:12.062263818 +0000 UTC m=+4483.233332478
```

**Verify that all workload pods are running** 

All worloads should be running with both the application and sidecar containers reporting ready to serve requests. Wait until all terminating pods are cleaned up.

```bash
kubectl get pods -n $NAMESPACE
```

**Check container logs**

To validate that the `istio-proxy` sidecar container has requested the certificate from the correct service, check the container logs:

```bash
kubectl logs $(kubectl get pod -n $NAMESPACE -o jsonpath="{.items...metadata.name}" --selector app=$APP) -c istio-proxy -n $NAMESPACE | grep 'cert-manager-istio-csr.cert-manager.svc:443'
```

There should be matching log lines similar to the sample output below.

```
2024-04-17T17:10:47.792253Z     info    CA Endpoint cert-manager-istio-csr.cert-manager.svc:443, provider Citadel
2024-04-17T17:10:47.792274Z     info    Using CA cert-manager-istio-csr.cert-manager.svc:443 cert with certs: var/run/secrets/istio/root-cert.pem
```

**Inspect certificate**
Finally, inspect the certificate being used in memory by Envoy. Verify that the certificate chain of the in-memory certificate used by Envoy proxy shows the Issuer Organization (`O`) as `cert-manager` and common name (`CN`) as `istio-ca`. The Issuer should match the intermediate CA verified earlier.

```bash
istioctl proxy-config secret $(kubectl get pods -n $NAMESPACE -o jsonpath='{.items..metadata.name}' --selector app=$APP) -n $NAMESPACE -o json \
  | jq -r '.dynamicActiveSecrets[0].secret.tlsCertificate.certificateChain.inlineBytes' \
  | base64 --decode \
  | openssl x509 -text -noout
```

The output should be similar to below snippet.

```
Certificate:
    Data:
        ...
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: O = cert-manager, CN = istio-ca
        ...
        X509v3 extensions:
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            ...
            X509v3 Subject Alternative Name: 
                URI:spiffe://cluster.local/ns/workshop/sa/frontend-sa
    Signature Algorithm: sha256WithRSAEncryption
    ...
```

## Mutual TLS Enforcement Modes in Istio

Now that certificate management is configured properly, we can move on to the Istio configuration.  This section will demonstrate the steps needed to validate and enforce Mutual Transport Layer Security (mTLS) for peer authentication between workloads.

### Change default Istio Permissive configuration to Strict

By default, Istio will use mTLS for all workloads with proxies configured, however it will also allow plain text.  When the `X-Forwarded-Client-Cert` header is present in the request, Istio will use mTLS, and when it is missing, it implies that the requests are in plain text.

![Sidecar mTLS connections](/images/04-peer-authentication-mtls-sidecar-connections.png)

**Verify if mTLS is in Permissive mode**

(uses mTLS when available but allows plain text) or Strict mode (mTLS required). Note the value for "Workload mTLS mode" should show `PERMISSIVE`.

```bash
istioctl x describe pod $(kubectl get pods -n $NAMESPACE -o jsonpath='{.items..metadata.name}' --selector app=$APP).workshop
```

The output should look similar to the below sample output.

```
Pod: frontend-78f696695b-6txvg.workshop
   Pod Revision: default
   Pod Ports: 9000 (frontend), 15090 (istio-proxy)
--------------------
Service: frontend.workshop
   Port: http 9000/HTTP targets pod port 9000
VirtualService: frontend.workshop
   Match: /*
--------------------
Effective PeerAuthentication:
   Workload mTLS mode: PERMISSIVE
Skipping Gateway information (no ingress gateway pods)
```

In a separate terminal window open the Kiali dashboard.

```bash
istioctl dashboard kiali
```

**Verify mTLS status in Kiali by checking the tooltip for the lock icon in the masthead.**

![Kiali mast head lock tooltip for mesh wide auto mTLS](/images/04-kiali-mast-head-lock-auto-mtls.png)


If we want to force mTLS for all traffic, then we must enable STRICT mode.  Run the following command to force mTLS everywhere Istio is running.

```bash
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: "default"
  namespace: "istio-system"
spec:
  mtls:
    mode: STRICT
EOF
```

**Verify that the workload mTLS mode shows `STRICT`**

```bash
istioctl x describe pod $(kubectl get pods -n $NAMESPACE -o jsonpath='{.items..metadata.name}' --selector app=$APP).workshop
```

The output should look similar to the below sample output.

```
Pod: frontend-78f696695b-6txvg.workshop
   Pod Revision: default
   Pod Ports: 9000 (frontend), 15090 (istio-proxy)
--------------------
Service: frontend.workshop
   Port: http 9000/HTTP targets pod port 9000
VirtualService: frontend.workshop
   Match: /*
--------------------
Effective PeerAuthentication:
   Workload mTLS mode: STRICT
Applied PeerAuthentication:
   default.istio-system
Skipping Gateway information (no ingress gateway pods)
```

You can also check this by hovering your mouse over the Lock icon in the Kiali banner, which should now look like this:

![Kiali mast head lock tooltip for mesh wide strict mTLS](/images/04-kiali-mast-head-lock-default-strict-mode.png)


### Verify that mTLS is now required

Next, run `curl` command from another pod to test and verify that mTLS is enabled.

First find the specific service to test, in this case, `frontend`.

```bash
kubectl get svc/$APP -n $NAMESPACE
```

The output should look similar to below sample output. Note the service cluster IP in the output.

```
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
frontend   ClusterIP   172.20.207.162   <none>        9000/TCP   27m
```

**Failure case of mTLS connectivity**
Now run a pod with `curl` to try and reach the `frontend` service from a new and untrusted container.

```bash
kubectl run -i --tty curler --image=public.ecr.aws/k8m1l3p1/alpine/curler:latest --rm
```

Send a request to port `9000`, which should get rejected as we don't have the proper certificate to authenticate to mTLS.

```bash
curl -v frontend.workshop.svc.cluster.local:9000
```

The output should be similar to the sample output below.

```
*   Trying 172.20.207.162:9000...
* Connected to frontend.workshop.svc.cluster.local (172.20.207.162) port 9000 (#0)
> GET / HTTP/1.1
> Host: frontend.workshop.svc.cluster.local:9000
> User-Agent: curl/7.77.0
> Accept: */*
> 
* Recv failure: Connection reset by peer
* Closing connection 0
curl: (56) Recv failure: Connection reset by peer
```

Note that the resolved IP address should match the cluster IP of the `frontend` service inspected earlier.

Exit out of the container shell session.

**Success case of mTLS connectivity**
Now let's run a curl command from the frontend pod's istio-proxy directly to itself on port 9000. Because the certificate is in place and trusted, mTLS connectivity is possible, and we should see a success message:

```$ kubectl exec $(kubectl get pod -l app=$APP -n $NAMESPACE -o jsonpath='{.items..metadata.name}') -n $NAMESPACE -c istio-proxy -- curl localhost:9000/ -s -o /dev/null -w "HTTP Response: %{http_code}\n"```

```
HTTP Response: 200
```

Next, search the proxy debug log to verify that tls mode (`socket tlsMode-istio`) has been selected for proxy connections to the workload pods.

```bash
kubectl logs $(kubectl get pods -n $NAMESPACE -o jsonpath='{.items..metadata.name}' --selector app=$APP) -n workshop -c istio-proxy \
  | grep 'tlsMode.*:[359]000'
```

There should be matches similar to below snippet.

```
2024-04-17T17:38:00.214249Z     debug   envoy upstream external/envoy/source/common/upstream/upstream_impl.cc:426       transport socket match, socket tlsMode-istio selected for host with address 10.0.8.17:3000      thread=15
2024-04-17T17:38:00.214285Z     debug   envoy upstream external/envoy/source/common/upstream/upstream_impl.cc:426       transport socket match, socket tlsMode-istio selected for host with address 10.0.41.45:3000     thread=15
2024-04-17T17:38:00.214752Z     debug   envoy upstream external/envoy/source/common/upstream/upstream_impl.cc:426       transport socket match, socket tlsMode-istio selected for host with address 10.0.37.163:5000    thread=15
2024-04-17T17:38:00.215299Z     debug   envoy upstream external/envoy/source/common/upstream/upstream_impl.cc:426       transport socket match, socket tlsMode-disabled selected for host with address 10.0.41.134:3000 thread=15
2024-04-17T17:38:00.215464Z     debug   envoy upstream external/envoy/source/common/upstream/upstream_impl.cc:426       transport socket match, socket tlsMode-istio selected for host with address 10.0.43.244:9000    thread=15
```

**Verify the application pod IPs match the log lines.**

```bash
kubectl get pods -n $NAMESPACE -o custom-columns='NAME:metadata.name,PodIP:status.podIP'
```

The output should be similar to the below sample output.

```
NAME                              PodIP
catalogdetail-5896fff6b8-gqp5p    10.0.8.17
catalogdetail2-7d7d5cd48b-qw2dw   10.0.41.45
frontend-78f696695b-6txvg         10.0.43.244
productcatalog-64848f7996-62r74   10.0.37.163
```

Check the status of each connection in Kiali. Navigate to the Graph tab and enable Security in the Display menu. Then you will see a Lock icon to show where mTLS encryption is happening in the traffic flow graph.

![Application graph with auto mTLS](/images/04-kiali-auto-mtls-application-graph.png)

Congratulations!!! You've now successfully validated peer authentication setup in Istio on Amazon EKS. :tada:

You can either move on to the other sub-modules or if you're done with this module then refer to [Clean up](https://github.com/aws-samples/istio-on-eks/blob/main/modules/04-security/README.md#clean-up) to clean up all the resources provisioned in this module.
