# burp-scripts
A collection of scripts for burp backup

# deleteburpclient.sh
Description:
- Revokes a client certificate, deletes config files, certificates and backup data

Install: 
- Copy the file to the preferred location, eg /usr/local/bin
- Change directories on top of the script if needed
- Make it executable with chmod +x deleteburpclient.sh
- Run it with deleteburpclient.sh

How it works:
- The script follows the steps in http://burp.grke.org/docs/add-remove.html "Revoking a client"
- You are asked for the client name (= name of the client file in clientconfdir)
- The certificate will be revoked
- Additionally, the certificate files and the client configuration file will be removed
- At last, the backup data is removed
- Every step must be confirmed so you don't accidentially loose data

# addburpclient.sh
- Description: Checks the logfile and automatically creates a config file for a new client and therefore allowing it to backup without further admin interaction

Install:
- Copy the file to your preferred locations, eg /usr/local/bin
- Change the password on top of the script and also the the directories / files if needed
- Make the script executable with chmod +x addburpclient.sh
- You will need a own logfile for burp, see here how to to that: https://github.com/qm2k/burp_integration
- Additionally, you will need a systemd file to control the script; copy the addburpclient.service to /etc/systemd/system/
- Start the script and enable it on startup:
  - ```systemctl start addburpclient```
  - ```systemctl enable addburpclient```
- When you install a new client, you have to set the password specified in the script
- From the client, connect with "burp -a l" twice
- The first connection will fail, the second will succeed

