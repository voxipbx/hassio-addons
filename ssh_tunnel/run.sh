#!/usr/bin/with-contenv bashio
set -e

CONFIG_PATH=/data/options.json
KEY_PATH=/data/ssh_keys
HOSTNAME=remotessh.voxip.nl
SSH_PORT=22222

USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
PUB_KEY=$(jq --raw-output ".pubkey" $CONFIG_PATH)
PRIV_KEY=$(jq --raw-output ".privkey" $CONFIG_PATH)

#

mkdir -p "$KEY_PATH"
echo "ssh-rsa ${PUB_KEY}" > "${KEY_PATH}/autossh_rsa_key.pub"
chmod 400 "${KEY_PATH}/autossh_rsa_key.pub"
echo "${PRIV_KEY}" > "${KEY_PATH}/autossh_rsa_key"
chmod 400 "${KEY_PATH}/autossh_rsa_key"

bashio::log.info "SHOW ssh-rsa ${PUB_KEY}"
bashio::log.info "SHOW ssh-rsa ${PRIV_KEY}"
 
#

TEST_COMMAND="/usr/bin/ssh "\
"-o BatchMode=yes "\
"-o ConnectTimeout=5 "\
"-o PubkeyAuthentication=no "\
"-o PasswordAuthentication=no "\
"-o KbdInteractiveAuthentication=no "\
"-o ChallengeResponseAuthentication=no "\
"-o StrictHostKeyChecking=no "\
"-p ${SSH_PORT} -t -t "\
"test@${HOSTNAME} "\
"2>&1 || true"

if eval "${TEST_COMMAND}" | grep -q "Permission denied"; then
  bashio::log.info "Testing SSH connection... SSH service reachable on remote server"
else
  eval "${TEST_COMMAND}"
  bashio::log.error "SSH service can't be reached on remote server"
  exit 1
fi

bashio::log.info "Remote server host keys:"
ssh-keyscan -p $SSH_PORT $HOSTNAME || true

#

COMMAND="/usr/bin/autossh "\
" -M 0 -N "\
"-o ServerAliveInterval=30 "\
"-o ServerAliveCountMax=3 "\
"-o StrictHostKeyChecking=no "\
"-o ExitOnForwardFailure=yes "\
"-p ${SSH_PORT} -t -t "\
"-i ${KEY_PATH}/autossh_rsa_key.pub "\
"hassio_${USERNAME}@${HOSTNAME} "\
"-R ${USERNAME}:127.0.0.1:8123"


COMMAND="${COMMAND}"

bashio::log.info "Executing command: ${COMMAND}"
/usr/bin/autossh -V

# Execute
exec ${COMMAND}
