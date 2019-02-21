#!/bin/sh


if [ -n "$CFG" ]
then
  echo "$CFG" > /etc/git2consul.d/config.json
else
  sed -i -e "s@GITREPO@$GIT_REPO@" -e "s@NAMESPACE@$NAMESPACE@" /etc/git2consul.d/config.json
fi



mkdir ~/.ssh
cp /etc/ssh-key-secret/ssh-publickey ~/.ssh/id_rsa
cp /etc/ssh-key-secret/ssh-privatekey ~/.ssh/id_rsa.pub
echo -e "StrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" > ~/.ssh/config
chmod 700 -R ~/.ssh

echo -e "$(date) starting git2consul. found these env vars: \nCFG:$CFG\nIDPUB:$IDPUB\nGIT_REPO:$GIT_REPO\nNAMESPACE:$NAMESPACE\nCONSUL_ENDPOINT:$CONSUL_ENDPOINT\nCONSUL_PORT:$CONSUL_PORT"

while true
do
  /usr/bin/node /usr/lib/node_modules/git2consul $@ --config-file /etc/git2consul.d/config.json
done

