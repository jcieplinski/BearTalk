#!/bin/bash

# Exit on error
set -e

# Directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Directory for generated files
GENERATED_DIR="$SCRIPT_DIR/../Generated"

# Create generated directory if it doesn't exist
mkdir -p "$GENERATED_DIR"

# Generate Swift code from proto files
protoc \
    --proto_path="$SCRIPT_DIR" \
    --swift_opt=Visibility=Public \
    --swift_out="$GENERATED_DIR" \
    --grpc-swift_opt=Visibility=Public \
    --grpc-swift_out="$GENERATED_DIR" \
    "$SCRIPT_DIR"/*.proto

echo "Generated Swift code in $GENERATED_DIR" 
