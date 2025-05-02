#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${2}${1}${NC}"
}

# Function to build and push a specific PHP version
build_and_push() {
    local php_version=$1
    local image_tag="erkineren/pier:${php_version}"

    print_message "Building Docker image for PHP ${php_version}..." "${YELLOW}"

    if ! docker build --build-arg PHP_VERSION="${php_version}" -t "${image_tag}" .; then
        print_message "Error: Docker build failed for PHP ${php_version}" "${RED}"
        exit 1
    fi

    print_message "Pushing Docker image ${image_tag} to registry..." "${YELLOW}"

    if ! docker push "${image_tag}"; then
        print_message "Error: Docker push failed for PHP ${php_version}" "${RED}"
        exit 1
    fi

    print_message "Successfully built and pushed ${image_tag}" "${GREEN}"
}

# Main execution
print_message "Starting Docker build and push process..." "${YELLOW}"

# Build and push for each PHP version
for version in "8.1" "8.2" "8.3" "8.4"; do
    build_and_push "${version}"
done

print_message "All builds and pushes completed successfully!" "${GREEN}"
