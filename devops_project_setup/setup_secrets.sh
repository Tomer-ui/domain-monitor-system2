#!/bin/bash
VAULT_PASS_FILE=".vault_pass.txt"
SECRETS_FILE="ansible/secrets.yml"
TEMP_FILE="ansible/secrets_temp.yml"

# Safety Trap: Delete temp file if script crashes
trap 'rm -f $TEMP_FILE' EXIT

if [ ! -f "$VAULT_PASS_FILE" ]; then
    echo "--- Generating Vault Key ---"
    openssl rand -base64 20 > $VAULT_PASS_FILE
fi

if [ ! -f "$SECRETS_FILE" ]; then
    echo "--- Generating Jenkins Admin Password ---"
    JENKINS_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9')
    
    cat <<EOF > $TEMP_FILE
my_jenkins_pass: "$JENKINS_PASS"
EOF

    ansible-vault encrypt $TEMP_FILE \
        --vault-password-file $VAULT_PASS_FILE \
        --output $SECRETS_FILE
    
    echo "✅ Secrets created."
    echo "====================================================="
    echo "⚠️  SAVE THIS PASSWORD: $JENKINS_PASS"
    echo "====================================================="
else
    echo "Secrets file already exists."
fi