#!/bin/bash

set -e

echo "✅ Updating packages..."
sudo yum update -y

echo "✅ Installing Java 17 if not present..."
if ! java -version &>/dev/null; then
    sudo yum install -y java-17-amazon-corretto
else
    echo "Java 17 already installed."
fi

echo "✅ Installing Maven 3.9.6 if not present..."
if ! mvn -v | grep "3.9.6"; then
    echo "Downloading Maven 3.9.6..."
    wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -P /tmp
    sudo tar xf /tmp/apache-maven-3.9.6-bin.tar.gz -C /opt
    sudo ln -sfn /opt/apache-maven-3.9.6 /opt/maven
    sudo tee /etc/profile.d/maven.sh <<EOF
export M2_HOME=/opt/maven
export PATH=\${M2_HOME}/bin:\${PATH}
EOF
    source /etc/profile.d/maven.sh
else
    echo "Maven 3.9.6 already installed."
fi

echo "✅ Navigating to app folder..."
cd /home/ec2-user/app

echo "✅ Cleaning previous builds..."
mvn clean

echo "✅ Building Spring Boot app..."
mvn package -DskipTests

echo "✅ Stopping any running Spring Boot application..."
sudo pkill -f 'java -jar' || true

echo "✅ Starting Spring Boot app on port 8080..."
nohup java -jar target/*.jar --server.port=8080 > app.log 2>&1 &

echo "✅ Deployment completed successfully."
