#!/bin/sh
#
#Variables
CLUSTER_NAME=eksp6lab
REGION=us-east-1
NODEGROUP_NAME=eksp6-ng-1
NODE_TYPE=t3.medium
NODE_MIN=2
NODE_MAX=4
NODE_VOL_SIZE=20
SSH_PUBLIC_KEY=project2KeyPair


        
eksctl create nodegroup --cluster=$CLUSTER_NAME \
                        --region=$REGION \
                        --name=$NODEGROUP_NAME \
                        --node-type=$NODE_TYPE \
                        --nodes-min=$NODE_MIN \
                        --nodes-max=$NODE_MAX \
                        --node-volume-size=$NODE_VOL_SIZE \
                        --ssh-access \
                        --ssh-public-key=$SSH_PUBLIC_KEY \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \


