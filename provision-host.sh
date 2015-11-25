#!/bin/bash

# Only prerequisites: docker and curl. And the assumption that you're running on an EC2 instance. And that your name
# is Eli Mallon and you're running on my AWS account, that's a big one too.

# Set the host's SSH port to 2222
cat /etc/ssh/sshd_config | sed s/"^Port 22$"/"Port 2222"/ > /etc/ssh/sshd_config_new
mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
mv /etc/ssh/sshd_config_new /etc/ssh/sshd_config
service ssh restart

instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)

# Mount the EBS with my home directory on it
export AWS_DEFAULT_REGION=us-west-2
aws ec2 attach-volume \
  --volume-id vol-58d929be \
  --instance-id `ec2metadata --instance-id`\
  --device /dev/xvdb
mkdir -p /mnt/user
while [ ! -e /dev/xvdb ]
do
  sleep 1
done
mount /dev/xvdb /mnt/user

# Disable apparmor for the container. We can do whatever we want.
aa-complain /etc/apparmor.d/docker

# Gimmie my elastic IP
aws ec2 associate-address \
  --allocation-id eipalloc-c54dfca0 \
  --instance-id `ec2metadata --instance-id`

# Docker please.
curl -sSL https://get.docker.com/ | sh
service docker start

# Fire up the real thing!
cat <<EOF > /root/start.sh
#!/bin/bash
while true; do
  docker pull iameli/drumstick-eli
  docker run \
    --privileged=true \
    --rm \
    --name drumstick \
    --net host \
    -v /mnt/user:/root \
    -v /run/docker.sock:/run/docker.sock \
    iameli/drumstick-eli
  sleep 1
done
EOF
chmod 755 /root/start.sh
screen -d -m -s /root/start.sh
