#!/usr/bin/with-contenv bashio
set -e

CONFIG_PATH=/data/options.json
KEY_PATH=/data/ssh_keys
HOSTNAME=remotessh.voxip.nl
SSH_PORT=22222

USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
SSHUSERNAME=2${USERNAME:1}
PRIV_KEY=$(jq --raw-output ".privkey" $CONFIG_PATH)

#

mkdir -p "$KEY_PATH"
echo -e "-----BEGIN RSA PRIVATE KEY-----\n${PRIV_KEY}\n-----END RSA PRIVATE KEY-----" > "${KEY_PATH}/autossh_rsa_key"
chmod 400 "${KEY_PATH}/autossh_rsa_key"

#

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
"-i ${KEY_PATH}/autossh_rsa_key "\
"hassio_${USERNAME}@${HOSTNAME} "\
"-R ${USERNAME}:127.0.0.1:8123" \
"-R ${SSHUSERNAME}:127.0.0.1:22"


COMMAND="${COMMAND}"

bashio::log.info "Executing command: ${COMMAND}"
/usr/bin/autossh -V

# Execute
exec ${COMMAND}
