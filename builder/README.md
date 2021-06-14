# How-to

How-to create a one-time cloud server to build all the images of this reposirory and push them to an object storage.


```bash
sudo apt update && sudo apt -y upgrade
sudo apt -y install firewalld fail2ban git
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo -y apt install terraform
sudo curl -o /usr/local/bin/scw -L "https://github.com/scaleway/scaleway-cli/releases/download/v2.3.1/scw-2.3.1-linux-x86_64"
sudo chmod +x /usr/local/bin/scw
echo export SCW_ACCESS_KEY="<SCALEWAY ACCESS KEY>" >> ~/.profile
echo export SCW_SECRET_KEY="<SCALEWAY SECRET KEY>" >> ~/.profile
echo export SCW_DEFAULT_ORGANIZATION_ID="<SCALEWAY ORGANIZATION ID>" >> ~/.profile
echo export AWS_ACCESS_KEY=$SCW_ACCESS_KEY >> ~/.profile
echo export AWS_SECRET_KEY=$SCW_SECRET_KEY >> ~/.profile
sudo reboot
```

## all-in-one

This example is based on the Scaleway provider and can publish 12 images in 35 minutes.

```bash
#!/bin/bash

TO_EMAIL="test@test.tf"
sudo apt update && sudo apt -y install ssmtp zip mpack
TIMESTAMP="$(date -I)-$(date +%s)"
git clone https://github.com/goffinet/packer-kvm /opt/packer-kvm-$TIMESTAMP
cd /opt/packer-kvm-$TIMESTAMP/builder/all-in-one
terraform init
mkdir -p /opt/log/packer
source ~/.profile
TF_LOG="TRACE" TF_LOG_PATH="/opt/log/packer/builder-apply-$TIMESTAMP.log" terraform apply -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_KEY=$AWS_SECRET_KEY" -auto-approve
sleep 300
TF_LOG="TRACE" TF_LOG_PATH="/opt/log/packer/builder-destroy-$TIMESTAMP.log" terraform destroy -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_KEY=$AWS_SECRET_KEY" -auto-approve
sleep 60
TF_LOG="TRACE" TF_LOG_PATH="/opt/log/packer/builder-destroy-$TIMESTAMP.log" terraform destroy -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_KEY=$AWS_SECRET_KEY" -auto-approve
sleep 30
TF_LOG="TRACE" TF_LOG_PATH="/opt/log/packer/builder-destroy-$TIMESTAMP.log" terraform destroy -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_KEY=$AWS_SECRET_KEY" -auto-approve
sleep 10
TF_LOG="TRACE" TF_LOG_PATH="/opt/log/packer/builder-destroy-$TIMESTAMP.log" terraform destroy -var="AWS_ACCESS_KEY=$AWS_ACCESS_KEY" -var="AWS_SECRET_KEY=$AWS_SECRET_KEY" -auto-approve
zip /opt/log/packer-kvm-build-$TIMESTAMP.zip /opt/log/packer/*-$TIMESTAMP.log
mpack -s "[Packer KVM Factory]: Report logs" /opt/log/packer-kvm-build-$TIMESTAMP.zip $TO_EMAIL

```
