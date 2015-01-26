#!/bin/sh

set -u

# Internal variables
CONFIG_FILE="/etc/driveclient/bootstrap.json"
LOG_FILE="/var/log/driveclient.log"
WAIT_TIME=30
PID=0


#########################################################
# Fill the config with provided values via ENV variables
# Globals:
#   API_HOST
#   API_KEY
#   ACCOUNT_ID
#   USERNAME
#########################################################
function update_config() {
  sed -i "s/API_HOST/$API_HOST/g" $CONFIG_FILE
  sed -i "s/API_KEY/$API_KEY/g" $CONFIG_FILE
  sed -i "s/ACCOUNT_ID/$ACCOUNT_ID/g" $CONFIG_FILE
  sed -i "s/USERNAME/$USERNAME/g" $CONFIG_FILE
  echo "driveclient config updated:"
  cat $CONFIG_FILE && echo
}

#########################################################
# Start the driveclient daemon, wait a bit,
# and check the status.
# Globals:
#   PID
#   WAIT_TIME
#########################################################
function start_driveclient() {
  if [[ $PID != 0 ]]; then 
    echo "Shutting down driveclient..." && kill $PID && sleep 3
  fi

  : > $LOG_FILE && echo # truncate the log file, so we can grep always the current version
  driveclient &
  PID=$!
  
  echo "Backup agent (driveclient) started, pid=$PID"
  sleep $WAIT_TIME && echo
  
  # In case of these strings were not found, the script will exit (set -e)
  if [[ $(grep -i "Could not register the agent" $LOG_FILE) != "" ]]; then echo "Error 1: Could not register the agent. Check your account id, username and/or api key (password)." && exit 1; fi
  if [[ $(grep -i "Successfully authenticated the agent" $LOG_FILE) == "" ]]; then echo "Error 2: Could not authenticate the agent." && exit 1; fi
  if [[ $(grep -i "Configuration parsed and loaded" $LOG_FILE) == "" ]]; then echo "Error 3: Could not parse the config file." && exit 1; fi
}


# tail the log to stdout (in the background), so it can be easily inspected via `docker logs`
touch $LOG_FILE && tail -F $LOG_FILE &

# Generate the config and start the deamon
update_config
start_driveclient

# In case we spot any problems, do restart until they disappear...
while [[ $(grep -i "HTTP(s) error code = 403" $LOG_FILE) != "" ]] || [[ $(grep -i "Could not post an event" $LOG_FILE) != "" ]]; do
  echo "Problems with agent detected. Restaring..."
  start_driveclient
done

echo "Backup agent (driveclient) positive status verified, pid=$PID"
wait $PID
