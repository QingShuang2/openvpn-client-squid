#!/bin/sh
# Usage: ./build-image.sh [image-name] [build-context]
# Example: ./build-image.sh tunnelizer:latest .
# If no arguments are provided, defaults to image-name="proxier" and build-context="."

IMAGE_NAME="${1:-proxier}"
BUILD_CONTEXT="${2:-.}"

echo "Building Docker image with name: $IMAGE_NAME"
echo "Build context: $BUILD_CONTEXT"

docker build "$BUILD_CONTEXT" -t "$IMAGE_NAME"
if [ $? -eq 0 ]; then
  echo "Image built and tagged as '$IMAGE_NAME'"
else
  echo "Failed to build image."
  exit 2
fi
