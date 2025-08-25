#!/bin/sh

echo
echo "> Secure Manual File Transfer"
pip install requests

echo "Select machine type:"
echo "1) OLD machine (sender)"
echo "2) NEW machine (receiver)"
echo "3) Skip"
read -p "Enter choice [1/2/3]: " choice

case "$choice" in
    1)
        echo ">> Running sender script on OLD machine..."
        python3 scripts/transfer/transfer_sender.py
        ;;
    2)
        echo ">> Running receiver script on NEW machine..."
        python3 scripts/transfer/transfer_receiver.py
        ;;
    3)
        echo ">> Skipping transfer scripts."
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
