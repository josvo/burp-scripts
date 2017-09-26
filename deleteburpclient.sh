#!/usr/bin/env bash
# Author:               josvo
# Date:                 2017-09-25
# Name:                 deleteburpclient.sh
# Description:          Revokes a client certificate, deletes configs and backups


# **************************** Files and constantss ***************************
BURP_CLIENT_CONF_DIR="/etc/burp/clientconfdir"
BURP_CA_DIR="/etc/burp/CA"
BURP_DATA_DIR="/var/spool/burp"


# ******************************** functions **********************************
check_cert_revocation()
{
  # We assume there is only one valid certificat of that name - the last one
  index=`grep -w "$clientname" $BURP_CA_DIR/index.txt | tail -1`
  searchstring=".*\s+([0-9a-fA-F]+)\s+\w+\s\/CN=(\w+)"
  if [[ $index =~ $searchstring ]]; then
    certnumber=${BASH_REMATCH[1]}
  else
    echo -e "\e[31mNo certificate found for client \"$clientname\". Is it spelled correctly?\e[39m"
    exit
  fi

  revoked=`openssl crl -text -noout -in $BURP_CA_DIR/CA_burpCA.crl | grep -A1 "Serial Number: $certnumber"`
  searchstring="Revocation Date: (.*)"
  if [[ $revoked =~ $searchstring ]]; then
    revocation_date=${BASH_REMATCH[1]}
  fi
}

delete_config_files()
{
  if [ -e $BURP_CA_DIR/$clientname.crt ] || [ -e $BURP_CA_DIR/$clientname.csr ] || [ -e $BURP_CLIENT_CONF_DIR/$clientname ]; then
    while true; do
    echo -en "\e[32mDo you want to delete the config files and certificates? [Y/n]: \e[39m"
    read ans
    case $ans in
      n|N)
        break;;
      y|Y|"")
        echo -n "Deleting config files... "
        rm -f $BURP_CA_DIR/$clientname.*
        rm -f $BURP_CLIENT_CONF_DIR/$clientname
        echo "done"
        break;;
    esac
  done
  else
    echo "Config files already deleted."
  fi
}

delete_data()
{
  if [ -e $BURP_DATA_DIR/$clientname ]; then
    while true; do
    echo -en "\e[32mDo you want to delete the clients backup data? [y/N]: \e[39m"
    read ans
    case $ans in
      n|N|"")
        break;;
      y|Y)
        echo -n "Deleting backup data... "
        rm -r $BURP_DATA_DIR/$clientname
        echo "done"
        break;;
    esac
  done
  else
    echo "Backup data already deleted."
  fi
}


# ****************************** Script start *********************************
echo -en "\e[32mPlease input client to revoke: \e[39m"
read clientname
check_cert_revocation

if [ -n "$revocation_date"  ]; then
  echo -e "Client \"$clientname\" already revoked on ${BASH_REMATCH[1]}"
else
  while true; do
    echo -en "\e[32mRevoking certificate \"$clientname\". OK? [y/N]: \e[39m"
    read ans
    case $ans in
      n|N|"")
        echo -en "\e[31mCertificate for \"$clientname\" not revoked. Exiting.\e[39m\n"
        exit
        break;;
      y|Y)
        # Revoke certifikate
        burp_ca --name burpCA --revoke $certnumber >/dev/null 2>&1

        # Regenerate crl
        burp_ca --name burpCA --crl >/dev/null 2>&1

        # Check if certificate is revoked successfully
        check_cert_revocation
        if [ -n "$revocation_date"  ]; then
          echo "Client \"$clientname\" successfully revoked on ${BASH_REMATCH[1]}"
        fi
        break;;
    esac
  done
fi

# Delete config files
delete_config_files

# Delete backup data
delete_data

exit
