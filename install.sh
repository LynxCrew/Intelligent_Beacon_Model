#!/bin/bash

CONFIG_PATH="${HOME}/printer_data/config"
REPO_PATH="${HOME}/intelligent_beacon_model"
OVERRIDES=("BEACON_MODEL_SELECT")

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

function check_download {
    local repodirname repobasename
    repodirname="$(dirname ${REPO_PATH})"
    repobasename="$(basename ${REPO_PATH})"

    if [ ! -d "${REPO_PATH}" ]; then
        echo "[DOWNLOAD] Downloading IntelligentBeaconModel repository..."
        if git -C $repodirname clone https://github.com/LynxCrew/Intelligent_Default_Mesh.git $repobasename; then
            chmod +x ${REPO_PATH}/install.sh
            chmod +x ${REPO_PATH}/update.sh
            chmod +x ${REPO_PATH}/uninstall.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of IntelligentBeaconModel git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] IntelligentBeaconModel repository already found locally. Continuing...\n\n"
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."


    mkdir -p "${CONFIG_PATH}/Overrides"
    for OVERRIDE in ${OVERRIDES[@]}; do
        if [ -f "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg" ]; then
            chmod -R 777 "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
            rm -R "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
        fi
        cp -rf "${REPO_PATH}/Overrides/override_${OVERRIDE}.cfg" "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
    done
    
    chmod 755 "${CONFIG_PATH}/Overrides"
    for FILE in "${CONFIG_PATH}/Overrides/*"; do
        chmod 644 $FILE
    done
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}


printf "\n======================================\n"
echo "- Klicky install script -"
printf "======================================\n\n"


# Run steps
preflight_checks
check_download
link_extension
restart_klipper
