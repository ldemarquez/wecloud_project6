#!/bin/sh
#
#  Luis De Marquez
#
#Dinamic and AWS  Variables
#
#
#Check aws cli installed
#Check aws credential and tokens
#Display aws user and aws account
#
AWS_Ver_Min=`aws --version |cut -d "/" -f2|cut -c 1`
AWS_Ver=`aws --version`
AWS_SSO_CHK_TOKEN=`aws sts get-caller-identity |grep UserId|cut -d":" -f 3 |wc -c`
AWS_ACCOUNT=`aws sts get-caller-identity |grep "Account" |awk '{print $2}'|sed 's/"//g'|sed 's/,//'`
AWS_SSO_USERID=`aws sts get-caller-identity|grep "UserId" |cut -d ":" -f 3|sed 's/"//g'|sed 's/,//'`
AWS_IAM_USERID=`aws sts get-caller-identity|grep "Arn" |cut -d":" -f 7`
#
#
#
# Verify if aws cli is installed and is version 2
#
if [[ $AWS_Ver_Min == 2 ]]
 then
  echo "****"
  echo "**** aws cli version installed is: $AWS_Ver"
  echo " "
 else
  echo "**** aws cli is not installed or is not version 2.x ****"
  echo "****"
  echo "**** Please install aws cli version 2.x"
  exit
fi
#
# list existing aws configure environment
echo "****"
echo "**** Existing aws configure env"
echo " "
aws configure list

#
# Verify active token
#
if [[ $AWS_SSO_CHK_TOKEN -gt 1  ]]
 then
  echo "****"
  echo "**** Current aws configuration is AWS SSO"
  echo "****"
  echo "**** Your aws ID is: $AWS_SSO_USERID"
 else
  echo " "
  echo "****"
  echo "**** Current aws configuration is AWS IAM user"
  echo "****"
  echo "**** Your aws ID is: $AWS_IAM_USERID"
fi
