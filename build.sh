#/bin/bash

template="$1"

3_docker_docker-compose_installation () {
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
if [ -f /etc/debian_version ]; then
apt-get update && apt-get -y install python3-pip
elif [ -f /etc/redhat-release ]; then
yum -y install python3-pip
fi
pip3 install docker-compose
}

which docker || 3_docker_docker-compose_installation
docker run --rm \
  -e PACKER_LOG=1 \
  -e PACKER_LOG_PATH="packer-docker.log" \
  -it \
  --privileged \
  --cap-add=ALL -v /lib/modules:/lib/modules \
  -v `pwd`:/opt/ \
  -e AWS_ACCESS_KEY=$AWS_ACCESS_KEY \
  -e AWS_SECRET_KEY=$AWS_SECRET_KEY \
  -w /opt/ goffinet/packer-qemu build ${template}
