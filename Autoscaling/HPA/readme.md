    
# Horizontal Pod Autoscaler

It scales the pods in a deployment or replica set. It is implemented as a K8s API resource and a controller. The controller manager queries the resource utilization against the metrics specified in each HorizontalPodAutoscaler definition. It obtains the metrics from either the resource metrics API (for per-pod resource metrics), or the custom metrics API (for all other metrics).

#### Prerequisite
##### Install [Helm](https://docs.aws.amazon.com/eks/latest/userguide/helm.html) 

On linux: 
```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod +x get_helm.sh
./get_helm.sh
```

#### Install Metrics Server:

```
helm install stable/metrics-server \
--set rbac.create=true \
--set args[0]="--kubelet-insecure-tls=true" \
--set args[1]="--kubelet-preferred-address-types=InternalIP" \
--set args[2]="--v=2" \
--name metrics-server
```

Confirm the Metrics API is available

```
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```

If everithing goes fine, you should see a status message similar to the one below in the response. (This can take some time.)
```
status:
conditions:
- lastTransitionTime: "2019-08-20T09:33:01Z"
    message: all checks passed
    reason: Passed
    status: "True"
    type: Available
```
Now we will scale a deployed application.

#### Test `helloworld` application

Deploy sample helloworld app
```
kubectl apply -f ./sample-app/
```

##### Create an HPA Resource
This HPA scales up when CPU exceeds 50% of the allocated container resource.
```
kubectl autoscale deployment helloworld-deployment --cpu-percent=50 --min=1 --max=10
```
`Description:`
The above command will create a Horizontal Pod Autoscaler that maintains between 1 and 10 replicas of the Pods controlled by the helloworld-deployment deployment. Roughly speaking, HPA will increase and decrease the number of replicas (via the deployment) to maintain an average CPU utilization across all Pods of 50% (since each pod requests 200 milli-cores by kubectl run, this means average CPU usage of 100 milli-cores).

View the HPA using kubectl. You probably will see `<unknown>/50%` for 1-2 minutes and then you should be able to see `0%/50%`

```
kubectl get hpa
```
output:
```
NAME                    REFERENCE                                TARGET       MINPODS   MAXPODS   REPLICAS   AGE
helloworld-deployment   Deployment/helloworld-deployment/scale   0% / 50%     1         10        1          11m
```

#### Testing HPA using Busybox

Get `LoadBalancer DNS` of `helloworld` service. This will be required for executing one of the commands below.
```
kubectl get svc helloworld-service
```

Increase the load by hitting the App K8S service from several locations.

Run this command in a new terminal
```
kubectl run -i --tty load-generator --image=busybox /bin/sh
```
The above command will open a terminal, where we need to execute the command below.

```bash
while true; do wget -q -O - <LoadBalancer DNS>; done
```


The HPA should now start to scale the number of Pods in the deployment as the load increases. This scaling takes place according to what is specified in the HPA resources. At some point, the new Pods fall into a ‘pending state’ while waiting for extra resources.

On the other teminal, within a minute or so, we should see the higher CPU load by executing:
```
kubectl get hpa -w
```
output:
```
NAME                    REFERENCE                          TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
helloworld-deployment   Deployment/helloworld-deployment   250%/50%   1         10        1          2m21s
helloworld-deployment   Deployment/helloworld-deployment   250%/50%   1         10        4          2m32s
helloworld-deployment   Deployment/helloworld-deployment   250%/50%   1         10        5          2m47s
```


Here, CPU consumption has increased to the request. As a result, the deployment was resized to replicas:
```
kubectl get deployment helloworld-deployment
```

You will see HPA scale the pods from 1 up to our configured maximum (10) until the CPU average is below our target (50%)





