
Date: 14/03/2020
# Building cluster:

## Cluster Architecture:

- Kube Master:
  
  Docker, Kubeadm, kubelet ,kubectl , control panel
- Kube Node 1:

	Docker, Kubeadm, kubelet ,kubectl 
- Kube Node 2:

	Docker, Kubeadm, kubelet ,kubectl 
 
	
### Installing docker in above 3 servers:

#### Commands:
```
$curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo   apt-key add -

$sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

$sudo apt-get update

$sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu

$sudo apt-mark hold docker-ce
```

### Installing Kubeadm, kubelet ,kubectl on above 3 servers:

#### Commands:
```
$curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

$cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

$sudo apt-get update
$sudo apt-get install -y kubelet=1.12.7-00 kubeadm=1.12.7-00 kubectl=1.12.7-00
$sudo apt-mark hold kubelet kubeadm kubectl
```

### Bootstrapping the cluster :

we are bootstrapping the cluster on the Kube master node. Then, joining each of the two worker nodes to the cluster, forming an actual multi-node Kubernetes cluster.
#### Commands:
```
//To initialize the cluster
$sudo kubeadm init --pod-network-cidr=10.244.0.0/16

//set up the local kubeconfig
$mkdir -p $HOME/.kube
$sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$sudo chown $(id -u):$(id -g) $HOME/.kube/config

// to join 2 working nodes into master node cluster , run below command in 2 working nodes
$sudo kubeadm join $some_ip:6443 --token $some_token --discovery-token-ca-cert-hash $some_hash

// now in the master node run following command to see clusters
$kubectl get nodes
```
Output:
```
cloud_user@grokrs1c:~$  kubectl get nodes
NAME  STATUS     ROLES    AGE   VERSION
grokrs1c.mylabserver.com   NotReady   master   14m   v1.12.7
grokrs2c.mylabserver.com   NotReady   <none>   65s   v1.12.7
grokrs3c.mylabserver.com   NotReady   <none>   7s    v1.12.7
```

### Configuring cluster networking to make the cluster fully functional
For this we are using flannel as a network plugin.
#### Commands:
```
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

//run below command only on master node 
$kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

$kubectl get nodes
```
Output:
```
cloud_user@grokrs1c:~$ kubectl get nodes
NAME                       STATUS   ROLES    AGE   VERSION
grokrs1c.mylabserver.com   Ready    master   57m   v1.12.7
grokrs2c.mylabserver.com   Ready    <none>   44m   v1.12.7
grokrs3c.mylabserver.com   Ready    <none>   43m   v1.12.7
```
So, we can that our cluster nodes are in ready state

## Kubernetes concepts:
### pods and container
- Pods are the smallest and most basic building block of kubernetes model.
- Pods contains 1 or more containers, storage resources, IP address . 
#### For Creating a simple pod running an nginx container:
```
$cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
EOF

```
The above one is creating a pod, with containers having image of nginx server .

Run following command to get runnung pod
```
cloud_user@grokrs1c:~$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          60s

//as we can see that ngnix pod is running
```

### kubernetes architecture components

Lets lists the pods of kube-system
```
cloud_user@grokrs1c:~$ kubectl get pods -n kube-system
NAME                                               READY   STATUS    RESTARTS   AGE
coredns-bb49df795-8ntnr                            1/1     Running   0          120m
coredns-bb49df795-lbfvp                            1/1     Running   0          120m
etcd-grokrs1c.mylabserver.com                      1/1     Running   0          119m
kube-apiserver-grokrs1c.mylabserver.com            1/1     Running   0          120m
kube-controller-manager-grokrs1c.mylabserver.com   1/1     Running   0          120m
kube-flannel-ds-amd64-6ccrs                        1/1     Running   0          63m
kube-flannel-ds-amd64-bxtzr                        1/1     Running   0          63m
kube-flannel-ds-amd64-h6br4                        1/1     Running   0          63m
kube-proxy-4b488                                   1/1     Running   0          107m
kube-proxy-58c6q                                   1/1     Running   0          106m
kube-proxy-c54lt                                   1/1     Running   0          120m
kube-scheduler-grokrs1c.mylabserver.com            1/1     Running   0          119m
```
- **etcd** :-  provides distributed and syncronized storage data for cluster state
- **kube-apiserver**  :- serves the kubernetes API, primary interface for cluster
- **kube-controller-manager**  :- bundles several components into 1 package
- **kube-scheduler**  :-schedule pods to run in individual nodes



	

