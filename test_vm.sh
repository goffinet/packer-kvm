#!/bin/bash

image=$1
if [ -z "$image" ]; then
  echo "No image specified. Usage: $0 $(cat imagename)"
  exit 1
fi
name=$(echo "$image" | tr -d '0-9.')
## Test the image with kcli.
# Get kcli tool
curl https://raw.githubusercontent.com/karmab/kcli/main/install.sh | sudo bash
# Get the image
kcli download image -P url=http://download.goffinet.org/kvm/${image}.qcow2 ${image}
# Create a test vm
kcli create vm -i ${image} -P memory=2048 -P numcpus=1 -P disks=[50] ${image}
# Test SSH connexion and delete the test VM
chmod 600 sshkeys/id_rsa
sleep 30
if [ "${name}" == "ubuntu" ] ; then
  user="ubuntu"
else
  user="root"
fi
if [ "$(kcli ssh -u ${user} -i sshkeys/id_rsa ${image} 'echo test')" == "test"  ] ; then 
  echo SUCCESS ; kcli delete vm -y ${image}
else 
  echo ERROR ; kcli delete vm -y ${image} ; exit 1
fi
