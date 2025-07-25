#!/bin/bash

set -e

echo "========================"
echo "🚀 Starting setup.sh..."
echo "========================"

echo "🔍 Checking for yum lock..."
MAX_WAIT=300
WAITED=0

while sudo fuser /var/run/yum.pid >/dev/null 2>&1; do
    echo "⚠️  yum is locked. Waiting for it to be released..."
    sleep 5
    WAITED=$((WAITED + 5))
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo "🛑 yum lock held too long. Attempting to kill the blocking process..."
        YUM_PID=$(sudo lsof /var/run/yum.pid | awk 'NR==2{print $2}')
        if [ -n "$YUM_PID" ]; then
            echo "⚔️  Killing process $YUM_PID holding yum lock..."
            sudo kill -9 "$YUM_PID"
            sleep 5
        else
            echo "⚠️  Could not find PID. Proceeding cautiously."
        fi
        break
    fi
done

echo "🔄 Updating system packages..."
sudo yum update -y

echo "☕ Installing Java (Amazon Corretto 17 or fallback)..."
if sudo amazon-linux-extras enable corretto17; then
    sudo yum install -y java-17-amazon-corretto-devel
else
    echo "⚠️  Corretto17 not found, attempting OpenJDK 17..."
    sudo yum install -y java-17-openjdk-devel
fi

echo "✅ Java installed:"
java -version

echo "🔧 Installing Maven..."
sudo yum install -y maven

echo "✅ Maven installed:"
mvn -version

echo "📂 Navigating to app folder..."
cd /home/ec2-user/app

echo "🏗️  Building Spring Boot application..."
mvn clean package

echo "🛑 Stopping any running Spring Boot instance..."
sudo pkill -f 'java -jar' || true

echo "🚀 Starting Spring Boot application on port 80..."
nohup java -jar target/*.jar --server.port=80 > /home/ec2-user/app/nohup.out 2>&1 &

echo "✅ Deployment complete. Logs: /home/ec2-user/app/nohup.out"
