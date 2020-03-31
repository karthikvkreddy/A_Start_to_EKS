# ALB_Ingree_Controller_POC

AWS ALB Ingress Controller for Kubernetes is a controller that triggers the creation of an Application Load Balancer and the necessary supporting AWS resources whenever an Ingress resource is created on the cluster with the **kubernetes.io/ingress.class: alb** annotation. The Ingress resource uses the ALB to route HTTP or HTTPS traffic to different endpoints within the cluster.

NOte: AWS EKS creates Classic Load Balancer when deployed service By default.

Before starting deployment ALB ingress controller we need to add these Tag to the subnets in your VPC that you want to use for your load balancers so that the ALB Ingress Controller knows that it can use them.

Public subnets in your VPC should be tagged accordingly so that Kubernetes knows to use only those subnets for external load balancers.
```
Key:  kubernetes.io/role/elb          Value: 1
```
Also, private subnets in your VPC should be tagged accordingly so that Kubernetes knows that it can use them for internal load balancers:
```
Key: kubernetes.io/role/internal-elb  Value: 1
```
### Step 1: Deploying the ALB ingress controller
Verify the Name of the Cluster with the CLI

```
aws eks list-clusters
```
Output
```

{
        "clusters": [
                "<EKS-CLUSTER-NAME>"
                    ]
} 
```

Create an IAM policy called ALBIngressControllerIAMPolicy for your worker node instance profile that allows the ALB Ingress Controller to make calls to AWS APIs on your behalf
```
aws iam create-policy \
--policy-name ALBIngressControllerIAMPolicy \
--policy-document file://iam-policy.json
```
Get the IAM role name for your worker nodes. Use the following command to print the aws-auth configmap from where you can fetch the IAM role name:

```
kubectl -n kube-system describe configmap aws-auth
```
Attach the new ALBIngressControllerIAMPolicy IAM policy to each of the worker node IAM roles:
```
 aws iam attach-role-policy \
--policy-arn arn:aws:iam::<AWS_ACCOUNT_ID>:policy/ALBIngressControllerIAMPolicy \
--role-name <WORKER_NODES_IAM_ROLE>                                                 
```

Deploy RBAC Roles and RoleBindings needed by the AWS ALB Ingress controller:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml
```

Download the AWS ALB Ingress controller YAML into a local file:
```
curl -sS "https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml" > alb-ingress-controller.yaml
```
Edit the AWS ALB Ingress controller YAML to include the clusterName of the Amazon EKS cluster.

Edit the –cluster-name flag to be the real name of the Amazon EKS cluster in your alb-ingress-controller.yaml file.

Deploy the AWS ALB Ingress controller YAML:
```
kubectl apply -f alb-ingress-controller.yaml
```
Verify that the deployment was successful and the controller started:
```
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o alb-ingress[a-zA-Z0-9-]+)
```
You should be able to see the following output:

```
-------------------------------------------------------------------------------
AWS ALB Ingress controller
  Release:    v1.1.4
  Build:      git-0db46039
  Repository: https://github.com/kubernetes-sigs/aws-alb-ingress-controller
--------------------------------------------------------------------------
```

### Step 2: Deploying sample application

Creating Ingress Object
Actual ALB will not be created until you create an ingress object which is expected.

Here is a sample deployment file which we are going to expose using ingress object.

Deploy the sample app
```
kubectl create -f sample-app.yaml
```

View pods
```
kubectl get all --selector=app=blog
```
output
```
NAME                        READY   STATUS              RESTARTS   AGE
pod/blog-5db564d456-bbd7s   0/1     ContainerCreating   0          7s
pod/blog-5db564d456-fwst7   0/1     ContainerCreating   0          7s
pod/blog-5db564d456-wbgt9   0/1     ContainerCreating   0          7s

NAME           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/blog   NodePort   10.100.192.86   <none>        80:31033/TCP   7s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/blog-5db564d456   3         3         0       7s

```

Deploy ingress object

```
kubectl apply -f ingress.yaml
```
Check ingress object
```
kubectl get ingress -o wide
```
output:
```
NAME       HOSTS   ADDRESS                                                                PORTS   AGE
blog       *                                                                              80      6s
mywebapp   *       dd591b5c-default-mywebapp-633c-704431140.us-east-1.elb.amazonaws.com   80      3m45s

```
Here you can see ingress is created and it has the address of Load Balancer which is deployed in AWS Application Load Balancer.
Note down the  ALB URL and open it in browser to access your application.
