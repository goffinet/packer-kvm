#!/bin/bash

# Post-processor : doing something with the build image. Here we generate an
# appliance template for GNS3 and we put the image and the template
# to an S3 Bucket by the Scaleway provider for distribution.
# Please adapt it or disable it with the `disable` valued to `true`.

# set variables

disable=false
#disable=true
name=$IMAGE_NAME
version=$IMAGE_VERSION
image="${name}${version}"
path_image="artifacts/qemu/${image}"
#BUCKET=your_bucket
BUCKET=$DESTINATION_SERVER
export AWS_ACCESS_KEY=$AWS_ACCESS_KEY
export AWS_SECRET_KEY=$AWS_SECRET_KEY

if [ $disable == "true"  ] ; then exit ; fi

# go to the artifact folder

cd ${path_image}

# rename the image, check the size, compute md5 and sha1 sum

mv packer-${image} ${image}.qcow2
md5sum_image=$(md5sum ${image}.qcow2 | cut -d' ' -f1)
size_image=$(stat -c %s ${image}.qcow2)
md5sum ${image}.qcow2 > ${image}.qcow2.md5sum
sha256sum ${image}.qcow2 > ${image}.qcow2.sha256sum

# create a https://gns3.com appliance file

cat << EOF > ${image}.gns3a
{
    "name": "${name}${version}",
    "category": "guest",
    "description": "${name} ${version} image",
    "vendor_name": "${name}",
    "vendor_url": "https://download.goffinet.org/kvm",
    "product_name": "${name}",
    "registry_version": 1,
    "status": "stable",
    "maintainer": "goffinet@goffinet.org",
    "maintainer_email": "goffinet@goffinet.org",
    "usage": "Default password is user/root/testtest",
    "port_name_format": "eth{0}",
    "qemu": {
        "adapter_type": "virtio-net-pci",
        "adapters": 1,
        "ram": 512,
        "arch": "x86_64",
        "hda_disk_interface": "virtio",
        "console_type": "telnet",
        "kvm": "require"
    },
    "images": [
        {
            "filename": "${name}${version}.qcow2",
            "version": "${version}",
            "md5sum": "${md5sum_image}",
            "filesize": ${size_image},
            "download_url": "https://download.goffinet.org/kvm/",
            "direct_download_url": "https://download.goffinet.org/kvm/${name}${version}.qcow2"
        }
    ],
    "versions": [
       {
            "name": "${name}${version}",
            "images": {
                "hda_disk_image": "${name}${version}.qcow2"
            }
        }
    ]
}
EOF

# Push image to S3 bucket

# Install python3-pip
if [ -f /etc/debian_version ]; then
apt update && apt -y install python3-pip
fi
pip3 install awscli --upgrade
pip3 install awscli-plugin-endpoint --upgrade
# Configure parameters and credits
mkdir ~/.aws
cat << EOF > ~/.aws/config
[plugins]
endpoint = awscli_plugin_endpoint

[default]
region = fr-par
s3 =
  endpoint_url = https://s3.fr-par.scw.cloud
  signature_version = s3v4
  max_concurrent_requests = 100
  max_queue_size = 1000
  multipart_threshold = 50MB
  # Edit the multipart_chunksize value according to the file sizes that you want to upload. The present configuration allows to upload files up to 10 GB (100 requests * 10MB). For example setting it to 5GB allows you to upload files up to 5TB.
  multipart_chunksize = 10MB
s3api =
  endpoint_url = https://s3.fr-par.scw.cloud
EOF
cat << EOF > ~/.aws/credentials
[default]
aws_access_key_id=$AWS_ACCESS_KEY
aws_secret_access_key=$AWS_SECRET_KEY
EOF
# Push the files
for ext in qcow2 qcow2.md5sum qcow2.sha256sum ; do
aws s3 rm s3://$BUCKET/kvm/${image}.${ext}
aws s3 cp ${image}.${ext} s3://$BUCKET/kvm/
aws s3api put-object-acl --bucket $BUCKET --key kvm/${image}.${ext} --acl public-read
done
aws s3 rm s3://$BUCKET/gns3a/${image}.gns3a
aws s3 cp ${image}.gns3a s3://$BUCKET/gns3a/
aws s3api put-object-acl --bucket $BUCKET --key gns3a/${image}.gns3a --acl public-read
aws s3 rm s3://$BUCKET/kvm/imagename
aws s3 cp ../../../imagename s3://$BUCKET/kvm/imagename
aws s3api put-object-acl --bucket $BUCKET --key kvm/imagename --acl public-read
