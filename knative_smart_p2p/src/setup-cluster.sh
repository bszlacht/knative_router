# 1. crds
kubectl apply \
  --filename https://github.com/knative/serving/releases/download/knative-v1.8.3/serving-crds.yaml \
  --filename https://github.com/knative/eventing/releases/download/knative-v1.8.5/eventing-crds.yaml
# 2. serving-core
kubectl apply \
  --filename \
  https://github.com/knative/serving/releases/download/knative-v1.8.3/serving-core.yaml
# 3. wait for deployment
kubectl rollout status deploy controller -n knative-serving
kubectl rollout status deploy activator -n knative-serving
kubectl rollout status deploy autoscaler -n knative-serving
kubectl rollout status deploy webhook -n knative-serving
# 4. install Kourier
kubectl apply \
  --filename \
    https://github.com/knative/net-kourier/releases/download/knative-v1.8.1/kourier.yaml
# 5. wait for deployment
kubectl rollout status deploy 3scale-kourier-control -n knative-serving
kubectl rollout status deploy 3scale-kourier-gateway -n kourier-system
# 6. set kourier as default ingress
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
# 5. install countour
kubectl apply \
  --filename https://projectcontour.io/quickstart/contour.yaml
# 6. wait for deployment
kubectl rollout status ds envoy -n projectcontour
kubectl rollout status deploy contour -n projectcontour
# 7. deploy kourier ingress
cat <<EOF | kubectl apply -n kourier-system -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kourier-ingress
  namespace: kourier-system
spec:
  rules:
  - http:
     paths:
       - path: /
         pathType: Prefix
         backend:
           service:
             name: kourier
             port:
               number: 80
EOF
# 8. configure Knative to use the kourier-ingress Gateway:
ksvc_domain="\"data\":{\""$(minikube -p knativetutorial ip)".nip.io\": \"\"}"
kubectl patch configmap/config-domain \
    -n knative-serving \
    --type merge \
    -p "{$ksvc_domain}"
# 9. install Kn Eventing
kubectl apply \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-v1.8.5/eventing-core.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-v1.8.5/in-memory-channel.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-v1.8.5/mt-channel-broker.yaml
# 10. wait for deployment
kubectl rollout status deploy eventing-controller -n knative-eventing
kubectl rollout status deploy eventing-webhook  -n knative-eventing
kubectl rollout status deploy imc-controller  -n knative-eventing
kubectl rollout status deploy imc-dispatcher -n knative-eventing
kubectl rollout status deploy mt-broker-controller -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing
# 11. crate namespace
kubectl create namespace knativetutorial
kubectl config set-context --current --namespace=knativetutorial
