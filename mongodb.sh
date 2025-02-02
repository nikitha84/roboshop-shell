#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "ERROR: $2 .. $R failed $N"
    else
        echo -e "$2.... $G Success $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "ERROR : $R Please run with root user $N"
    exit 1
else
    echo "you are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongoDB repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Instaling mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enable mongodb"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "remote access to mongodb"

systemctl restart mongod
VALIDATE $? "restarting mongodb" &>> $LOGFILE

