# wecloud_project6

******  Project 6 Observability Systems ******

Member of the team: 
Luis De Marquez
Prithvi kohli
Sara Siddiqui
Bhargav Dalwadi

This repo has 4 sub directories under the top workdir

Directory infra  ( scripts to create AWS EKS infrastructure)

Directory monitoring ( prometheus, grafana & loki

Directory web-app  ( kubernetes manifest for a demo web-app react using AWS NLB 
                     image from dockerhub )

Directory lb-nginx ( kubernetes manifest for a demo nginx using AWS NLB 
                     image from AWS ECR )


***** Prerequisites *****
AWS account and credentials with permissions to access multiple AWS Resources;
docker hub account ;
Have AWS CLI, eksctl, kubectl, helm and Git installed on your machine;



1. Create AWS EKS Infrastructure

from the repo top dir 


cd infra

verify credentials 

./chk_aws.sh

verify eksctl 

Example below
 % eksctl info

eksctl version: 0.124.0
kubectl version: v1.23.0
OS: darwin

1.1 Create AWS EKS cluster 

cd dir infra

Edit Variables in script create-ekscluster.sh for your environment

#Variables
CLUSTER_NAME=eksp6lab
REGION=us-east-1
ZONE1=us-east-1a
ZONE2=us-east-1b

Run script ./create-ekscluster.sh 

% ./create-ekscluster.sh 

wait at least 15 min 

Verify the script output last five lines

2023-07-28 14:18:30 [✔]  saved kubeconfig as "/Users/ldemarquez/.kube/config"
2023-07-28 14:18:30 [ℹ]  no tasks
2023-07-28 14:18:30 [✔]  all EKS cluster resources for "eksp6lab" have been created
2023-07-28 14:18:45 [ℹ]  kubectl command should work with "/Users/ldemarquez/.kube/config", try 'kubectl get nodes'
2023-07-28 14:18:45 [✔]  EKS cluster "eksp6lab" in "us-east-1" region is ready

Verify your AWS EKS Cluster

% eksctl get cluster 

% kubectl config view |grep eksp6lab

  name: eksp6lab.us-east-1.eksctl.io
    cluster: eksp6lab.us-east-1.eksctl.io
    user: root@eksp6lab.us-east-1.eksctl.io
  name: root@eksp6lab.us-east-1.eksctl.io
current-context: root@eksp6lab.us-east-1.eksctl.io
- name: root@eksp6lab.us-east-1.eksctl.io
      - eksp6lab


% kubectl get namespaces 

NAME              STATUS   AGE
default           Active   7m16s
kube-node-lease   Active   7m18s
kube-public       Active   7m18s
kube-system       Active   7m18s

1.2 Create IAM OIDC Provider

cd infra

Edit Variables in script create-iamoidc-provider.sh for your environment

#Variables
CLUSTER_NAME=eksp6lab
REGION=us-east-1

% ./create-iamoidc-provider.sh

2023-07-28 14:29:57 [ℹ]  will create IAM Open ID Connect provider for cluster "eksp6lab" in "us-east-1"
2023-07-28 14:29:58 [✔]  created IAM Open ID Connect provider for cluster "eksp6lab" in "us-east-1"


#########################################################################
2. Create nodegroup workers node access to public subnets

Pre-requisites a valid EC2 KeyPair in your working dir

example project2KeyPair.pem

cd infra

Edit Variables in script create-nodegroup-public.sh for your environment

#Variables
CLUSTER_NAME=eksp6lab
REGION=us-east-1
NODEGROUP_NAME=eksp5-ng-private1
NODE_TYPE=t3.medium
NODE_MIN=2
NODE_MAX=4
NODE_VOL_SIZE=20
SSH_PUBLIC_KEY=project2KeyPair


!!!!!!! NOTE:  Remenber never commit your EC2 KeyPair to your repo !!!!!!!!


 % ./create-nodegroup.sh

Verify nodegroup

% eksctl get nodegroup --cluster eksp6lab

% kubectl get nodes -o wide

NAME                             STATUS   ROLES    AGE     VERSION                INTERNAL-IP      EXTERNAL-IP      OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
ip-192-168-5-156.ec2.internal    Ready    <none>   9m54s   v1.23.17-eks-a5565ad   192.168.5.156    54.173.49.63     Amazon Linux 2   5.4.247-162.350.amzn2.x86_64   docker://20.10.23
ip-192-168-58-164.ec2.internal   Ready    <none>   9m52s   v1.23.17-eks-a5565ad   192.168.58.164   34.228.194.164   Amazon Linux 2   5.4.247-162.350.amzn2.x86_64   docker://20.10.23

#########################################################################
3. Adding workload to the AWS EKS cluster ( two deployments ) 

cd to the top working dir

3.1 First Deployment web-app 

% kubectl create namespace web-app
namespace/web-app created

% kubectl apply -f web-app/manifest -n web-app
deployment.apps/web created
service/nlb-web created
service/web created

Verify deployment

% kubectl get all -n web-app                  
NAME                      READY   STATUS    RESTARTS   AGE
pod/web-945fcc47d-lxx7p   1/1     Running   0          5m37s
pod/web-945fcc47d-nnptb   1/1     Running   0          5m37s

NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)        AGE
service/nlb-web   LoadBalancer   10.100.199.93    a4dad101873d64ef792210e8c2d4cb80-791f634a72211dc1.elb.us-east-1.amazonaws.com   80:32477/TCP   5m37s
service/web       ClusterIP      10.100.139.114   <none>                                                                          80/TCP         5m37s

NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web   2/2     2            2           5m38s

NAME                            DESIRED   CURRENT   READY   AGE
replicaset.apps/web-945fcc47d   2         2         2       5m39s

Verify AWS NLB access ( wait 5 min ) 

NOTE:  nslookup the service/nlb-web LoadBalancer a4dad101873d64ef792210e8c2d4cb80-791f634a72211dc1.elb.us-east-1.amazonaws.com

ldemarquez@Luiss-MacBook-Pro-2 project6 % nslookup a4dad101873d64ef792210e8c2d4cb80-791f634a72211dc1.elb.us-east-1.amazonaws.com
Server:		2607:f798:18:10:0:640:7125:5204
Address:	2607:f798:18:10:0:640:7125:5204#53

Non-authoritative answer:
Name:	a4dad101873d64ef792210e8c2d4cb80-791f634a72211dc1.elb.us-east-1.amazonaws.com
Address: 54.174.16.168
Name:	a4dad101873d64ef792210e8c2d4cb80-791f634a72211dc1.elb.us-east-1.amazonaws.com
Address: 54.236.138.237


Verify access to the Web App suing the NLB 

example below http://nlb
in the browser http://4dad101873d64ef792210e8c2d4cb80-791f634a72211dc1.elb.us-east-1.amazonaws.com


3.12 Second Deployment  lb-nginx

cd to the top working dir

% kubectl create namespace lb-nginx
namespace/lb-nginx created

% kubectl apply -f lb-nginx/manifest -n lb-nginx 
deployment.apps/lb-nginx created
service/lb-nginx created
ldemarquez@Luiss-MacBook-Pro-2 project6 % 

% kubectl get all -n lb-nginx 
NAME                            READY   STATUS    RESTARTS   AGE
pod/lb-nginx-5f6d7f9869-299hd   1/1     Running   0          46s
pod/lb-nginx-5f6d7f9869-bqn7v   1/1     Running   0          46s
pod/lb-nginx-5f6d7f9869-fg5q8   1/1     Running   0          46s

NAME               TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)        AGE
service/lb-nginx   LoadBalancer   10.100.103.177   a88c1bc2e15cd4da7a0d997f95852f33-b54ee7d702f44573.elb.us-east-1.amazonaws.com   80:30783/TCP   46s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/lb-nginx   3/3     3            3           46s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/lb-nginx-5f6d7f9869   3         3         3       47s

Verify AWS NLB access ( wait 5 min )

NOTE:  nslookup the service/lb-nginx LoadBalancer a88c1bc2e15cd4da7a0d997f95852f33-b54ee7d702f44573.elb.us-east-1.amazonaws.com 

nslookup a88c1bc2e15cd4da7a0d997f95852f33-b54ee7d702f44573.elb.us-east-1.amazonaws.com
Server:		2607:f798:18:10:0:640:7125:5204
Address:	2607:f798:18:10:0:640:7125:5204#53

Non-authoritative answer:
Name:	a88c1bc2e15cd4da7a0d997f95852f33-b54ee7d702f44573.elb.us-east-1.amazonaws.com
Address: 44.199.170.115
Name:	a88c1bc2e15cd4da7a0d997f95852f33-b54ee7d702f44573.elb.us-east-1.amazonaws.com
Address: 3.211.69.124

Verify access to the Web App suing the NLB 

example below http://nlb
in the browser http://a88c1bc2e15cd4da7a0d997f95852f33-b54ee7d702f44573.elb.us-east-1.amazonaws.com

#########################################################################
4. Installation and Configuration of Prometheus, Grafana & Loki 

The installation of Prometheus, Grafana & Loki will be in one namespace ( monitoring ),  
in production the installation should be using stateful environment and AWS ALB LoadBalancer

4.1 Installation of Prometheus

% kubectl create namespace monitoring
namespace/monitoring created



% helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
% helm repo update
% helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

Verify Prometheus & Grafana ( Kube-Prometheus-Stack ) 

% kubectl --namespace monitoring get pods -l "release=monitoring"
NAME                                                   READY   STATUS    RESTARTS   AGE
monitoring-kube-prometheus-operator-6df4dc47bc-nkzb5   1/1     Running   0          77s
monitoring-kube-state-metrics-56ff45d66-svppg          1/1     Running   0          76s
monitoring-prometheus-node-exporter-6nvjk              1/1     Running   0          77s
monitoring-prometheus-node-exporter-vbqtp              1/1     Running   0          77s

Access Prometheus main console 

% kubectl port-forward service/prometheus-operated 9090:9090 -n monitoring

http://127.0.0.1:9090/

Access Grafana main Console 

kubectl port-forward service/monitoring-grafana 8080:80 -n monitoring

http://127.0.0.1:8080/ 

login: User is admin and password is prom-operator

Kube-Prometheus-Stack provides out-of-the-box monitoring capabilities using Prometheus, Grafana, and Alertmanager. It collects metrics from various Kubernetes components and allows you to visualize them using chart Grafana dashboards.

Go to the toggle menu left corner beside Home / Dashboard see all available dashboards

Import th following dashboards IDs:  10000 & 13770

Go to Dashboard / New / scroll down to import 

Import via grafana.com  ID xxx / load 

Folder General / Import

Select Prometheus Data Source ( Prometheus Default ) 

Import 

name Cluster Monitoring for Kubernetes

Repeat thge process for dashboard ID 1 13770 Kubernetes All-in-one Cluster Monitoring KR

Other IDs to import 

Dashboard	ID
k8s-addons-prometheus.json	19105
k8s-addons-trivy-operator.json	16337
k8s-system-api-server.json	15761
k8s-system-coredns.json	15762
k8s-views-global.json	15757
k8s-views-namespaces.json	15758
k8s-views-nodes.json	15759
k8s-views-pods.json	15760



4.2 Installation Grafana-Loki Log Aggregation

%helm repo add grafana https://grafana.github.io/helm-charts
%helm repo update
%helm upgrade --install loki --namespace=monitoring grafana/loki-stack --set grafana.enabled=false --set loki.enabled=true --set loki.promtail.enabled=true

Verify 

% kubectl get all -n monitoring |grep loki
pod/loki-0                                                   1/1     Running   0          2m34s
pod/loki-promtail-brhg9                                      1/1     Running   0          2m34s
pod/loki-promtail-kp69m                                      1/1     Running   0          2m34s
service/loki                                      ClusterIP   10.100.93.3      <none>        3100/TCP                     2m35s
service/loki-headless                             ClusterIP   None             <none>        3100/TCP                     2m35s
service/loki-memberlist                           ClusterIP   None             <none>        7946/TCP                     2m35s
daemonset.apps/loki-promtail                         2         2         2       2            2           <none>                   2m35s
statefulset.apps/loki                                                   1/1     2m35s
ldemarquez@Luiss-MacBook-Pro-2 project6 % 


Add Loki as Data Source in Grafana,

Log in to Grafana Console

Home / toggle menu / Administration / Data Source / Connections / search Loki

Select Loki / 



Right corner + Add new data Source 

Select <Logging & document databases>

<Loki> 

URL   http://loki:3100

save

Then, import the dashboard ID 12611 for logs visualization.

5. Test Grafana

Home / Dashboards / select Kubernetes / Compute Resources / Cluster

cd top work dir


edit web-app/manifest/web-deployment.yaml 

change replicas: 2 for replicas: 20

save 

% kubectl apply -f web-app/manifest -n web-app
deployment.apps/web configured
service/nlb-web unchanged
service/web configured


Check the Grafana Dashboard









