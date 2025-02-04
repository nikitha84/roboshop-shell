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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enable nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "remove default nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "download web file"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "moving to nginx directory"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unziping"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copy roboshop.conf"

systemctl restart nginx  &>> $LOGFILE
VALIDATE $? "restart"