#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating packages..."
sudo yum update -y

echo "Installing Java (Amazon Corretto 17)..."
sudo amazon-linux-extras install java-openjdk17 -y

echo "Installing Maven..."
sudo yum install -y maven

echo "Navigating to app folder..."
cd /home/ec2-user/app

echo "Building Spring Boot application..."
mvn clean package

echo "Stopping existing Spring Boot application if running..."
sudo pkill -f 'java -jar' || true

echo "Starting Spring Boot application on port 80..."
nohup java -jar target/*.jar --server.port=80 &
