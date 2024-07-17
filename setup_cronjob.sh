#!/bin/bash

# Create Cronjob to restart Docker & Service
RESTART_SCRIPT="/usr/local/bin/restart_satorineuron_and_service.sh"
sudo bash -c "echo '#!/bin/bash' > $RESTART_SCRIPT"
sudo bash -c "echo 'docker stop satorineuron' >> $RESTART_SCRIPT"
sudo chmod +x $RESTART_SCRIPT

# Set up the cron job to run the script at 6:00 PM every day
(crontab -l 2>/dev/null; echo '0 18 * * * /bin/bash /usr/local/bin/restart_satorineuron_and_service.sh') | crontab -

echo "Cron job setup completed successfully."

