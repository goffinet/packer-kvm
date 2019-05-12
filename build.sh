#/bin/bash

template="$1"

docker run --rm                                     \
  -e PACKER_LOG=1                                   \
  -e PACKER_LOG_PATH="$1-packer-docker.log"         \
  -it                                               \
  --privileged                                      \
  --cap-add=ALL -v /lib/modules:/lib/modules        \
  -v `pwd`:/opt/                                    \
  -v $HOME/.ssh/id_rsa:/root/.ssh/id_rsa            \
  -v $HOME/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub    \
  -w /opt/ goffinet/packer-qemu build ${template}
