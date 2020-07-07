#!/usr/bin/env bash

set +x -e

PROJECT="<PROJECT_NAME>"  # ex. infotech
ENVIRONMENT="<ENV>"  # ex. prod

EKS_CLUSTER_NAME="$PROJECT-eks-cluster-$ENVIRONMENT"
EKS_VERSION="<VERSION>"  # ex. 1.5 

AWS_REGION="<REGION_CODE>"  # You can choose other region as per your requirement
VPC_ID="<VPC_ID>"
SUBNET_IDS= "<SUBNET_IDs>" # ex. can be either private and public subnets

TEMPLATE_FILE="Configuring_EKS_Cluster/cloudformation/amazon-eks-cluster.yaml"

STACK_NAME="$PROJECT-eks-cluster-$ENVIRONMENT"

stack_parameters="Project=$PROJECT ClusterName=$EKS_CLUSTER_NAME VpcId=$VPC_ID SubnetIds=$SUBNET_IDS EKSVersion=$EKS_VERSION Environment=$ENVIRONMENT"
aws cloudformation deploy --region $AWS_REGION --template-file $TEMPLATE_FILE \
    --no-fail-on-empty-changeset \
    --parameter-overrides $stack_parameters \
    --capabilities CAPABILITY_NAMED_IAM --stack-name $STACK_NAME
