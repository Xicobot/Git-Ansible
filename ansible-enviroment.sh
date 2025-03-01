#!/bin/bash

# Prompt for server IP addresses
read -p "Enter the server IPs separated by spaces: " -a SERVERS

# Prompt for remote username
read -p "Enter the remote username: " REMOTE_USER

# Prompt for the remote user password
read -s -p "Enter the password for $REMOTE_USER: " REMOTE_PASS
echo ""

# SSH key file
SSH_KEY="$HOME/.ssh/id_rsa"

# Check if the SSH key exists, generate one if it does not
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating SSH key for the user..."
    ssh-keygen -t rsa -b 4096 -N "" -f "$SSH_KEY"
    echo "SSH key generated at $SSH_KEY"
else
    echo "SSH key already exists at $SSH_KEY"
fi

# Function to install Ansible on the local machine
install_ansible_local() {
    echo "Installing Ansible on the local machine..."
    sudo apt update && sudo apt install -y ansible sshpass
    echo "Ansible successfully installed on the local machine."
}

# Function to copy SSH key to the remote server
copy_ssh_key() {
    local server="$1"
    echo "Copying SSH key to server $server..."
    sshpass -p "$REMOTE_PASS" ssh-copy-id -o StrictHostKeyChecking=no "$REMOTE_USER@$server"
}

# Function to install Ansible on the remote server
install_ansible_remote() {
    local server="$1"
    echo "Installing Ansible on $server..."
    ssh "$REMOTE_USER@$server" "sudo apt update && sudo apt install -y ansible"
    echo "Ansible installed on $server."
}

# Install Ansible on the local machine
install_ansible_local

# Iterate over the list of servers to configure SSH and install Ansible
for SERVER in "${SERVERS[@]}"; do
    copy_ssh_key "$SERVER"
    install_ansible_remote "$SERVER"
done

# Verify connectivity with Ansible
echo "Checking connectivity with servers..."
ansible all -m ping -u "$REMOTE_USER"

echo "Installation completed. You can now use Ansible."
