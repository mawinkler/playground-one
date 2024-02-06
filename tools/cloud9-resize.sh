#!/bin/bash

METADATA_TOKEN=$(curl -sS --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")
SIZE=${1:-30}
INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $METADATA_TOKEN")
VOLUMEID=$(aws ec2 describe-instances \
  --instance-id $INSTANCEID \
  --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
  --output text)

aws ec2 modify-volume --volume-id $VOLUMEID --size $SIZE

while [ \
  "$(aws ec2 describe-volumes-modifications \
    --volume-id $VOLUMEID \
    --filters Name=modification-state,Values="optimizing","completed" \
    --query "length(VolumesModifications)"\
    --output text)" != "1" ]; do
echo -n .
sleep 1
done

sudo growpart /dev/nvme0n1 1

if [ "$(df -T | grep -i '/$' | awk '{print $2}')" == "xfs" ]; then
  sudo xfs_growfs -d /
else
  sudo resize2fs /dev/nvme0n1p1
fi
