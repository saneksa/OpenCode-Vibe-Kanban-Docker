#!/bin/bash

# OpenCode Kanban Docker Image Build Script
# Builds the Docker image with a fixed name: successage/opencode-kanban

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fixed image name
IMAGE_NAME="successage/opencode-kanban"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building Docker Image${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Image name: $IMAGE_NAME"
echo ""

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Error: Dockerfile not found in current directory.${NC}"
    exit 1
fi

# Check if image already exists
if docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo -e "${YELLOW}Image '$IMAGE_NAME' already exists.${NC}"
    echo ""
    echo "Image details:"
    docker image inspect "$IMAGE_NAME" --format='  ID: {{.Id}}' 2>/dev/null | head -1
    docker image inspect "$IMAGE_NAME" --format='  Created: {{.Created}}' 2>/dev/null | head -1
    docker image inspect "$IMAGE_NAME" --format='  Size: {{.Size}}' 2>/dev/null | head -1 | sed 's/ bytes//' | awk '{printf "  Size: %.2f MB\n", $1/1024/1024}'
    echo ""
    read -p "Do you want to rebuild the image? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Build cancelled."
        exit 0
    fi
    echo ""
    echo "Removing old image..."
    docker rmi "$IMAGE_NAME" || {
        echo -e "${YELLOW}Warning: Failed to remove old image. Trying with -f flag...${NC}"
        docker rmi -f "$IMAGE_NAME" || {
            echo -e "${RED}Error: Failed to remove old image. Please remove it manually:${NC}"
            echo "  docker rmi -f $IMAGE_NAME"
            exit 1
        }
    }
    echo ""
fi

# Build the image
echo -e "${GREEN}Building image...${NC}"
echo ""

docker build --no-cache -t "$IMAGE_NAME" .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Build successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Image name: $IMAGE_NAME"
    echo ""
    echo "Image details:"
    docker image inspect "$IMAGE_NAME" --format='  ID: {{.Id}}' 2>/dev/null | head -1
    docker image inspect "$IMAGE_NAME" --format='  Created: {{.Created}}' 2>/dev/null | head -1
    docker image inspect "$IMAGE_NAME" --format='  Size: {{.Size}}' 2>/dev/null | head -1 | sed 's/ bytes//' | awk '{printf "  Size: %.2f MB\n", $1/1024/1024}'
    echo ""
    echo "You can now run:"
    echo "  docker compose up -d"
    echo ""
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Build failed!${NC}"
    echo -e "${RED}========================================${NC}"
    exit 1
fi
