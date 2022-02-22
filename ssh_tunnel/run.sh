#!/usr/bin/with-contenv bashio
set -e

CONFIG_PATH=/data/options.json
#KEY_PATH=/data/ssh_keys

HOSTNAME=$(jq --raw-output ".hostname" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
KEY=$(jq --raw-output ".key" $KEY)

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
