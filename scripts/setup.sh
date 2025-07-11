#!/bin/bash
yum update -y
amazon-linux-extras install java-openjdk11 -y
yum install -y git awscli

# Clone and run app
git clone https://github.com/techeazy-consulting/techeazy-devops.git app || true
cd app
chmod +x scripts/start.sh || true
./scripts/start.sh --port 80 || true

# Setup shutdown hook for log upload
echo '
#!/bin/bash
aws s3 cp /var/log/cloud-init.log s3://techeazy-prerna-logs/ec2-logs/cloud-init.log
if [ -d /app/logs ]; then
    aws s3 cp /app/logs s3://techeazy-prerna-logs/app/logs/ --recursive
fi
' > /usr/local/bin/upload_logs.sh

chmod +x /usr/local/bin/upload_logs.sh

echo "/usr/local/bin/upload_logs.sh" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

shutdown -h +10
