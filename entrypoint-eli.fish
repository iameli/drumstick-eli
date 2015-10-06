#!/usr/bin/fish

# Start up my SSH server
service ssh start

# Call my parent's entrypoint
exec /root/.build/entrypoint.fish
