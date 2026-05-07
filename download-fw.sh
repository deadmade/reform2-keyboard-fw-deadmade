#!/bin/bash

programname=$0
fwver=$1

function usage {
        echo "usage: $programname variant"
        echo ""
        echo "to download the firmware for the keyboard built into your MNT Reform:"
        echo ""
        echo "       $programname 3_US  # (if you have a QWERTY-US keyboard V3)"
        echo "       $programname 3     # (if you have a non-US keyboard V3)"
        echo "       $programname 2_US  # (if you have a QWERTY-US keyboard V2)"
        echo "       $programname 2     # (if you have a non-US keyboard V2)"
        echo ""
        echo "if you want to flash a standalone USB keyboard, use one of the following:"
        echo ""
        echo "       $programname 3_US-standalone"
        echo "       $programname 3-standalone"
        echo "       $programname 2_US-standalone"
        echo "       $programname 2-standalone"
        echo ""
        exit 1
}

if [ "$fwver" != "3_US" ] && [ "$fwver" != "2_US" ] && [ "$fwver" != "3" ] && [ "$fwver" != "2" ] && [ "$fwver" != "3_US-standalone" ] && [ "$fwver" != "2_US-standalone" ] && [ "$fwver" != "3-standalone" ] && [ "$fwver" != "2-standalone" ]; then
        usage
fi

mkdir -p bin
wget -O keyboard.hex "https://source.mnt.re/reform/reform/-/jobs/artifacts/master/raw/reform2-keyboard-fw/keyboard-$fwver.hex?job=build"

