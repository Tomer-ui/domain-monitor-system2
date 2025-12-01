#!/bin/bash
if [ ! -f "my-key.pem" ]; then
    echo "ERROR: my-key.pem missing!"
    exit 1
fi
chmod 400 my-key.pem

echo "--- 0. SECRETS ---"
chmod +x setup_secrets.sh
./setup_secrets.sh

echo "--- 1. TERRAFORM ---"
cd terraform
terraform init
terraform apply -auto-approve
cd ..

echo "--- 2. SLEEPING (30s) ---"
sleep 30

echo "--- 3. ANSIBLE ---"
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --vault-password-file .vault_pass.txt

echo "--- DONE ---"