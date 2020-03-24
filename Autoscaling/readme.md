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

