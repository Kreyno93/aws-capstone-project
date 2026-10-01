#!/bin/bash
# Testing loadbalancer by creating a website with httpd and showing the AZ and private IP
# redirecting any error messages to a log file
exec 2>>/var/log/loadbalancer_test.log
# Update the system
yum update -y
# Install Apache HTTP Server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Get AZ and Private IP using metadata
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a basic HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>EC2 Web Server</title>
  <style>
    body { font-family: Arial; text-align: center; margin-top: 100px; }
    h1 { color: #2e8b57; }
    p { font-size: 20px; }
  </style>
</head>
<body>
  <h1>Welcome to your EC2 Web Server!</h1>
  <p><strong>Availability Zone:</strong> $AZ</p>
  <p><strong>Private IP Address:</strong> $PRIVATE_IP</p>
</body>
</html>
EOF