#!/bin/bash

# Specify the starting directory
START_DIR="/home/max/"

# Function to count inodes
count_inodes() {
  local dir=$1
  find "$dir" -xdev -printf "." | wc -c
}

export -f count_inodes

# Find all directories and count inodes
find "$START_DIR" -xdev -type d -exec bash -c 'echo -n "{}: "; count_inodes "{}"' \; | sort -n -t: -k2

#find / -xdev -type d -exec sh -c 'echo -n "{}: "; find "{}" -type f | wc -l' \; | sort -n -r -k 2 | head -20

