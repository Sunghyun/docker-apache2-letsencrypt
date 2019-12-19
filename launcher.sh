#!/bin/bash
echo "----------------------------------------------------------------"
echo " Running $0 to check for letsencrypt certificate and renewal"
echo "--------------------------------------------------------------- -"
privateKeyHome="/etc/letsencrypt/live/$(hostname -f)"
privateKeyFile="$privateKeyHome/privkey.pem"
renewalFlags=""
if [ ! -z $LETS_ENCRYPT_FORCE_RENEWAL ]; then
  renewalFlags="$renawalFlags --force-renewal"
fi

echo "Checking if certificate [$privateKeyFile] exist )."
if [ ! -f $privateKeyFile ]; then
  echo "Certificate file [$privateKeyFile] does not exist"

  if [[ ! "x$LETS_ENCRYPT_DOMAINS" == "x" ]]; then
    DOMAIN_CMD="-d $(echo $LETS_ENCRYPT_DOMAINS | sed 's/,/ -d /')"
    cmd="certbot -n certonly --no-self-upgrade --agree-tos --standalone -m \"$LETS_ENCRYPT_EMAIL\" -d $(hostname -f) $DOMAIN_CMD"
    echo "Requesting certificates for [$cmd]"
    eval $cmd
    echo "Linking certificate folder"
    ln -s /etc/letsencrypt/live/$(hostname -f) /etc/letsencrypt/certs
  else
    echo "LETS_ENCRYPT_DOMAINS not defined, skipping certificate creation"
  fi
else
  echo "Certificate file [$privateKeyFile] exist, checking for renewal"
  cmd="certbot renew --no-random-sleep-on-renew --apache --no-self-upgrade $renewalFlags"
  echo "Requesting certificate renawal: [$cmd]"
  eval $cmd
fi

echo "Launching apache2."
apache2 -DFOREGROUND
