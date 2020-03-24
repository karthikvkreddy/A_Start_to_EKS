Date: 18/03/2020

## Horizental pod autoscaling
### Step 1:
	
Install helm:

Ref Link= https://helm.sh/

Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.
	
On Linux:
    
    $ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
    $ chmod +x get_helm.sh
    $ ./get_helm.sh
    
### Step 2: configuring Tiller RBAC
Ref Link about RBAC:  https://helm.sh/docs/topics/rbac/
    
    $kubectl apply -f ./tiller-rbac.yaml
 
Initialize Helm on both client and server using Tiller Service Account:
    
    $ helm init --service-account tiller
 
### Step 3: Installing matrix server
	  
    $helm install stable/metrics-server --name metrics-server --version 2.0.4 --namespace metrics

### Step 5: deploying php-apache
    
    $ kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80

### Step 6: Autoscale the deployment
    
    $ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
The above command will create a Horizontal Pod Autoscaler that maintains between 1 and 10 replicas of the Pods controlled by the php-apache deployment we created in 

### step 7: To check status of pods
    $kubectl get hpa
    
   ouput:
    
    NAME         REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
    php-apache   Deployment/php-apache   <unknown>/50%   1         10        1          4m8s
    
   As we can see, currently the CPU consumption is 0 % out of 50 % , as we dont have any load .
   
   Open a new terminal enter the following command.
   
    $kubectl run -i --tty load-generator --image=busybox /bin/sh
  
   Execute a while loop to continue getting http:///php-apache

    $while true; do wget -q -O - http://php-apache; done

In the previous termninal , watch the HPA with the following command
  
    $kubectl get hpa -w
    
    
## Cluster Autoscaler

### Step 1:Modify the Min/Max Sizes of the Autoscaling Group

1. log in to the AWS Management Console .
2. Navigate to the EC2 service.
3. Click Autoscaling Groups in the left sidebar.
4. Select the autoscaling group that has already been created for you.

Note the name of the autoscaling group (we'll need it later).

5. Click Actions > Edit.
6. In the Edit details menu, configure the following settings:
  Min: 2
  Max: 8

7. Click Save.

### Step 2:Configure the Cluster Autoscaler
1. Go back to your terminal application
2. List the contents of the home directory.
```ls```
3. Edit the cluster_autoscaler.yaml file.
4. vim cluster_autoscaler.yaml
5. Locate the <AUTOSCALING GROUP NAME>placeholder, and replace it with the autoscaling group name we found in the AWS Management Console.
6. Press Escape, then type :wq to quit the vim text editor.

### Step 3:Apply the IAM Policy to the Worker Node Group Role
1. List the contents of the asg-policy.json file.
2. cat asg-policy.json
3. Copy the content of asg-policy.json to your clipboard.
4. Switch to the AWS Management Console.
5. Navigate to the IAM service.
6. Click Roles in the left sidebar.
7. Type "node" in the search bar.
8. Click the name of the role that appears in the search results to open it.
9. Click + Add inline policy.
10. Click the JSON tab.
11. Delete the default text from the policy editor, and paste in the content of asg-policy.json you copied to your clipboard earlier.
12. Click Review policy.
13. Name the policy "CA".
14. Click Create policy.

### step 4: Deploy the Cluster Autoscaler
Go back to your terminal application.
1. Run the following command:
```
$kubectl apply -f cluster_autoscaler.yaml
```
2. Check the cluster autoscaler logs.
```
$kubectl logs -f deployment/cluster-autoscaler -n kube-system
```
Press Ctrl + C to exit the logs.

Deploy and Scale the Nginx Deployment.


3. Deploy the nginx deployment.
```
$kubectl apply -f nginx.yaml
```

Verify that the deployment was successful.
```
$kubectl get deployment/nginx-scaleout
```
Scale the Nginx Deployment

4. run the following command:
```
$kubectl scale --replicas=10 deployment/nginx-scaleout
```
Check the autoscaler logs again.
```
$kubectl logs -f deployment/cluster-autoscaler -n kube-system
```


Check the nodes.
```
$kubectl get nodes

```
Delete the nginx and cluster autoscaler deployments.
```
$kubectl delete -f cluster_autoscaler.yaml
$kubectl delete -f nginx.yaml
```





