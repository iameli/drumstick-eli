#!/usr/bin/fish

# Start up my SSH server
service ssh start

# Copy over my authorized keys file to the /home/root partition.
mkdir -p /home/root/.ssh
cat /build/authorized_keys > /home/root/.ssh/authorized_keys
chmod 600 /home/root/.ssh/authorized_keys

# Call my parent's entrypoint
exec /build/entrypoint.fish
