#!/bin/bash

set -e

echo "========================"
echo "🚀 Starting setup.sh..."
echo "========================"

echo "🔍 Checking for yum lock..."
MAX_WAIT=300
WAITED=0

while sudo fuser /var/run/yum.pid >/dev/null 2>&1; do
    echo "⚠️  yum is locked. Waiting..."
    sleep 5
    WAITED=$((WAITED + 5))
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo "⚔️  Forcing unlock..."
        YUM_PID=$(sudo lsof /var/run/yum.pid | awk 'NR==2{print $2}')
        [ -n "$YUM_PID" ] && sudo kill -9 "$YUM_PID"
        break
    fi
done

echo "🔄 Updating system packages..."
sudo yum update -y

echo "☕ Installing Java..."
if ! java -version &>/dev/null; then
    sudo amazon-linux-extras enable corretto17
    sudo yum install -y java-17-amazon-corretto-devel || sudo yum install -y java-17-openjdk-devel
fi

echo "🔧 Installing Maven..."
sudo yum install -y maven

echo "✅ Java and Maven installed."

if [ ! -d "/home/ec2-user/app/.git" ]; then
    echo "📥 Cloning repository..."
    git clone <YOUR_REPO_URL> /home/ec2-user/app
else
    echo "📂 Repo exists, pulling latest..."
    cd /home/ec2-user/app
    git pull
fi

echo "🏗️  Building Spring Boot application..."
cd /home/ec2-user/app
mvn clean package

echo "🛑 Stopping running application..."
sudo pkill -f 'java -jar' || true

echo "🚀 Starting Spring Boot on port 80..."
nohup java -jar target/*.jar --server.port=80 > /home/ec2-user/app/nohup.out 2>&1 &

echo "✅ Deployment complete. Access your app via:"
curl -s http://169.254.169.254/latest/meta-data/public-ipv4

echo "✅ Logs: /home/ec2-user/app/nohup.out"
