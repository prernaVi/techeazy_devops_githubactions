#!/bin/bash
sudo yum update -y
sudo yum install git -y

# Clone your repo into /home/ec2-user/app
cd /home/ec2-user
git clone https://github.com/prernaVi/techeazy_devops_githubactions.git app

cd app

# Ensure Maven is installed if not already
sudo yum install maven -y

# Build the Spring Boot app
mvn clean package

# Stop existing Java processes
sudo pkill -f 'java -jar' || true

# Run the app
nohup java -jar target/*.jar --server.port=80 &
