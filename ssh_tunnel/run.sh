#!/usr/bin/with-contenv bashio
set -e

CONFIG_PATH=/data/options.json

HOSTNAME=$(jq --raw-output ".hostname" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
SSH_KEY=$(cat << EOF
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----
EOF
)

REMOTE_FORWARDING=$(jq --raw-output ".remote_forwarding[]" $CONFIG_PATH)

OTHER_SSH_OPTIONS=$(jq --raw-output ".other_ssh_options" $CONFIG_PATH)

#

if [ -z "$HOSTNAME" ]; then
  bashio::log.error "Please set 'hostname' in your config to the address of your remote server"
  exit 1
fi

#

COMMAND="/usr/bin/autossh "\
" -M 0 -N "\
"-o ServerAliveInterval=30 "\
"-o ServerAliveCountMax=3 "\
"-o StrictHostKeyChecking=no "\
"-o ExitOnForwardFailure=yes "\
"-p ${SSH_PORT} -t -t "\
"-i /dev/stdin "\
"${USERNAME}@${HOSTNAME}"

if [ ! -z "${REMOTE_FORWARDING}" ]; then
  while read -r LINE; do
    COMMAND="${COMMAND} -R ${LINE}"
  done <<< "${REMOTE_FORWARDING}"
fi

COMMAND="${COMMAND} ${OTHER_SSH_OPTIONS}"

bashio::log.info "Executing command: ${COMMAND}"
/usr/bin/autossh -V

# Execute
exec echo ${KEY} | ${COMMAND}
