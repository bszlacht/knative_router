# Setup Cluster:
```
./start-minikube.sh
```
```
./setup-cluster.sh
```
Don't worry about any warning.

# Setup 


https://redhat-developer-demos.github.io/knative-tutorial/knative-tutorial/setup/minikube.html


# co to kafka sink i kafka source
# todo jak polaczona jest ta aplikacja? gdzie sie dzieje scaling do zera? jak podbic liczbe replic dla servisu knative
# sdn - data plane - leca eventy/ controle plane -> routowanie eventow jakies proste, mikro agenciki odpychja/przyciagaja eventy

# todo:
# expose kafki na external events
# filtering na trigerach:
#   1. log
#   2. forward msg
# sending messages to other clusters
# switch to MQTT and K3S than use K3D