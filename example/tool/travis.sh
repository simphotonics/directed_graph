#!/bin/bash --

# Defining colours
BLUE='\033[1;34m'
RESET='\033[0m'

# Exit immediately if a command exits with a non-zero status.
set -e

echo
echo -e "${BLUE}=== Running Example $PWD...${RESET}"
echo

dart ./bin/example.dart

echo
