#!/bin/bash

# Set non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Update machine
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Install Docker
# Add Docker's official GPG key
apt update
DEBIAN_FRONTEND=noninteractive apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Install Docker packages & requirements
DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin zip unzip wget curl python3-venv

# Download software from GitHub
cd ~
wget -P ~/ https://github.com/SatoriNetwork/Installer/archive/main.zip

# Unzip and remove folder
unzip ~/main.zip
cp -r ~/Installer-main/linux/.satori ~/
rm -rf ~/Installer-main
rm ~/main.zip
cd ~/.satori

# Install dependencies
bash install.sh 


# Check if Docker group exists, create if it does not
if ! getent group docker > /dev/null; then
    groupadd docker
fi

# Ensure the user is in the Docker group
usermod -aG docker $USER
# Apply the new group membership
newgrp docker <<EONG
echo "New group session for Docker group applied"
EONG

# Configure and start the service
SERVICE_FILE_PATH="$HOME/.satori/satori.service"
sed -i "s/#User=.*/User=$USER/" "$SERVICE_FILE_PATH"
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$HOME/.satori|" "$SERVICE_FILE_PATH"
cp "$SERVICE_FILE_PATH" /etc/systemd/system/satori.service
systemctl daemon-reload
systemctl enable satori.service
systemctl start satori.service

echo "Please wait 5 Minutes while the Docker container gets build."
sleep 300

# Check if Docker container satorineuron is running
check_docker_container() {
    local container_name=$1
    if [ "$(docker ps -q -f name=$container_name)" ]; then
        echo "Docker container $container_name is running, setup successfull."
    else
        echo "Docker container $container_name is not running, setup failed"
    fi
}
check_docker_container satorineuron

# Create Cronjob to restart Docker & Service
RESTART_SCRIPT="/usr/local/bin/restart_satorineuron_and_service.sh"
bash -c "echo '#!/bin/bash' > $RESTART_SCRIPT"
bash -c "echo 'docker restart satorineuron' >> $RESTART_SCRIPT"
bash -c "echo 'sleep 300' >> $RESTART_SCRIPT"
bash -c "echo 'systemctl restart satori.service' >> $RESTART_SCRIPT"
chmod +x $RESTART_SCRIPT
(crontab -l 2>/dev/null; echo '0 18 * * * /bin/bash /usr/local/bin/restart_satorineuron_and_service.sh') | crontab -') | crontab -

echo "Cron job setup completed successfully"

#Copy Walletfile to Home
cp -r ~/.satori/wallet ~

echo "Setup completed successfully. Make sure to save the Wallet files"
