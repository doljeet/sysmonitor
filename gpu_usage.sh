#!/bin/bash

gpu_usage() {
    if ! command -v glxinfo &> /dev/null; then
        zenity --error --title="GPU Usage Error" --text="glxinfo is not installed or not available."
        exit 1
    fi

    while true; do
        dedicated=$(glxinfo | grep -i "Dedicated video memory" | awk '{print $4}' | grep -o '[0-9]\+')
        available=$(glxinfo | grep -i "Currently available dedicated video memory" | awk '{print $6}' | grep -o '[0-9]\+')

        if [[ -z $dedicated || -z $available ]]; then
            echo "Could not read GPU memory info from glxinfo."
            sleep $REFRESH_RATE
            continue
        fi

        used=$((dedicated - available))
        used_perc=$((100 * used / dedicated))
        avail_perc=$((100 * available / dedicated))

        used_bar=$(printf '█%.0s' $(seq 1 $((used_perc / 5))))
        used_space=$(printf ' %.0s' $(seq 1 $((20 - used_perc / 5))))

        echo "Dedicated VRAM: ${dedicated}MB"
        echo "Used VRAM      [$used_bar$used_space] $used_perc% (${used}MB / ${dedicated}MB)"
        echo

        sleep $REFRESH_RATE
    done | zenity --text-info --title="GPU VRAM Usage" --width=600 --height=170 --auto-scroll --cancel-label="Back"
}
