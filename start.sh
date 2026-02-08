#!/bin/bash

echo "Starting Docker daemon..."
sudo service docker start

echo "Starting SSH server on port 2211..."

# Start SSH daemon with sudo
sudo /usr/sbin/sshd

# Initialize Claude Code config if needed
if [ ! -f /home/user/.claude.json ] && [ -f /userdata/.claude.json ]; then
    echo "Copying Claude Code config from host..."
    cp /userdata/.claude.json /home/user/.claude.json 2>/dev/null || true
fi

if [ ! -d /home/user/.claude ] && [ -d /userdata/.claude ]; then
    echo "Copying Claude Code data from host..."
    cp -r /userdata/.claude /home/user/.claude 2>/dev/null || true
fi

# Change to project directory
cd /home/user/project

# Start OpenCode web server first (primary service)
echo "Starting OpenCode web server on port 2046..."
# Kill any existing opencode processes
pkill -f opencode || true
rm -rf ~/.opencode/data/ ~/.opencode/cache/ 2>/dev/null
# Disable Bun installation in oh-my-opencode
export OHMYOPENCODE_DISABLE_BUN=1

# Generate secure password if not provided
if [ -z "$OPENCODE_SERVER_PASSWORD" ]; then
    OPENCODE_SERVER_PASSWORD=$(openssl rand -hex 12)
    echo "================================================================="
    echo "WARNING: OPENCODE_SERVER_PASSWORD not set."
    echo "Generated temporary password: $OPENCODE_SERVER_PASSWORD"
    echo "================================================================="
fi
export OPENCODE_SERVER_PASSWORD

# Add SSH key if provided
if [ -n "$SSH_PUBLIC_KEY" ]; then
    mkdir -p ~/.ssh
    echo "$SSH_PUBLIC_KEY" >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    echo "Added SSH public key from environment."
fi

export PATH=$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.bun/bin:$PATH

# Check where opencode is installed
if [ ! -f "$HOME/.opencode/bin/opencode" ]; then
    echo "WARNING: OpenCode binary not found in standard location. Searching..."
    FOUND_PATH=$(find $HOME -name opencode -type f -executable | head -n 1)
    if [ -n "$FOUND_PATH" ]; then
        echo "Found opencode at: $FOUND_PATH"
        export PATH=$(dirname "$FOUND_PATH"):$PATH
    else
        echo "ERROR: Could not find opencode binary anywhere in home directory."
        ls -R $HOME/.opencode || echo ".opencode dir not found"
    fi
fi

OPENCODE_SERVER_USERNAME=user opencode --hostname 0.0.0.0 --port 2046 web &
OPENCODE_PID=$!

# Wait for OpenCode to initialize
echo "Waiting for OpenCode to start..."
sleep 8

# Check if OpenCode is running
if ! kill -0 $OPENCODE_PID 2>/dev/null; then
    echo "ERROR: OpenCode failed to start"
    exit 1
fi

# Start vibe-kanban in background
echo "Starting vibe-kanban on port 3927..."
PORT=3927 HOST=0.0.0.0 npx vibe-kanban &
VIBE_PID=$!

# Function to handle shutdown
shutdown() {
    echo "Shutting down services..."
    kill $OPENCODE_PID 2>/dev/null
    kill $VIBE_PID 2>/dev/null
    sudo service docker stop
    sudo killall sshd 2>/dev/null
    wait $OPENCODE_PID 2>/dev/null
    wait $VIBE_PID 2>/dev/null
    exit 0
}

# Trap signals for graceful shutdown
trap shutdown SIGTERM SIGINT

# Wait for services
wait $OPENCODE_PID $VIBE_PID
