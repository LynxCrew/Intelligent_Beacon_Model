#!/bin/bash

CONFIG_PATH="${HOME}/printer_data/config"
REPO_PATH="${HOME}/intelligent_beacon_model"
OVERRIDES=("BEACON_MODEL_SELECT")
green=$(echo -en "\e[92m")
red=$(echo -en "\e[91m")
cyan=$(echo -en "\e[96m")
white=$(echo -en "\e[39m")

set -eu
export LC_ALL=C


function preflight_checks {
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

function uninstall_macros {
    local yn
    while true; do
        read -p "${cyan}Do you really want to uninstall IntelligentBeaconModel? (Y/n):${white} " yn
        case "${yn}" in
          Y|y|Yes|yes)
            for OVERRIDE in ${OVERRIDES[@]}; do
                if [ -f "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg" ]; then
                    chmod -R 777 "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
                    rm -R "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
                    echo "${green}${OVERRIDE} override removed"
                else
                    echo "${red}override_${OVERRIDE}.cfg not found!"
                fi
            done

            if [ -d "${REPO_PATH}" ]; then
                chmod -R 777 "${REPO_PATH}"
                rm -R "${REPO_PATH}"
                echo "${green}Intelligent Beacon Model folder removed"
            else
                echo "${red}Intelligent Beacon Model folder not found!"
            fi
            break;;
          N|n|No|no|"")
            exit 0;;
          *)
            echo "${red}Invalid Input!";;
        esac
    done
}

preflight_checks
uninstall_macros
