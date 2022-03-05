#!/bin/bash

START_DIR="${START_DIR:-/home/coder/project}"

sudo /usr/local/share/ssh-init.sh

echo "Starting code-server..."
# Now we can run code-server with the default entrypoint
/usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 $START_DIR
