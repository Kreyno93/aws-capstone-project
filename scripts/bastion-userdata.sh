#!/bin/bash

# Bastion Host Setup Script for Amazon Linux 2
# This script configures the bastion host with necessary tools and security settings

set -e  # Exit on any error

# Logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting bastion host setup at $(date)"

# Update system packages
echo "Updating system packages..."
yum update -y

# Install essential tools
echo "Installing essential tools..."
yum install -y \
    wget \
    curl \
    unzip \
    git \
    htop \
    tree \
    mysql \
    telnet \
    nc \
    tcpdump \
    vim \
    nano

# Install AWS CLI v2 (if not already installed)
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Install Session Manager plugin for AWS CLI
echo "Installing Session Manager plugin..."
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
yum install -y session-manager-plugin.rpm
rm -f session-manager-plugin.rpm

# Configure SSH for better security
echo "Configuring SSH security..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# SSH hardening
cat >> /etc/ssh/sshd_config << EOF

# Bastion Host Security Configuration
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60
EOF

# Restart SSH service
systemctl restart sshd

# Configure automatic security updates
echo "Configuring automatic security updates..."
yum install -y yum-cron
systemctl enable yum-cron
systemctl start yum-cron

# Configure yum-cron for security updates only
sed -i 's/update_cmd = default/update_cmd = security/' /etc/yum/yum-cron.conf
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf

# Set up log rotation for SSH logs
echo "Configuring log rotation..."
cat > /etc/logrotate.d/ssh-bastion << EOF
/var/log/secure {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 600 root root
    postrotate
        /bin/kill -HUP \`cat /var/run/rsyslogd.pid 2> /dev/null\` 2> /dev/null || true
    endscript
}
EOF

# Create a welcome message
echo "Creating welcome message..."
cat > /etc/motd << 'EOF'
================================================================================
                          AWS Capstone Project - Bastion Host
================================================================================

This is a bastion host for secure access to private resources.

Available tools:
- AWS CLI v2
- Session Manager Plugin
- MySQL Client
- Network utilities (telnet, nc, tcpdump)
- Text editors (vim, nano)
- System monitoring (htop)

Security reminders:
- Only use this host for administrative purposes
- Do not store sensitive data on this instance
- All activities are logged and monitored
- Use proper SSH key management

For support, contact the DevOps team.

================================================================================
EOF

# Create useful aliases for ec2-user
echo "Setting up user aliases..."
cat >> /home/ec2-user/.bashrc << 'EOF'

# Bastion Host Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# AWS specific aliases
alias awswhoami='aws sts get-caller-identity'
alias awsregion='aws configure get region'

# Network utilities
alias ports='netstat -tulanp'
alias listening='netstat -tlnp'
alias connections='netstat -tup'

# System monitoring
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias cpuinfo='lscpu'
alias diskusage='df -H'

# Quick navigation to common directories
alias logs='cd /var/log'
alias ssh-config='cd /etc/ssh'

# Function to test database connectivity
test-db() {
    if [ $# -eq 0 ]; then
        echo "Usage: test-db <hostname> [port]"
        echo "Example: test-db mydb.cluster-xyz.us-west-2.rds.amazonaws.com 3306"
        return 1
    fi
    
    local host=$1
    local port=${2:-3306}
    
    echo "Testing connection to $host:$port..."
    if nc -z -w5 $host $port; then
        echo "✓ Connection successful to $host:$port"
    else
        echo "✗ Connection failed to $host:$port"
    fi
}

# Function to show system information
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime)"
    echo "Load Average: $(cat /proc/loadavg)"
    echo "Memory Usage: $(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2 }')"
    echo "Disk Usage: $(df -h | awk '$NF=="/"{printf "%s", $5}')"
    echo "Network Interfaces:"
    ip addr show | grep -E '^[0-9]+:' | awk '{print "  " $2}' | sed 's/://'
}

EOF

# Set proper ownership for ec2-user files
chown ec2-user:ec2-user /home/ec2-user/.bashrc

# Configure CloudWatch agent for bastion monitoring (optional)
if command -v amazon-cloudwatch-agent-ctl &> /dev/null; then
    echo "Configuring CloudWatch agent for bastion host..."
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "/aws/ec2/bastion/secure",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/bastion/messages",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "Bastion/CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 300
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 300,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 300
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 300
            }
        }
    }
}
EOF
    
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -s \
        -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
fi

# Final security check
echo "Performing final security check..."
if systemctl is-active --quiet sshd; then
    echo "SUCCESS: SSH service is running"
else
    echo "ERROR: SSH service is not running"
    systemctl status sshd
fi

# Display final status
echo "Bastion host setup completed at $(date)"
echo "Instance is ready for administrative access"
echo "SSH service status: $(systemctl is-active sshd)"
echo "Available tools: AWS CLI, MySQL client, network utilities"
echo "Security features: Hardened SSH, automatic updates, logging"
