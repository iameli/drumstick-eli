#!/usr/bin/fish

# Start up my SSH server
service ssh start

# Copy over my authorized keys file to the /root partition.
mkdir -p /root/.ssh
cat /build/authorized_keys > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Call my parent's entrypoint
exec /build/entrypoint.fish
