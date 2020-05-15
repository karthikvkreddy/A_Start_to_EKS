# Cluster Autoscaler

It is the default K8s component that can be used to perform pod scaling as well as scaling nodes in a cluster. It automatically increases the size of an Auto Scaling group so that pods have a place to run. And it attempts to remove idle nodes, that is, nodes with no running pods.

#### Prerequisites
Edit the ASG's min/max size to 2 and 8 nodes, respectively.

####  Create IAM Roles

The way kube2iam works is that each node in your cluster will need an IAM policy attached which allows it to assume the roles for your pods.


Change direcory for running set of commands below
```bash
cd 'Autoscaling/Custom autoscaler'
```

Create an IAM policy for your nodes and attach it to the the role your Kubernetes nodes run on:
This policy tells our IAM role can allow us to assume role for any resource in aws.

To apply policy:
```
aws iam put-role-policy --role-name <NODE_INSTANCE_ROLE_NAME> --policy-name kube2iamAssumeRolePolicy --policy-document file://kube2iam-assume-role-policy.json --profile <profile-name>
```

Next, creating roles for each pod. Each role will need a policy that has only the permissions that the pod needs to perform its function e.g. listing s3 objects, writing to DynamoDB, reading from SQS, etc. 
Replace `<NODE_GROUP_ROLE>` in `kube2iam-ca-role-policy.json` file with the arn of the role attached to the EKS nodegroup EC2 instances.


To get the informmation of `node_group_role` name in which your kuberntes nodes runs.

```
kubectl -n kube-system describe configmap aws-auth
```

```
aws iam create-role --role-name CP-kube2iam-ca-role <Kube2iam-ROLE_NAME> \
 --assume-role-policy-document file://kube2iam-ca-role-policy.json 
```

Attaching required policies to above created role `<Kube2iam-ROLE_NAME>'.
```
aws iam create-policy \
--policy-name <kube2iam-POLICY_NAME> \
--policy-document file://asg-policy.json 
```
```
aws iam attach-role-policy \
--policy-arn arn:aws:iam::<Account-Id>:policy/<kube2iam-POLICY_NAME> \
--role-name <Kube2iam-ROLE_NAME> 
```

Verify that below annotation is present in k8s/cluster_autoscaler.yaml file with correct role name, under metadata in our deployment file.
```
annotations:
  iam.amazonaws.com/role: <Kube2iam-ROLE_NAME>
```

#### Deploy Kube2iam chart **(if not deployed already)**

Follow steps from [root README](../../README.md) file for deploying `kube2iam` chart.

#### Deploy Cluster Autoscaler

Edit `k8s/cluster_autoscaler.yaml`, replacing `<AUTOSCALING_GROUP_NAME>` in line 140 with the ASG name you found in the AWS console. Optionally change the value for AWS_REGION in line 143 to something other if you are working in a different region.


Deploy the autoscaler:
```
kubectl apply -f ./k8s/cluster_autoscaler.yaml
```

Watch the logs:
```
kubectl logs -f deployment/cluster-autoscaler -n kube-system
```

#### Test cluster autoscaling on the `helloworld` application  

##### Scaling our deployment
Deploy samplel application:
```
kubectl apply -f ./sample-app
```

Scale out the replicaset of `helloworld` deployment to 20

```
kubectl scale --replicas=20 deployment/helloworld-deployment
```

Watch the pods to see new pods in running up.
```
kubectl get pods -o wide --watch
```

After few minutes, once the maximum pod limit is reached for existing cluster worker nodes, `Cluster Autoscaler` will try to launch new worker nodes in order to accomodate required number of replicas.


You can run below command to check number of nodes
```bash
kubectl get nodes -w
```


Alternatively, you can also check the AWS Management Console to confirm that the Auto Scaling group is scaling up to meet demand. This may take a few minutes. 