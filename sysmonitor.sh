#!/bin/bash

# Author           : Bartłomiej Chociaj (s203683@student.pg.edu.pl)
# Created On       : 8.05.2024
# Last Modified By : Bartłomiej Chociaj  (s203683@student.pg.edu.pl)
# Last Modified On : 10.05.2024
# VERSION:           1.1
#
# DESCRIPTION:       This script can be used to read basic system informations 
#                    as well as live system utillization.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

source ./ram_usage.sh
source ./cpu_usage.sh
source ./gpu_usage.sh
source ./save_log.sh

CONFIG_FILE="./config.cfg"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Warning: config file not found, using defaults."
    REFRESH_RATE=1
    LOG_DIR="./logs"
    VERSION="1.1"
fi

while getopts ":hv" opt; do
    case ${opt} in
        h)
            echo "$DESCRIPTION"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -h        Show this help message"
            echo "  -v        Show script version"
            exit 0
            ;;
        v)
            echo "sysmonitor Script Version: $VERSION"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

get_refresh_rate() {
    refresh_rate=$(zenity --entry --title="Refresh Rate" --text="Enter refresh rate in seconds:" --entry-text="$REFRESH_RATE" --ok-label="Confirm" --cancel-label="Exit")

    if [[ ! "$refresh_rate" =~ ^[0-9]+$ || "$refresh_rate" -le 0 ]]; then
        refresh_rate=1
    fi
    export REFRESH_RATE=$refresh_rate
}

while true; do
    menu=("Basic System Information" "System Utilization" "Save log to file")
    resp=$(zenity --list \
        --title="System Monitor" \
        --text="Choose the option:" \
        --column=Menu "${menu[@]}" \
        --ok-label="Confirm" \
        --cancel-label="Exit"\
        --height=300 \
        --width=300)

    case "$resp" in
        "Basic System Information")
            cpu_info=$(LC_ALL=C lscpu| grep -E 'Architecture|CPU\(s\)|Model name|Threads per core|Cores per socket|Sockets|Frequency boost|CPU\(s\) scaling MHz|CPU max MHz|CPU min MHz|Virtualization')
            cpu_freqs=$(cat /proc/cpuinfo | grep "cpu MHz" | awk '{print "Core " NR ": " $4 " MHz"}')
            ram_info=$(LC_ALL=C free -h)
            system_info=$(LC_ALL=C uname -a)

            info="System:\n$system_info\n\nCPU Information:\n\nCPU:\n$cpu_info\n\nCPU Frequencies:\n$cpu_freqs\n\nRAM Memory:\n$ram_info"
            echo -e "$info" | zenity --text-info --title="Basic System Information" --width=600 --height=700 --cancel-label="Back"
            ;;
        "System Utilization")
            while true; do
                menu=("CPU Usage" "RAM Usage" "GPU VRAM Usage" "Disk Usage")
                resp=$(zenity --list \
                    --title="System Utilization" \
                    --text="Choose the option:" \
                    --column=Menu "${menu[@]}" \
                    --ok-label="Confirm" \
                    --cancel-label="Back"\
                    --height=300 \
                    --width=300)

                case "$resp" in
                    "CPU Usage")
                        get_refresh_rate
                        cpu_usage
                        ;;
                    "RAM Usage")
                        get_refresh_rate
                        ram_usage
                        ;;
                    "GPU VRAM Usage")
                        get_refresh_rate
                        gpu_usage
                        ;;
                    "Disk Usage")
                        data=$(LC_ALL=C df -h --output=source,size,used,avail,pcent,target | tail -n +2 | while read -r source size used avail pcent target; do
                            echo "$source" "$size" "$used" "$avail" "$pcent" "$target"
                        done)

                        zenity --list \
                            --title="Disk Usage" \
                            --cancel-label="Back"\
                            --width=600 --height=500 \
                            --column="Filesystem" --column="Size" --column="Used" --column="Avail" --column="Use%" --column="Mount Point" \
                            $data
                        ;;
                    *)
                        break
                        ;;
                esac
            done
            ;;
        "Save log to file")
            save_log
            ;;
        *)
            break
            ;;
    esac
done


