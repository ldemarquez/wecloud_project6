#!/bin/sh
#
#Variables
CLUSTER_NAME=eksp6lab
REGION=us-east-1
ZONE1=us-east-1a
ZONE2=us-east-1b



eksctl create cluster --name=$CLUSTER_NAME \
                      --region=$REGION \
                      --zones=$ZONE1,$ZONE2 \
                      --without-nodegroup 
