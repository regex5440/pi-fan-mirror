#!/bin/bash

# DON'T CHANGE THESE VARIABLES
# If needed to, ensure they are in sync with service file.
SCRIPT_DEST=/usr/local/bin
SCRIPT_NAME=fan_led_sync.sh

SERVICE_DEST=/etc/systemd/system
SERVICE_NAME=fan_led_sync.service

echo "Setting up to $SCRIPT_DEST"

sudo cp ./src/$SCRIPT_NAME "$SCRIPT_DEST/$SCRIPT_NAME"
sudo chmod +x $SCRIPT_DEST/$SCRIPT_NAME

echo "Configuring system service"
sudo cp ./src/$SERVICE_NAME "$SERVICE_DEST/$SERVICE_NAME"
sudo systemctl daemon-reload
sudo systemctl enable --now $SERVICE_NAME

echo "Successfully Configured!"