#!/usr/bin/bash
# Copyright (c) 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.

MON_SERVICE="LEGENDLab-Monitoring"
WEB_SERVICE="LEGENDLab-Webgen"

systemctl stop ${MON_SERVICE}.service
systemctl stop ${WEB_SERVICE}.service

systemctl disable ${MON_SERVICE}.service
systemctl disable ${WEB_SERVICE}.service

rm /etc/systemd/system/${MON_SERVICE}.service
rm /etc/systemd/system/${WEB_SERVICE}.service

rm /etc/systemd/system/${MON_SERVICE}.timer
rm /etc/systemd/system/${WEB_SERVICE}.timer

systemctl daemon-reload

echo "Services and timers uninstalled!"