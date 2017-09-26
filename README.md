# burp-scripts
A collection of scripts for burp backup

# deleteburpclient.sh
Description:
- revokes a client certificate, deletes config files, certificates and backup data

Install: 
- copy the file to the preferred location, eg /usr/local/bin
- change directories on top of the script if needed
- make it executable with chmod +x deleteburpclient.sh
- run it with deleteburpclient.sh

How it works:
- The script follows the steps in http://burp.grke.org/docs/add-remove.html "Revoking a client"
- You are asked for the client name (= name of the client file in clientconfdir)
- The certificate will be revoked
- Additionally, the certificate files and the client configuration file will be removed
- At last, the backup data is removed
- Every step must be confirmed so you don't accidentially loose data
