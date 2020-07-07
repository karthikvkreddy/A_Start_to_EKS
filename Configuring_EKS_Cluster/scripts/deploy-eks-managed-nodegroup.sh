#!/usr/bin/env bash

set +x -e
PROJECT="<PROJECT_NAME>"  # ex. infotech
ENVIRONMENT="<ENV>"  # ex. prod or test

EKS_CLUSTER_NAME="$PROJECT-eks-cluster-$ENVIRONMENT"
EKS_NODE_GROUP="$PROJECT-eks-nodegroup-$ENVIRONMENT"

KEY_NAME="$PROJECT-$ENVIRONMENT"
# INSTANCE_TYPE="t2.micro"  # each t2.micro node can run 4 pods.
INSTANCE_TYPE="t2.small"  # each t2.small can node run 11 pods.
INSTANCE_MIN_CAPACITY=1
INSTANCE_MAX_CAPACITY=5
INSTANCE_DESIRED_CAPACITY=3


AWS_REGION="<REGION_CODE>"  # You can choose other region as per your requirement
VPC_ID="<VPC_ID>"
SUBNET_IDS= "<SUBNET_IDs>" # ex. can be private subnets as recommended

stack_parameters="Project=$PROJECT ClusterName=$EKS_CLUSTER_NAME NodeGroupName=$EKS_NODE_GROUP VpcId=$VPC_ID Subnets=$SUBNET_IDS NodeInstanceType=$INSTANCE_TYPE KeyName=$KEY_NAME NodeAutoScalingGroupMinSize=$INSTANCE_MIN_CAPACITY NodeAutoScalingGroupDesiredCapacity=$INSTANCE_DESIRED_CAPACITY NodeAutoScalingGroupMaxSize=$INSTANCE_MAX_CAPACITY Environment=$ENVIRONMENT"
TEMPLATE_FILE="Configuring_EKS_Cluster/cloudformation/amazon-eks-managed-nodegroup.yaml"
STACK_NAME="$PROJECT-eks-nodegroup-$ENVIRONMENT"

aws cloudformation deploy --region $AWS_REGION --template-file $TEMPLATE_FILE \
    --no-fail-on-empty-changeset \
    --parameter-overrides $stack_parameters \
    --capabilities CAPABILITY_NAMED_IAM --stack-name $STACK_NAME --profile $PROFILE
