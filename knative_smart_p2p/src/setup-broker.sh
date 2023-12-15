# Todo change the path of resources so it works from the repo root


# STEP 1 - deploy kafka to k8s

# create kafka namespace
kubectl create namespace kafka
# deploy kafka into the cluster
curl -L \
https://github.com/strimzi/strimzi-kafka-operator\
/releases/download/0.32.0/strimzi-cluster-operator-0.32.0.yaml \
  | sed 's/namespace:.*/namespace: kafka/' \
  | kubectl apply -n kafka -f -
# wait for the kafka to stand up
kubectl wait --for=condition=Ready pod --all -n kafka --timeout=5m
# deploy kafka cluster
kubectl -n kafka apply -f broker-setup-files/kafka-broker-my-cluster.yaml
# deploy kafka topic
# TODO check if necesary
# kubectl -n kafka create -f broker-setup-files/kafka-topic-my-topic.yaml

# STEP 2 - install eventing logic in cluster

# apply knative eventing for kafka
kubectl apply \
-f https://github.com/knative-sandbox/eventing-kafka/releases/download/knative-v1.8.1/source.yaml
# wait for they to deploy
kubectl wait --for=condition=Ready pod --all -n knative-eventing --timeout=5m
# deploy kn kafka channel
curl -L "https://github.com/knative-sandbox/eventing-kafka/\
releases/download/knative-v1.8.1/channel-consolidated.yaml" \
 | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
 | kubectl apply --filename -
# apply kafka default channel
kubectl apply -f broker-setup-files/default-channel-config.yaml

# apply kafka default broker
kubectl apply -f broker-setup-files/broker-setup-files/default-broker.yaml

# node ingress
k apply -f my-node-ingress.yaml -n kafka 
kubectl wait --for=condition=Ready pod --all -n kafka --timeout=5m

# For each Knative Eventing Channel that you will create, 
# there will be a Kafka Topic created, 
# the topic’s name will follow a convention like 
# knative-messaging-kafka.<your-channel-namespace>.<your-channel-name>.
# kubectl apply -f default-kafka-channel.yaml
# kubectl -n knativetutorial delete  channels.messaging.knative.dev my-events-ch

# TODO usunac
# sink to process events from kafka
# kubectl apply -f eventing-hello-sink.yaml

# TODO usunac
# create kafka source
# kubectl -n knativetutorial apply -f mykafka-source.yaml

# TODO wybrac potrzebne
# STEP 3 - content based routing + useless fruites with kamel
# kamel install --olm=false
# kamel -n knativetutorial run \
#  --wait \
#  --dependency camel:log \
#  --dependency camel:jackson \
#  --dependency camel:jsonpath \
#  fruits-producer.yaml

# watch kubectl -n knativetutorial get pods

# kubectl apply -n knativetutorial -f fruit-processor-kamelet.yaml
# kubectl apply -n knativetutorial -f eip/fruits-processor-to-knative.yaml
# kubectl apply -n knativetutorial -f fruit-events-display.yaml

# minikube -p knativetutorial -n knativetutorial service fruit-events-display

# kubectl apply -n knativetutorial -f sugary-fruits.yaml
# ./call.sh fruits-producer ''

# komenda zeby dostac ip gdzie ladowac numerki
# FIXME src/broker-setup-files [ minikube service my-node-ingress-service -n kafka --url                                                                                         ] 12:53 
