#starting K8s
## minikube is a service dedicated for running k8s in macOs
## in case you are running under Linux you need to run 
minikube start
#execute K8s 
kubectl start
#verify on configuration
kubectl config view
##verify on cluster nodes
kubectl get nodes
kubectl get pods


##Create Secret
kubectl create secret generic mssql --from-literal=SA_PASSWORD="MyC0m9l&xP@ssw0rd"
#Create persistent volume
## if succeded you will see the message “persistentvolumeclaim “mssql-data-claim” created
kubectl apply -f /Users/carloslopez/GitHub/SQL-Project-Repo/K8s/pv-claim.yaml
#Create a load balancer.
## After created and deployment you will read “mssql-deployment” created.
kubectl apply -f /Users/carloslopez/GitHub/SQL-Project-Repo/K8s/sqldeployment.yaml
#Start SQL Service

kubectl get service
minikube service mssql-deployment --url

#Stop k8s
minikube stop

#verify on minikube
kubectl cluster-info dump

kubectl get deployment mssql-deployment

#set minikube context
kubectl config use-context minikube

#minikube logs
minikube logs |grep "mssql-deployment"

kubectl get event
kubectl --help

##verify on service for minikube, Minikube runs on a built in Docker daemon
minikube dashboard

#remove Pod mssql-deployment
kubectl delete deployment mssql-deployment
#verification of pods run
kubectl get po -l run=mssql-deployment
kubectl delete pod mssql-deployment
kubectl delete secret mssql
