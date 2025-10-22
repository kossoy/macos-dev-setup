#!/bin/bash

# Get the status of Ethernet (en7)
ethernet_status=$(ifconfig en7 | grep "status: active")

# Handle IPv4 Routes
if [ -n "$ethernet_status" ]; then
    # Ethernet is active - prioritize it for IPv4
    sudo route delete default -ifscope en0 2>/dev/null
else
    # Ethernet is inactive - allow Wi-Fi for IPv4
    sudo route add default 10.0.0.138 -ifscope en0 2>/dev/null
fi

# Handle IPv6 Routes
if [ -n "$ethernet_status" ]; then
    # Ethernet is active - prioritize it for IPv6
    sudo route delete -inet6 -net ::/0 -ifscope en0 2>/dev/null
else
    # Ethernet is inactive - allow Wi-Fi for IPv6 (replace <Wi-Fi_Gateway_IPv6>)
    sudo route add -inet6 -net ::/0 fe80::2b8:c2ff:fef0:d19e%en0 -ifscope en0 2>/dev/null
fi

