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

dnf install python3.11 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing pythone"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "downloading payment file"

cd /app &>> $LOGFILE

unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzing user file"

pip3.11 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing dependencis"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copied payment service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user daemon reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "user enable payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "user start payment"