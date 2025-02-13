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

dnf install maven -y &>> $LOGFILE

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shipping"

cd /app &>> $LOGFILE
VALIDATE $? "moving into app directoey"

unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unziping shipping file"

mvn clean package &>> $LOGFILE
VALIDATE $? "installing dependices"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jar files"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copied shipping service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "deamon reload"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabling"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql client"

mysql -h 172.31.38.62 -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE 
VALIDATE $? "loading shipping date into mysql"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"

