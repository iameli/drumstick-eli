#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Only prerequisites: docker and curl. And the assumption that you're running on an EC2 instance. And that your name
# is Eli Mallon and you're running on my AWS account, that's a big one too.

# Close STDOUT file descriptor
exec 1<&-
# Close STDERR FD
exec 2<&-

# Open STDOUT as $LOG_FILE file for read and write.
exec 1<>/var/log/drumstick-eli.log

# Redirect STDERR to STDOUT
exec 2>&1

apt update && apt -y install awscli linux-image-extra-$(uname -r) linux-image-extra-virtual  apt-transport-https ca-certificates

apt-key adv \
               --keyserver hkp://ha.pool.sks-keyservers.net:80 \
               --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
apt update
apt-get install -y docker-engine
service docker start

# Set the host's SSH port to 2222
cat /etc/ssh/sshd_config | sed s/"^Port 22$"/"Port 2222"/ > /etc/ssh/sshd_config_new
mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
mv /etc/ssh/sshd_config_new /etc/ssh/sshd_config
service ssh restart

instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)

# Mount the EBS with my home directory on it
export AWS_DEFAULT_REGION=us-west-2
aws ec2 attach-volume \
  --volume-id vol-8253c875 \
  --instance-id `ec2metadata --instance-id`\
  --device /dev/xvdb
mkdir -p /home/root
while [ ! -e /dev/xvdb ]
do
  sleep 1
done
mount /dev/xvdb /home/root

# Gimmie my elastic IP
aws ec2 associate-address \
  --allocation-id eipalloc-c54dfca0 \
  --instance-id `ec2metadata --instance-id`

# Get ready to run a kubernetes cluster!
mkdir -p /var/lib/kubelet
mount --bind /var/lib/kubelet /var/lib/kubelet
mount --make-shared /var/lib/kubelet

# Fire up the real thing!
cat <<EOF > /root/start.sh
#!/bin/bash
exec 1<&-
exec 2<&-
exec 1<>/var/log/drumstick-eli-run.log
exec 2>&1
while true; do
  docker pull iameli/drumstick-eli
  docker run \
    --privileged=true \
    --rm \
    --name drumstick \
    --net host \
    -v /home/root:/home/root \
    -v /run/docker.sock:/run/docker.sock \
    iameli/drumstick-eli
  sleep 1
done
EOF
chmod 755 /root/start.sh
screen -d -m -s /root/start.sh
