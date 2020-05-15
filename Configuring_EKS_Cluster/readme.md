
#### Deploy EKS cluster
Change the parameter values in `Configuring_EKS_Cluster/scripts/deploy-cluster.sh` (if needed) and run the script.
```bash
sh Configuring_EKS_Cluster/scripts/deploy-cluster.sh 
```

This will launch the cloudformation stack to deploy the EKS cluster.

Install [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) for Kubernetes 1.15 or later version.
Install [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

#### Configure EKS Access

Create or update your kubeconfig for your cluster.

```bash
aws eks --region <AWS_REGION> update-kubeconfig --name <eks-cluster-name> 
```

Test the configuration.

```bash
kubectl get svc
```

##### Provision EKS Nodegroup (Worker nodes)
Change the parameter values in `Configuring_EKS_Cluster/scripts/deploy-eks-managed-nodegroup.sh` (if needed) and run the script.

Before running the script create a EC2 Key-Pairs with the Name `{PROJECT_NAME}-{ENVIRONMENT}` depending on the `ENVIRONMENT` value in the script.
```bash
sh Configuring_EKS_Cluster/scripts/deploy-eks-managed-nodegroup.sh
```

This will launch the cloudformation stack to deploy the eks nodegroup. Watch the status of your nodes and wait for them to reach the `Ready` status.
```
$ kubectl get nodes --watch
```

#### Configure EKS Access

When we create an Amazon EKS cluster, the IAM entity user or role, such as a federated user that creates the cluster, is automatically granted system:masters permissions in the cluster's RBAC configuration. To grant additional AWS users or roles the ability to interact with your cluster, you must edit the aws-auth ConfigMap within Kubernetes.

##### aws-auth ConfigMap snippet
&nbsp;
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<AWS::AccountId>:role/<ROLE_NAME1>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
```

Open the aws-auth ConfigMap.

```bash
$ kubectl edit -n kube-system configmap/aws-auth
```

Add the IAM role/user to you want to provide access to and save the file.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<AWS_ACCOUNTID>:role/<ROLE_NAME1>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::<AWS_ACCOUNTID>:role/<ROLE_NAME2>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::<AWS_ACCOUNTID>:user/<IAM_USER_NAME1>
      username: <IAM_USER_NAME1>
      groups:
        - system:masters
    - userarn: arn:aws:iam::<AWS_ACCOUNTID>:user/<IAM_USER_NAME2>
      username: <IAM_USER_NAME2>
      groups:
        - system:masters
```

