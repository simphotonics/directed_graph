#!/bin/bash --

# Defining colours
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
RESET='\033[0m'


# Exit immediately if a command exits with a non-zero status.
set -e

# Resolving dependencies
echo
echo -e "${BLUE}=== Resolving dependencies $PWD...${RESET}"
echo

# Make sure .dart_tool/package_config.json exists.
pub get

# Upgrade packages.
pub upgrade

echo
echo -e "${PURPLE}=== Checking Source Code Formatting${RESET} $PWD..."
echo
# Overwrite files with formatted content: -w
# Dry run: -n
dart format bin lib test

# Analyze dart files
echo
echo -e "${BLUE}=== Analyzing $PWD...${RESET}"
echo

dart analyze \
    --fatal-warnings \
    --fatal-infos

# Running tests
echo
echo -e "${CYAN}=== Testing $PWD...${RESET}"
echo
dart run test -r expanded --test-randomize-ordering-seed=random


# ================
# Running examples
# ================

echo
echo -e "${BLUE}=== Running Example $PWD...${RESET}"
echo

dart example/bin/directed_graph_example.dart

echo

# =================
# Running benchmark
# =================
echo
echo -e "${GREEN}=== Running Benchmark $PWD...${RESET}"
echo

dart run benchmark bin/
