#!/bin/bash

ram_usage(){
    while true; do
        read used <<< $(LC_ALL=C free --mega | awk '/Mem:/ {print $3}')
        read total <<< $(LC_ALL=C free --mega | awk '/Mem:/ {print $2}')
        read available <<< $(LC_ALL=C free --mega | awk '/Mem:/ {print $7}')

        used_perc=$(( 100 * used / total ))
        avail_perc=$(( 100 * available / total ))
        
        used_bar=$(printf '█%.0s' $(seq 1 $((used_perc / 5))))
        used_space=$(printf ' %.0s' $(seq 1 $((20 - used_perc / 5))))
        
        avail_bar=$(printf '█%.0s' $(seq 1 $((avail_perc / 5))))
        avail_space=$(printf ' %.0s' $(seq 1 $((20 - avail_perc / 5))))

        echo "Used      [$used_bar$used_space] $used_perc% (${used}MB / ${total}MB)"
        echo "Available [$avail_bar$avail_space] $avail_perc% (${available}MB / ${total}MB)"

        echo
        sleep $REFRESH_RATE
    done | zenity --text-info --title="RAM Usage" --width=600 --height=170 --auto-scroll --cancel-label="Back"
}
