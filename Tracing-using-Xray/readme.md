# Tracing-using-Xray

As distributed systems evolve, monitoring and debugging services becomes challenging. Container-orchestration platforms like Kubernetes solve a lot of problems, but they also introduce new challenges for developers and operators in understanding how services interact and where latency exists. AWS X-Ray helps developers analyze and debug distributed services.


### step 1:MODIFY IAM ROLE
    Go to worker node and select IAMrole and click on attach policy: AWSXRayDaemonWriteAccess  
    (or)
    //command to attcah 
    $aws iam attach-role-policy --role-name <ROLE_NAME> --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess

  
### step 2:DEPLOY X-RAY DAEMONSET
    
### step 3:DEPLOY EXAMPLE MICROSERVICES
### step 4:X-RAY CONSOLE
### step 5:Clean Up


Usefull Link: https://aws.amazon.com/blogs/compute/application-tracing-on-kubernetes-with-aws-x-ray/
