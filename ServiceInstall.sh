#!/usr/bin/bash
# Copyright (c) 2023, 2024, 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

MON_SERVICE="LEGENDLab-Monitoring"
WEB_SERVICE="LEGENDLab-Webgen"

cat <<EOF > /etc/systemd/system/${MON_SERVICE}.service
[Unit]
Description=${MON_SERVICE} Service

[Service]
ExecStart=$SCRIPT_DIR/Monitor.sh
EOF

cat <<EOF > /etc/systemd/system/${WEB_SERVICE}.service
[Unit]
Description=${WEB_SERVICE} Service

[Service]
ExecStart=$SCRIPT_DIR/WebGen.sh
EOF

cat <<EOF > /etc/systemd/system/${MON_SERVICE}.timer
[Unit]
Description=Run ${MON_SERVICE} service every 2 minutes of the hour

[Timer]
OnCalendar=*-*-* *:0/2:00
Unit=${MON_SERVICE}.service

[Install]
WantedBy=timers.target
EOF

cat <<EOF > /etc/systemd/system/${WEB_SERVICE}.timer
[Unit]
Description=Run ${WEB_SERVICE} service every minute of the hour

[Timer]
OnCalendar=*-*-* *:0/1:00
Unit=${WEB_SERVICE}.service

[Install]
WantedBy=timers.target
EOF

chmod +x $SCRIPT_DIR/Monitor.sh
chmod +x $SCRIPT_DIR/WebGen.sh

systemctl daemon-reload

systemctl enable ${WEB_SERVICE}.timer
systemctl start ${WEB_SERVICE}.timer

echo -e "Services and timers installed:"
echo -e "\t ${WEB_SERVICE}.timer"
echo -e "\t ${MON_SERVICE}.timer"
echo -e "\n It is necessary to start the monitoring service manually"
echo -e "\t systemctl start ${MON_SERVICE}.timer"
echo -e "\n################################################################################"
echo -e "Start monitoring service with:  systemctl start ${MON_SERVICE}.timer"
echo -e "Stop monitoring service with:   systemctl stop ${MON_SERVICE}.timer"
echo -e "Monitoring Service status with: systemctl status ${MON_SERVICE}.timer"
echo -e "################################################################################"
echo -e "Start website generating service with:  systemctl start ${WEB_SERVICE}.timer"
echo -e "Stop website generating service with:   systemctl stop ${WEB_SERVICE}.timer"
echo -e "Website generating Service status with: systemctl status ${WEB_SERVICE}.timer"
echo -e "################################################################################"
