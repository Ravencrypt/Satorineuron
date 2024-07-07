#!/bin/bash

# Create Cronjob to restart Docker & Service
RESTART_SCRIPT="/usr/local/bin/restart_satorineuron_and_service.sh"
bash -c "echo '#!/bin/bash' > $RESTART_SCRIPT"
bash -c "echo 'docker restart satorineuron' >> $RESTART_SCRIPT"
bash -c "echo 'sleep 300' >> $RESTART_SCRIPT"
bash -c "echo 'systemctl restart satori.service' >> $RESTART_SCRIPT"
chmod +x $RESTART_SCRIPT

# Set up the cron job to run the script at 6:00 PM every day
(crontab -l 2>/dev/null; echo '0 18 * * * /bin/bash /usr/local/bin/restart_satorineuron_and_service.sh') | crontab -

echo "Cron job setup completed successfully."
