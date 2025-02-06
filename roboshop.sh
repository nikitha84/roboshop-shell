#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0af62f102bd40722d
INSTANCES=("mongodb" "mysql" "cart" "user")

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb"] || [ $i == "mysql"]
    then
        INSTANCES_TYPE="t3.small"
    else
        INSTANCES_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type t2.micro --security-group-ids sg-0af62f102bd40722d --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'instance[0].PrivateIpAddress' --output text)
   
   echo "instance is: $i"
done






#using query cmd query data and getback ips
