#!/bin/bash
set -e

echo "Updating packages and installing Java & Maven if not present..."
sudo yum update -y

if ! java -version &>/dev/null; then
    echo "Java not found, installing Amazon Corretto 17..."
    sudo yum install -y java-17-amazon-corretto
else
    echo "Java is already installed."
fi

if ! mvn -v &>/dev/null; then
    echo "Maven not found, installing Maven..."
    sudo yum install -y maven
else
    echo "Maven is already installed."
fi

echo "Navigating to app folder..."
cd /home/ec2-user/app

echo "Cleaning previous builds..."
mvn clean

echo "Building Spring Boot app with Maven..."
mvn package

echo "Stopping any running Spring Boot application..."
sudo pkill -f 'java -jar' || true

echo "Starting Spring Boot app on port 8080..."
nohup java -jar target/*.jar --server.port=8080 &
