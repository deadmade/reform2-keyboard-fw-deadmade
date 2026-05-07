#!/bin/sh
# Copyright 2023-2025 Johannes Schauer Marin Rodrigues <josch@debian.org>
# SPDX-License-Identifier: MIT

set -eu

if [ ! -e ./keyboard.hex ]; then
	echo "keyboard.hex doesn't exist. build it or use ./download-fw.sh to download it." >&2
	exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
	echo "you need to run this as root (for example by using sudo)" >&2
	exit 1
fi

get_property() {
	path="$1"
	property="$2"
	if [ "$(udevadm --version)" -lt 250 ]; then
		# no udevadm --property before version 250
		udevadm info --query=property "$path" | sed -ne "s/^$property=//p"
	else
		udevadm info --query=property --property="$property" --value "$path"
	fi
}

find_usb_device() {
	result=
	for p in /sys/bus/usb/devices/*; do
		[ -e "$p/idVendor" ] || continue
		[ "$(cat "$p/idVendor")" = "$1" ] || continue
		[ -e "$p/idProduct" ] || continue
		[ "$(cat "$p/idProduct")" = "$2" ] || continue
		[ "$(get_property "$p" "ID_MODEL")" = "$3" ] || continue
		if [ -n "$result" ]; then
			echo "found more than one device matching $1 $2 $3" >&2
			exit 1
		fi
		result="$(realpath -e "$p")"
	done
	echo "$result"
}

remove_prefix_char() {
	result="$1"
	char="$2"
	while :; do
		case $result in
			"$char"*) result=${result#"$char"};;
			*) break;;
		esac
	done
	echo "$result"
}

if ! command -v dfu-programmer &>/dev/null; then
	echo "E: please 'apt install dfu-programmer' before running this script"
	exit 1
fi

path_keyboard=$(find_usb_device 03eb 2042 Reform_Keyboard)

# if the keyboard was not found with the old identifier, try the modern ones
if [ -z "$path_keyboard" ]; then
	for model in "MNT_Reform_Keyboard_2.0" "MNT_Reform_Keyboard_3.0"; do
		for variant in US Neo2 Intl; do
			for mode in ST LT; do
				path_keyboard=$(find_usb_device 1209 6d00 "${model}_${variant}_${mode}")
				[ -n "$path_keyboard" ] && break
			done
			[ -n "$path_keyboard" ] && break
		done
		[ -n "$path_keyboard" ] && break
	done
fi

busnum_keyboard=
devnum_keyboard=
if [ -n "$path_keyboard" ] && [ -e "$path_keyboard" ]; then
	busnum_keyboard="$(get_property "$path_keyboard" "BUSNUM")"
	devnum_keyboard="$(get_property "$path_keyboard" "DEVNUM")"
	echo " 1. Find out your keyboard firmware version in the 'System Status' by pressing" >&2
	echo "    the circle key followed by the S key. The keyboard firmware version is on" >&2
	echo "    on the last line in a date-based format YYYYMMDD. Then either:"
	echo >&2
	echo " 2.A. If you are on keyboard firmware version 20231124 or newer:" >&2
	echo >&2
	echo "       2.A.1. Press the circle key followed by the X key to enter firmware update mode." >&2
	echo >&2
	echo " 2.B. If you are on keyboard firmware version older than 20231124:" >&2
	echo >&2
	echo "       2.B.1. Toggle the programming DIP switch SW84 on the keyboard to “ON”." >&2
	echo "       2.B.2. Press the reset button SW83." >&2
	echo >&2
	echo "    ATTENTION: Do not remove the keyboard bezel without having disconnected" >&2
	echo "               both battery boards first. If you don't want to remove the" >&2
	echo "               bezel you can reach both the programming DIP switch as well" >&2
	echo "               as the reset button with a non-conductive thin stick (like" >&2
	echo "               a wooden toothpick) behind the F4 key." >&2
	echo >&2
	if [ "$(udevadm --version)" -lt 251 ]; then
		# no udevadm wait before version 251
		echo " 3. Press the Enter key once you are ready" >&2
		# shellcheck disable=SC2034
		read -r enter
	else
		echo " 3. Waiting for the keyboard to disappear..." >&2
		udevadm wait --removed "$path_keyboard"
		echo " 4. Waiting for the Atmel DFU bootloader USB device to appear..." >&2
		udevadm wait --settle "$path_keyboard"
	fi
fi

path=$(find_usb_device 03eb 2ff4 ATm32U4DFU)
if [ -z "$path" ] || [ ! -e "$path" ]; then
	echo "cannot find Atmel DFU bootloader USB device" >&2
	exit 1
fi

busnum="$(get_property "$path" "BUSNUM")"
devnum="$(get_property "$path" "DEVNUM")"

# do some extra checks if we saw the usb device as a keyboard before
if [ -n "$path_keyboard" ] && [ -e "$path_keyboard" ]; then
	if [ "$path_keyboard" != "$path" ]; then
		echo "path of Atmel DFU bootloader USB device is different from the keyboard" >&2
		exit 1
	fi
	if [ "$busnum_keyboard" != "$busnum" ]; then
		echo "busnum of Atmel DFU bootloader USB device is different from the keyboard" >&2
		exit 1
	fi
	# the devnum of the atmel increments by 1 on every press of the reset
	# button (why?), so no sense comparing those
	#if [ "$((devnum_keyboard+1))" != "$devnum" ]; then
	#	echo "devnum of Atmel DFU bootloader USB device is different from the keyboard" >&2
	#	exit 1
	#fi
fi

device="atmega32u4:$(remove_prefix_char "$busnum" 0),$(remove_prefix_char "$devnum" 0)"

dfu-programmer "$device" erase --suppress-bootloader-mem

dfu-programmer "$device" flash ./keyboard.hex --suppress-bootloader-mem

dfu-programmer "$device" start

if [ "$(udevadm --version)" -ge 251 ]; then
	echo "Waiting for the Atmel DFU bootloader USB device to disappear..." >&2
	udevadm wait --removed "$path"
	echo "Waiting for the keyboard to re-appear..." >&2
	udevadm wait --settle "$path"
fi

echo "All done!" >&2
echo >&2
echo "If you were on an old firmware, don't forget to toggle the programming DIP switch SW84 on the keyboard to “OFF” again" >&2
