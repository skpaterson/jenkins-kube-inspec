#!/usr/bin/env bash
set -x
CLUSTER=${GCP_CLUSTER_NAME:='jenkins-ci'}
ZONE=${GCP_ZONE:="europe-west2-a"}
SIZE=${GCP_MACHINE_TYPE:="n1-standard-2"}
NODES=${GCP_CLUSTER_NODES:=2}
NETWORK=${GCP_NETWORK:='jenkins'}
SCOPES=${GCP_SCOPES:='projecthosting,storage-rw'}
gcloud config set compute/zone ${ZONE}
gcloud compute networks create ${NETWORK}
gcloud container clusters create ${CLUSTER} --network ${NETWORK} --machine-type ${SIZE} --num-nodes ${NODES} \
  --scopes "https://www.googleapis.com/auth/${SCOPES}"
gcloud container clusters get-credentials ${CLUSTER}
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default
helm init --service-account tiller --wait
helm update
helm install -n cd stable/jenkins -f jenkins/values.yaml --version 0.16.6 --wait
kubectl get pods
until kubectl get pods | grep Running; do sleep 5; echo 'Pending Running state...'; done
until kubectl get pods | grep 1/1; do sleep 5; echo 'Pending Ready 1/1 state...'; done
#export POD_NAME=$(kubectl get pods -l "component=cd-jenkins-master" -o jsonpath="{.items[0].metadata.name}")
#kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
#echo http://127.0.0.1:8080
echo "Jenkins admin password is:"
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
helm install --name nginx-ingress stable/nginx-ingress
##helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true
#kubectl --namespace default get services -o wide -w nginx-ingress-controller
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=jenkins.com"
kubectl create secret tls jenkins-ingress-ssl --key /tmp/tls.key --cert /tmp/tls.crt
#kubectl describe secret jenkins-ingress-ssl
kubectl create -f jenkins/ingress-simple.yaml
