```sh
cd ../sandbox/istio/

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

helm ls -n istio-system

# The Kubernetes Gateway API CRDs do not come installed by default on most Kubernetes clusters, so make sure they are installed before using the Gateway API.
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.1.0" | kubectl apply -f -; }

# The Bookinfo application is deployed, but not accessible from the outside. To make it accessible, you need to create an ingress gateway, which maps a path to a route at the edge of your mesh.
kubectl apply -f samples/bookinfo/gateway-api/bookinfo-gateway.yaml
kubectl wait --for=condition=programmed gtw bookinfo-gateway

export INGRESS_HOST=$(kubectl get gtw bookinfo-gateway -o jsonpath='{.status.addresses[0].value}')
export INGRESS_PORT=$(kubectl get gtw bookinfo-gateway -o jsonpath='{.spec.listeners[?(@.name=="http")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo $GATEWAY_URL
curl -s "http://${GATEWAY_URL}/productpage" | grep -o "<title>.*</title>"

kubectl apply -f samples/bookinfo/platform/kube/bookinfo-versions.yaml


# Kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/kiali.yaml
kubectl port-forward svc/kiali 20001:20001 -n istio-system --address 0.0.0.0

# Kiali via Helm
helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm install \
    --set cr.create=true \
    --set cr.namespace=istio-system \
    --set cr.spec.auth.strategy="anonymous" \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator

# Cleanup bookinfo
samples/bookinfo/platform/kube/cleanup.sh
```

kubectl -n istio-system edit kiali 

spec:
  auth:
    strategy: anonymous
  deployment:
    accessible_namespaces:
    - '**'
  cluster_wide_access: true
  external_services:
    istio:
      component_status:
        enabled: true
        components:
        - app_label: "gateway"
          namespace: "istio-ingress"
          is_core: true
          is_proxy: true


kubectl apply -f samples/addons/kiali.yaml 
kubectl apply -f samples/addons/grafana.yaml 
kubectl apply -f samples/addons/prometheus.yaml 
kubectl apply -f samples/addons/jaeger.yaml

kubectl destroy -f samples/addons/kiali.yaml 
kubectl destroy -f samples/addons/grafana.yaml 
kubectl destroy -f samples/addons/prometheus.yaml 
kubectl destroy -f samples/addons/jaeger.yaml
