#!/usr/bin/env bash
# Author:               josvo
# Date:                 2017-09-25
# Name:                 addburpclient.sh
# Description:          Automatically adds a burp client that tries to connect

# **************************** Files and constantss ***************************
LOGFILE="/var/log/burp/burp_addclient.log"
BURP_LOGFILE="/var/log/burp/burp.log"
BURP_CLIENT_CONF_DIR="/etc/burp/clientconfdir"

PASSWORD="***password***"

# ******************************** functions **********************************
mylog()
{
  echo >>$LOGFILE "$@"
}

# ****************************** Script start *********************************
# Watch logfile but use only last line if restartet; automatically follow on file recreateion
# for example on logrotate
tail -F -n0 $BURP_LOGFILE | while read LOGLINE
do
  SEARCHSTRING="could not open '$BURP_CLIENT_CONF_DIR/(.*)'"
  if [[ ${LOGLINE} =~ $SEARCHSTRING ]]; then
    echo "password = $PASSWORD" > $BURP_CLIENT_CONF_DIR/${BASH_REMATCH[1]}
    DATE=`date +"%b %d %H:%M:%S"`
    mylog "$DATE New Client ${BASH_REMATCH[1]} activated."
  fi
done
