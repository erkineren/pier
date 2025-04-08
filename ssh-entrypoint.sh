#!/bin/bash
set -e

# Set password from environment variable if provided
if [ ! -z "$SSH_PASSWORD" ]; then
    echo "appuser:$SSH_PASSWORD" | chpasswd
fi

# Set bash as the default shell for appuser
chsh -s /bin/bash appuser

# Ensure proper permissions for SSH directories
mkdir -p /home/appuser/.ssh
chmod 700 /home/appuser/.ssh
chown -R appuser:appuser /home/appuser/.ssh

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Enable SSH TCP forwarding and other required settings
sed -i 's/#AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
sed -i 's/#GatewayPorts no/GatewayPorts yes/g' /etc/ssh/sshd_config
sed -i 's/#X11Forwarding no/X11Forwarding yes/g' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding yes/g' /etc/ssh/sshd_config

# Set proper permissions for host keys
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub

# Start SSH service
service ssh start

# Execute the original entrypoint script
exec /usr/local/bin/docker-entrypoint.sh "$@"
