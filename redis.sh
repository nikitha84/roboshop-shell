#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

exec &>$LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Installing redis remis"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOGFILE
VALIDATE $? "alowing remote access"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "enabling redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "start redis"