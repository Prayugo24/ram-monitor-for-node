#!/bin/bash

# RAM usage limit (percentage)
LIMIT=95  # Change to 90 if you want a lower limit

# Function to get current RAM usage
get_ram_usage() {
    # Get total memory and used memory using vm_stat
    total_memory=$(sysctl -n hw.memsize)
    vm_stat_output=$(vm_stat)
    pages_free=$(echo "$vm_stat_output" | awk '/Pages free:/ {print $3}' | tr -d '.')
    pages_active=$(echo "$vm_stat_output" | awk '/Pages active:/ {print $3}' | tr -d '.')
    pages_inactive=$(echo "$vm_stat_output" | awk '/Pages inactive:/ {print $3}' | tr -d '.')
    pages_speculative=$(echo "$vm_stat_output" | awk '/Pages speculative:/ {print $3}' | tr -d '.')
    pages_wired=$(echo "$vm_stat_output" | awk '/Pages wired down:/ {print $4}' | tr -d '.')

    # Calculate used memory
    used_memory=$((pages_active + pages_inactive + pages_wired + pages_speculative))
    used_memory_bytes=$((used_memory * 4096))  # Convert pages to bytes (1 page = 4096 bytes)

    # Calculate RAM usage percentage
    ram_usage=$((used_memory_bytes * 100 / total_memory))
    echo "$ram_usage"
}

# Loop to monitor RAM periodically
while true; do
    RAM_USAGE=$(get_ram_usage)
    echo "RAM usage: $RAM_USAGE%"
    if (( RAM_USAGE >= LIMIT )); then
    	echo "RAM has reached the limit of $LIMIT%. Stopping node processes."
        killall -SIGINT node
    fi
    sleep 5  # Check every 5 seconds
done