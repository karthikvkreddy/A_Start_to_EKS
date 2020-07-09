# Vertical Pod Autoscaler

The Kubernetes [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) automatically adjusts the CPU and memory reservations for your pods to help "right size" your applications. This adjustment can improve cluster resource utilization and free up CPU and memory for other pods.

#### Prerequisite
Install Metrics server(if not installed already), Follow the steps in [HPA readme](../HPA/readme.md) file.

#### Deploy the Vertical Pod Autoscaler

Clone the repo
```
git clone https://github.com/kubernetes/autoscaler.git
```

Change to the vertical-pod-autoscaler directory.
```
cd autoscaler/vertical-pod-autoscaler/
```
(Optional) If you have already deployed another version of the Vertical Pod Autoscaler, remove it with the following command.
```
./hack/vpa-down.sh
```

Deploy the Vertical Pod Autoscaler to your cluster with the following command.
```
./hack/vpa-up.sh
```

kubectl get pods -n kube-system
```
kubectl get pods -n kube-system
```

Output:
```
NAME                                        READY   STATUS    RESTARTS   AGE
vpa-admission-controller-68c748777d-ppspd   1/1     Running   0          7s
vpa-recommender-6fc8c67d85-gljpl            1/1     Running   0          8s
vpa-updater-786b96955c-bgp9d                1/1     Running   0          8s
```

#### Testing Vertical Pod Autoscaler 

##### Testing on `helloworld` deployment
The `helloworld-deployment.yml` file has been updated to include VPA configurations.

Delete and redeploy `helloworld` deployment for the new changes.
```bash
kubectl delete app/k8s/helloworld-deployment.yml
```

```bash
kubectl apply app/k8s/helloworld-deployment.yml
```

Get the pods from the `helloworld` application.
```
kubectl get pods -l app=helloworld
```
output:
```
helloworld-c7d89d6db-rglf5   1/1     Running   0          48s
helloworld-c7d89d6db-znvz5   1/1     Running   0          48s
```
Describe one of the pods to view its CPU and memory reservation.
```
kubectl describe pod <helloworld_pod_name>
```
Output:

```
...
    Requests:
      cpu:        100m
      memory:     50Mi    
...
```

We can see that the original pod reserves 100 millicpu of CPU and 50 Mebibytes of memory. For this example application, 100 millicpu is less than the pod needs to run, so it is CPU-constrained. It also reserves much less memory than it needs. The Vertical Pod Autoscaler `vpa-recommender` deployment analyzes the helloworld pods to see if the CPU and memory requirements are appropriate. If adjustments are needed, the `vpa-updater` relaunches the pods with updated values.

Now, get a shell for the `helloworld` container:
```bash
kubectl exec -it helloworld-deployment -- /bin/sh
```
And then run this command in above shell:
```bash
while true; do timeout 0.5s yes >/dev/null; sleep 0.5s; done
```
The above command will try to utilize slightly above 500 millicores (repeatedly using CPU for 0.5s and sleeping 0.5s).


In a new terminal, wait for the  `vpa-updater` to launch a new helloworld pod. This should take a minute or two. You can monitor the pods with the following command.
```
kubectl get --watch pods -l app=helloworld
```
When a new `helloworld` pod is started, describe it and view the updated CPU and memory reservations.
```
kubectl describe pod <new_helloworld_pod_name>
```
Output:
```
...
    Requests:
      cpu:        587m
      memory:     262144k
...
```
Here you can see that the CPU reservation has increased to 587 millicpu, which is over five times the original value. The memory has increased to 262,144 Kilobytes, which is around 250 Mebibytes, or five times the original value. This pod was under-resourced, and the Vertical Pod Autoscaler corrected our estimate with a much more appropriate value.

Describe the `helloworld-vpa` resource to view the new recommendation.
```
kubectl describe vpa/helloworld-vpa
```
Output:
```
...
  Recommendation:
    Container Recommendations:
      Container Name:  helloworld
      Lower Bound:
        Cpu:     100m
        Memory:  262144k
      Target:
        Cpu:     100m
        Memory:  262144k
      Uncapped Target:
        Cpu:     25m
        Memory:  262144k
      Upper Bound:
        Cpu:     341m
        Memory:  500Mi
Events:          <none>
...
```
