# Monitoring

AWS eks doesn't have integration with cloudwatch . So, thier is a OPEN SOURCE PROJECT to support monitoring of eks nodes, clusters.

That is Prometheus, https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html

### step 1: Install the Helm CLI, if not installed
```
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```
Download the stable repository so we have something to start with:
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```
Once this is installed, we will be able to list the charts you can install:
```
helm search repo stable
```
Finally, let’s configure Bash completion for the helm command:
```
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)
```

### step 2: Deploy Prometheus

In this page, we are primarily going to use the standard configuration, but we do override the storage class. We will use gp2 EBS volumes for simplicity and demonstration purpose. When deploying in production, you would use io1 volumes with desired IOPS and increase the default storage size in the manifests to get better performance. 

Run the following command:
  
    kubectl create namespace prometheus
    helm install prometheus stable/prometheus \
      --namespace prometheus \
      --set alertmanager.persistentVolume.storageClass="gp2" \
      --set server.persistentVolume.storageClass="gp2"
      
Check if Prometheus components deployed as expected
```
kubectl get all -n prometheus
```
You should see response similar to below. They should all be Ready and Available
```
NAME                                                 READY     STATUS    RESTARTS   AGE
pod/prometheus-alertmanager-77cfdf85db-s9p48         2/2       Running   0          1m
pod/prometheus-kube-state-metrics-74d5c694c7-vqtjd   1/1       Running   0          1m
pod/prometheus-node-exporter-6dhpw                   1/1       Running   0          1m
pod/prometheus-node-exporter-nrfkn                   1/1       Running   0          1m
pod/prometheus-node-exporter-rtrm8                   1/1       Running   0          1m
pod/prometheus-pushgateway-d5fdc4f5b-dbmrg           1/1       Running   0          1m
pod/prometheus-server-6d665b876-dsmh9                2/2       Running   0          1m

NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/prometheus-alertmanager         ClusterIP   10.100.89.154    <none>        80/TCP     1m
service/prometheus-kube-state-metrics   ClusterIP   None             <none>        80/TCP     1m
service/prometheus-node-exporter        ClusterIP   None             <none>        9100/TCP   1m
service/prometheus-pushgateway          ClusterIP   10.100.136.143   <none>        9091/TCP   1m
service/prometheus-server               ClusterIP   10.100.151.245   <none>        80/TCP     1m

NAME                                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/prometheus-node-exporter   3         3         3         3            3           <none>          1m

NAME                                            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-alertmanager         1         1         1            1           1m
deployment.apps/prometheus-kube-state-metrics   1         1         1            1           1m
deployment.apps/prometheus-pushgateway          1         1         1            1           1m
deployment.apps/prometheus-server               1         1         1            1           1m

NAME                                                       DESIRED   CURRENT   READY     AGE
replicaset.apps/prometheus-alertmanager-77cfdf85db         1         1         1         1m
replicaset.apps/prometheus-kube-state-metrics-74d5c694c7   1         1         1         1m
replicaset.apps/prometheus-pushgateway-d5fdc4f5b           1         1         1         1m
replicaset.apps/prometheus-server-6d665b876                1         1         1         1m
```
In order to access the Prometheus server URL, we are going to use the kubectl port-forward command to access the application. run:
```
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090
```

To access WEB UI, run:
```
<IP_ADDRESS>:9090
```

### step 4: Deploy grafana
Grafana is the open source analytics and monitoring solution for every database.

Please Refer this: https://grafana.com/

We are now going to install Grafana. For this example, we are primarily using the Grafana defaults, but we are overriding several parameters. As with Prometheus, we are setting the storage class to gp2, admin password, configuring the datasource to point to Prometheus and creating an external load balancer for the service.
```
kubectl create namespace grafana
helm install grafana stable/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set adminPassword='<PASSWORD>' \
    --set datasources."datasources\.yaml".apiVersion=1 \
    --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
    --set datasources."datasources\.yaml".datasources[0].type=prometheus \
    --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-server.prometheus.svc.cluster.local \
    --set datasources."datasources\.yaml".datasources[0].access=proxy \
    --set datasources."datasources\.yaml".datasources[0].isDefault=true \
    --set service.type=LoadBalancer
```
Run the following command to check if Grafana is deployed properly:
```
kubectl get all -n grafana
```
Ouput may look like, They should all be Ready and Available
```
NAME                          READY     STATUS    RESTARTS   AGE
pod/grafana-b9697f8b5-t9w4j   1/1       Running   0          2m

NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
service/grafana   LoadBalancer   10.100.49.172   abe57f85de73111e899cf0289f6dc4a4-1343235144.us-west-2.elb.amazonaws.com   80:31570/TCP   3m


NAME                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana   1         1         1            1           2m

NAME                                DESIRED   CURRENT   READY     AGE
replicaset.apps/grafana-b9697f8b5   1         1         1         2m
```
You can get Grafana ELB URL using this command. Copy & Paste the value into browser to access Grafana web UI.
```
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ELB"
```
When logging in, use the username admin and get the password hash by running the following:
```
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

### step 5: Grafana dashboard
Thier exist 2 dashboards 1 for cluster, 1 more for pods.

#### For cluster Monitoring Dashboard:
  For creating a dashboard to monitor the cluster:

1. Click ’+’ button on left panel and select ‘Import’.
2. Enter 3119 dashboard id under Grafana.com Dashboard.
3. Click ‘Load’.
4. Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.
5. Click ‘Import’.

This will show monitoring dashboard for all cluster nodes

#### Pods Monitoring Dashboard:
  For creating a dashboard to monitor all the pods:

1. Click ’+’ button on left panel and select ‘Import’.
2. Enter 6417 dashboard id under Grafana.com Dashboard.
3. Click ‘Load’.
4. Enter Kubernetes Pods Monitoring as the Dashboard name.
5. Click change to set the Unique identifier (uid).
6. Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.s
7. Click ‘Import’.
