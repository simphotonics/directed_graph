#!/bin/bash --

# Defining colours
GREEN='\033[1;32m'
RESET='\033[0m'

# Exit immediately if a command exits with a non-zero status.
set -e

# Running benchmark
echo
echo -e "${GREEN}=== Running Benchmark $PWD...${RESET}"
echo

dart --enable-experiment=non-nullable ./bin/benchmark.dart
