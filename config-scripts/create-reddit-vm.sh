#!/bin/bash
cd packer
packer build -var-file=variables.json immutable.json

USER_PUB_KEY=$(cat ~/.ssh/appuser.pub)
IMAGE_ID=$(yc compute image get-latest-from-family reddit-full --format json | jq --raw-output '.id')

# Если JQ не установлен, то:
# IMAGE_ID=$(yc compute image get-latest-from-family reddit-full --format json | grep -w "id" | sed "s/^.\{,9\}//;s/.\{,2\}$//" )

cat > metadata.yml << EOM
#cloud-config
timezone: Europe/Moscow

users:
  - name: appuser
    groups: sudo
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    ssh-authorized-keys:
    - $USER_PUB_KEY
EOM

yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk size=10GB,image-id=$IMAGE_ID \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=./metadata.yml \

rm -f metadata.yml
