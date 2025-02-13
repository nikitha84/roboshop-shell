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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading erland script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading rabbitmq script"

dnf install rabbitmq-server -y  &>> $LOGFILE
VALIDATE $? "downloading rabbitmq server"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "creating user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting permission"
