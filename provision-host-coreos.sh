#!/bin/bash

# Only prerequisites: docker and curl. And the assumption that you're running on an EC2 instance. And that your name
# is Eli Mallon and you're running on my AWS account, that's a big one too.

# Set the host's SSH port to 2222
cat /usr/lib/systemd/system/sshd.socket | \
  sed s/"^ListenStream=22$"/"ListenStream=2222"/ > \
  /etc/systemd/system/sshd.socket
service ssh restart

sudo systemctl daemon-reload

# Get our IAM security credentials
instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)

# Mount the EBS with my home directory on it
# export AWS_DEFAULT_REGION=us-west-2
docker run --rm blendle/aws-cli ec2 attach-volume \
  --volume-id vol-58d929be \
  --instance-id $instanceId \
  --device /dev/xvdz \
  --region us-west-2

mkdir -p /mnt/user

while [ ! -e /dev/xvdz ]
do
  sleep 1
done
mount /dev/xvdz /mnt/user

# Gimmie my elastic IP
docker run --rm blendle/aws-cli ec2 associate-address \
  --allocation-id eipalloc-c54dfca0 \
  --instance-id $instanceId \
  --region us-west-2

docker run \
  --privileged=true \
  -d \
  --name drumstick \
  --net host \
  -v /mnt/user:/root \
  -v $(which docker):/usr/bin/docker \
  -v /run/docker.sock:/run/docker.sock \
  iameli/drumstick-eli
