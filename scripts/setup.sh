#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating packages and installing Java if not present..."
sudo yum update -y
sudo yum install -y java-17-amazon-corretto maven

echo "Navigating to app folder..."
cd /home/ec2-user/app

echo "Building Spring Boot app with Maven..."
mvn clean package

echo "Stopping any running Spring Boot application..."
sudo pkill -f 'java -jar' || true

echo "Starting Spring Boot app on port 80..."
nohup java -jar target/*.jar --server.port=80 &
