#/bin/bash

template="$1"

docker run --rm \
  -e PACKER_LOG=1 \
  -e PACKER_LOG_PATH="packer-docker.log" \
  -it \
  --privileged \
  --cap-add=ALL -v /lib/modules:/lib/modules \
  -v `pwd`:/opt/ \
  -v $HOME/.profile:/root/.profile \
  -w /opt/ goffinet/packer-qemu build ${template}
