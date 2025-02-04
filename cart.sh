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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling  nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing  nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi        

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart file"

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unziping cart file"

npm install &>> $LOGFILE
VALIDATE $? "Installing depencies"

cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "copied cart service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "cart daemon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart"
 
systemctl start cart &>> $LOGFILE
VALIDATE $? "Start cart"

