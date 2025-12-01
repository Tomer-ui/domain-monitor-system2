#!/bin/bash
VAULT_PASS_FILE=".vault_pass.txt"
SECRETS_FILE="ansible/secrets.yml"
TEMP_FILE="ansible/secrets_temp.yml"
ENV_FILE="local_secrets.env"

# Safety Trap
trap 'rm -f $TEMP_FILE' EXIT

# 1. Load Secrets from .env file
if [ -f "$ENV_FILE" ]; then
    echo "--- Loading secrets from $ENV_FILE ---"
    source $ENV_FILE
else
    echo "ERROR: $ENV_FILE is missing!"
    echo "Please create it with DOCKER_HUB_USER and DOCKER_HUB_PASS"
    exit 1
fi

# 2. Generate Vault Key if needed
if [ ! -f "$VAULT_PASS_FILE" ]; then
    openssl rand -base64 20 > $VAULT_PASS_FILE
fi

# 3. Create Ansible Secrets
if [ ! -f "$SECRETS_FILE" ]; then
    JENKINS_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9')
    
    cat <<EOF > $TEMP_FILE
my_jenkins_pass: "$JENKINS_PASS"
docker_hub_user: "$DOCKER_HUB_USER"
docker_hub_pass: "$DOCKER_HUB_PASS"
EOF

    ansible-vault encrypt $TEMP_FILE \
        --vault-password-file $VAULT_PASS_FILE \
        --output $SECRETS_FILE
    
    echo "✅ Secrets created successfully."
    echo "JENKINS ADMIN PASS: $JENKINS_PASS"
else
    echo "Secrets file already exists."
fi