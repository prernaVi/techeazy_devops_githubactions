#!/bin/bash

set -e

echo "Updating packages and installing Java if not present..."
if ! java -version &>/dev/null; then
    sudo yum update -y
    sudo yum install -y java-17-amazon-corretto
fi

echo "Installing latest Maven (3.9.6) manually..."
MAVEN_VERSION=3.9.6
MAVEN_DIR=apache-maven-$MAVEN_VERSION
MAVEN_ARCHIVE=apache-maven-$MAVEN_VERSION-bin.tar.gz

if ! mvn -v | grep "$MAVEN_VERSION"; then
    wget https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN_ARCHIVE
    tar -xzf $MAVEN_ARCHIVE
    sudo mv $MAVEN_DIR /opt/
    sudo ln -sf /opt/$MAVEN_DIR/bin/mvn /usr/bin/mvn
    rm $MAVEN_ARCHIVE
else
    echo "Maven $MAVEN_VERSION already installed."
fi

mvn -v

echo "Navigating to app folder..."
cd /home/ec2-user/app

echo "Building Spring Boot app with Maven..."
mvn clean package -DskipTests

echo "Stopping any running Spring Boot application..."
sudo pkill -f 'java -jar' || true

echo "Starting Spring Boot application on port 8080..."
nohup java -jar target/*.jar --server.port=8080 > app.log 2>&1 &
