#/bin/bash

template="$1"
#mode="it"
mode="d"

docker_docker-compose_installation () {
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y install python3-pip
elif [ -f /etc/redhat-release ]; then
yum -y install python3-pip
fi
pip3 install docker-compose
}

if [ $template = "centos8.pkr.hcl" ] ; then
iso_checksum=$(curl -s http://ftp.belnet.be/mirror/ftp.centos.org/8-stream/isos/x86_64/CHECKSUM | grep "SHA256 (CentOS-Stream-8-x86_64-latest-boot.iso) =" | sed 's/^.*= //g')
packer_command="build -var \"iso_checksum=$iso_checksum\" centos8.pkr.hcl"
else
packer_command="build ${template}"
fi

which docker || docker_docker-compose_installation
docker run --rm \
  --name ${template//.pkr.hcl/}-builder \
  -e PACKER_LOG=1 \
  -e PACKER_LOG_PATH="packer-docker.log" \
  -$mode \
  --privileged \
  --cap-add=ALL -v /lib/modules:/lib/modules \
  -v `pwd`:/opt/ \
  -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY \
  -e AWS_SECRET_KEY=$AWS_SECRET_KEY \
  -w /opt/ goffinet/packer-qemu ${packer_command}
