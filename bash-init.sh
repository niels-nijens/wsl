#!/bin/bash

# Ensure that systemd has PID 1 by entering the WSL genie.
if [[ ! -v INSIDE_GENIE ]]; then
  echo "Starting WSL genie..."
  exec /usr/bin/genie -s
fi

# Activate GPG.
export GPG_TTY=`tty`

# Start SSH agent (when not already running).
if pidof ssh-agent > /dev/null
then
  export SSH_AGENT_PID=$(pidof ssh-agent | awk '{print $NF}')
  export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
else
  rm -f $HOME/.ssh/agent.sock
  eval $(ssh-agent -a $HOME/.ssh/agent.sock)
  ssh-add ~/.ssh/id_ed25519
fi
