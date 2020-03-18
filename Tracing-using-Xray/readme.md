# Tracing-using-Xray

As distributed systems evolve, monitoring and debugging services becomes challenging. Container-orchestration platforms like Kubernetes solve a lot of problems, but they also introduce new challenges for developers and operators in understanding how services interact and where latency exists. AWS X-Ray helps developers analyze and debug distributed services.


### step 1:MODIFY IAM ROLE
    Go to worker node and select IAMrole and click on attach policy: AWSXRayDaemonWriteAccess  
    (or)
    //command to attcah 
    $aws iam attach-role-policy --role-name <ROLE_NAME> --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess

  
### step 2:DEPLOY X-RAY DAEMONSET
    
    $docker build -t xray-daemon .
    

  Create an ECR repository for the xray-daemon. Replace us-east-1 with your region, if desired.
   
   Create an Amazon ECR repository
    
    $(aws ecr get-login --no-include-email --region us-east-1)
    $aws ecr create-repository --repository-name xray-daemon
  
  Tag and push the image to ECR. Replace 12345679898 in the commands below with your AWS account ID.

    $docker tag xray-daemon:latest 12345679898.dkr.ecr.us-east-1.amazonaws.com/xray-daemon:latest

    $docker push 12345679898.dkr.ecr.us-east-1.amazonaws.com/xray-daemon:latest
    
  Apply the configuration.
    
    $kubectl apply -f xray-k8s-daemonset.yaml

  To view the status of the X-Ray DaemonSet:

    $kubectl describe daemonset xray-daemon
    
  output:
  ```
  [cloud_user@ip-10-192-10-182 ~]$ kubectl describe daemonset xray-daemon
Name:           xray-daemon
Selector:       app=xray-daemon
Node-Selector:  <none>
Labels:         <none>
Annotations:    deprecated.daemonset.template.generation: 1
Desired Number of Nodes Scheduled: 2
Current Number of Nodes Scheduled: 2
Number of Nodes Scheduled with Up-to-date Pods: 2
Number of Nodes Scheduled with Available Pods: 2
Number of Nodes Misscheduled: 0
Pods Status: 2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=xray-daemon
  Containers:
   xray-daemon:
    Image:      rnzdocker1/eks-workshop-x-ray-daemon:dbada4c77e6ae10ecf5a7b1c5864aa6522d9fb02
    Port:       2000/UDP
    Host Port:  2000/UDP
    Command:
      /usr/bin/xray
      -c
      /aws/xray/config.yaml
    Limits:
      memory:     24Mi
    Environment:  <none>
    Mounts:
      /aws/xray from config-volume (ro)
  Volumes:
   config-volume:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      xray-config
    Optional:  false
Events:
  Type    Reason            Age    From                  Message
  ----    ------            ----   ----                  -------
  Normal  SuccessfulCreate  6m58s  daemonset-controller  Created pod: xray-daemon-jrb9d
  Normal  SuccessfulCreate  6m58s  daemonset-controller  Created pod: xray-daemon-pv6bj

  ```

  Ensure all pods are running. To view the logs for all of the X-Ray daemon pods run the following:

    $kubectl logs -l app=xray-daemon  

### step 3:DEPLOY EXAMPLE MICROSERVICES
   Build Two Application(1 for front-end and 1 more for back-end)
    
    cd app/service-a
    docker build -t service-a .
    cd ../service-b
    docker build -t service-b .
    cd ..
    
   creating a repocitory in ecr
    
    $aws ecr create-repository --repository-name service-a
    $aws ecr create-repository --repository-name service-b
    
   Tag and Push Both Demo Applications to ECR . Replace 12345679898 with your AWS account ID in the commands below:

    $docker tag service-a:latest 12345679898.dkr.ecr.us-east-1.amazonaws.com/service-a:latest
    $docker tag service-b:latest 12345679898.dkr.ecr.us-east-1.amazonaws.com/service-b:latest

    $docker push 12345679898.dkr.ecr.us-east-1.amazonaws.com/service-a:latest
    $docker push 12345679898.dkr.ecr.us-east-1.amazonaws.com/service-b:latest
    
   Deploy the Demo Applications to EKS. 
   Edit k8s-deploy.yaml specifying your ECR URIs for both services.

   Deploy the services:

    $kubectl apply -f k8s-deploy.yaml
   When the services are deployed, ELB is created and DNS updated.
   
   send some load to the application:
   
    $curl <DNS adresss>

### step 4:X-RAY CONSOLE
   We now have the example microservices deployed, so we are going to investigate our Service Graph and Traces in X-Ray section of the AWS Management Console.
### step 5:Clean Up
   Delete the example applications:
     
    $kubectl delete deployments service-a service-b
   
   Delete the X-Ray DaemonSet:

    $kubectl delete -f xray-k8s-daemonset.yaml


Usefull Link: https://aws.amazon.com/blogs/compute/application-tracing-on-kubernetes-with-aws-x-ray/
