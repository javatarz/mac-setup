#!/bin/sh

echo
echo "> Secure Manual File Transfer"

# Check if this is the new machine or old machine
read -p "Are you on the NEW machine (receiver)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo ">> Running receiver script on NEW machine..."
    python3 scripts/transfer/transfer_receiver.py
else
    echo ">> Running sender script on OLD machine..."
    python3 scripts/transfer/transfer_sender.py
fi
