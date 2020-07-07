# Flentd

Here we will be deploying Fluentd as a DaemonSet, or one pod per worker node. The fluentd log daemon will collect logs and forward to CloudWatch Logs.

Please Refer : https://www.fluentd.org/

### Step 1: create an IAM policy and attach it the the Worker node role
   Grab IAM Role Name from worker node
    
    $ROLE_NAME =  <IAM_ROLE_NAME>
    $aws iam put-role-policy --role-name $ROLE_NAME --policy-name Logs-Policy-For-Worker --policy- document file:://k8s-logs-policy.json
    
   
### step 2: Deploying Flentd 
   
   Change the yaml file and Update REGION and CLUSTER_NAME environment variables in fluentd.yml to the ones for your values. Currently, they are set to us-west-2 and eks_cluser by default. Adjust this change in the ‘env’ section of the fluentd.yml file on line no 196.
    
    $kubectl apply -f ./fluentd.yml
  
  kubectl get pods -w --namespace=kube-system
    
    $kubctl get pods -w --namespace=kube-system

### step 3: check out CloudWatch Logs 
   
   We are now ready to check that logs are arriving in CloudWatch Logs
  
### step 4: Cleanup
    
    $ kubectl delete -f ./fluentd.yml
   
