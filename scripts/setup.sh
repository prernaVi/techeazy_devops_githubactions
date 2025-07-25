#!/bin/bash

# Update package lists
sudo yum update -y

# Install Java (Amazon Corretto 17)
sudo amazon-linux-extras install java-openjdk17 -y

# Install Maven
sudo yum install maven -y

# Navigate to app directory
cd /home/ec2-user/app

# Build the Spring Boot project
mvn clean package

# Kill any existing Spring Boot process
sudo pkill -f 'java -jar' || true

# Run the Spring Boot jar on port 80
nohup java -jar target/*.jar --server.port=80 &
