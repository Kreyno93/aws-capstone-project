#!/bin/bash

# WordPress Installation Script for Amazon Linux 2
# This script installs and configures WordPress with Apache and PHP

set -e  # Exit on any error

# Logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting WordPress installation at $(date)"

# Database configuration from template variables
DB_NAME="${db_name}"
DB_USER="${db_username}"
DB_PASSWORD="${db_password}"
DB_HOST="${db_endpoint}"

# Remove port from endpoint if present
DB_HOST=$(echo "$DB_HOST" | sed 's/:3306//')

echo "Database configuration:"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DB_HOST: $DB_HOST"

# Update system packages
echo "Updating system packages..."
yum update -y

# Install Apache web server
echo "Installing Apache web server..."
yum install -y httpd

# Install PHP 8.0 and required extensions
echo "Installing PHP and extensions..."
amazon-linux-extras install -y php8.0
yum install -y php-mysqlnd php-gd php-xml php-mbstring php-json php-curl

# Install MySQL client for database connectivity testing
echo "Installing MySQL client..."
yum install -y mysql

# Install additional utilities
yum install -y wget unzip

# Start and enable Apache
echo "Starting Apache web server..."
systemctl start httpd
systemctl enable httpd

# Configure Apache
echo "Configuring Apache..."
# Enable mod_rewrite for WordPress permalinks
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

# Download and install WordPress
echo "Downloading WordPress..."
cd /tmp
wget -O wordpress.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf wordpress.tar.gz

# Move WordPress files to web root
echo "Installing WordPress files..."
cp -r wordpress/* /var/www/html/
rm -rf wordpress wordpress.tar.gz

# Set up WordPress configuration
echo "Configuring WordPress..."
cd /var/www/html
cp wp-config-sample.php wp-config.php

# Configure database connection
sed -i "s/database_name_here/$DB_NAME/g" wp-config.php
sed -i "s/username_here/$DB_USER/g" wp-config.php
sed -i "s/password_here/$DB_PASSWORD/g" wp-config.php
sed -i "s/localhost/$DB_HOST/g" wp-config.php

# Generate WordPress security keys
echo "Generating WordPress security keys..."
SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config.php

# Set proper file permissions
echo "Setting file permissions..."
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
chmod 600 wp-config.php

# Configure PHP settings for WordPress
echo "Configuring PHP settings..."
cat >> /etc/php.ini << EOF
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
memory_limit = 256M
EOF

# Create WordPress uploads directory
mkdir -p /var/www/html/wp-content/uploads
chown apache:apache /var/www/html/wp-content/uploads
chmod 755 /var/www/html/wp-content/uploads

# Test database connectivity
echo "Testing database connectivity..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "Database connection attempt $attempt of $max_attempts..."
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "Database connection successful!"
        break
    else
        echo "Database connection failed. Retrying in 10 seconds..."
        sleep 10
        ((attempt++))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "ERROR: Could not connect to database after $max_attempts attempts"
    exit 1
fi

# Create a simple health check endpoint
echo "Creating health check endpoint..."
cat > /var/www/html/health.php << EOF
<?php
// Simple health check
\$db_host = '$DB_HOST';
\$db_user = '$DB_USER';
\$db_pass = '$DB_PASSWORD';
\$db_name = '$DB_NAME';

try {
    \$pdo = new PDO("mysql:host=\$db_host;dbname=\$db_name", \$db_user, \$db_pass);
    \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Test database connection
    \$stmt = \$pdo->query('SELECT 1');
    
    http_response_code(200);
    echo json_encode([
        'status' => 'healthy',
        'timestamp' => date('Y-m-d H:i:s'),
        'database' => 'connected'
    ]);
} catch(PDOException \$e) {
    http_response_code(503);
    echo json_encode([
        'status' => 'unhealthy',
        'timestamp' => date('Y-m-d H:i:s'),
        'database' => 'disconnected',
        'error' => \$e->getMessage()
    ]);
}
?>
EOF

# Restart Apache to apply all configurations
echo "Restarting Apache..."
systemctl restart httpd

# Install and configure CloudWatch agent (optional)
if command -v amazon-cloudwatch-agent-ctl &> /dev/null; then
    echo "Configuring CloudWatch agent..."
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/apache/access",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/apache/error",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF
    
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -s \
        -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
fi

# Final status check
echo "Performing final status check..."
if systemctl is-active --quiet httpd; then
    echo "SUCCESS: Apache is running"
else
    echo "ERROR: Apache is not running"
    systemctl status httpd
fi

if curl -f http://localhost/ > /dev/null 2>&1; then
    echo "SUCCESS: WordPress is accessible"
else
    echo "WARNING: WordPress may not be fully accessible yet"
fi

echo "WordPress installation completed at $(date)"
echo "You can now access WordPress through the load balancer URL"
echo "Database Host: $DB_HOST"
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
