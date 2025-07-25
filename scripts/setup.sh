#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating packages..."
# Retry if yum lock is held
while fuser /var/run/yum.pid >/dev/null 2>&1; do
    echo "Another process is using yum. Waiting..."
    sleep 5
done
sudo yum update -y

echo "Installing Java (Amazon Corretto 17)..."
# Install java-17-amazon-corretto if available, else fallback to java-17-openjdk
if sudo amazon-linux-extras enable corretto17; then
    sudo yum install -y java-17-amazon-corretto-devel
else
    sudo yum install -y java-17-openjdk-devel
fi

echo "Verifying Java installation..."
java -version

echo "Installing Maven..."
sudo yum install -y maven

echo "Verifying Maven installation..."
mvn -version

echo "Navigating to app folder..."
cd /home/ec2-user/app

echo "Building Spring Boot application..."
mvn clean package

echo "Stopping existing Spring Boot application if running..."
sudo pkill -f 'java -jar' || true

echo "Starting Spring Boot application on port 80..."
nohup java -jar target/*.jar --server.port=80 > /home/ec2-user/app/nohup.out 2>&1 &
echo "Spring Boot application started. Logs are available in /home/ec2-user/app/nohup.out"
