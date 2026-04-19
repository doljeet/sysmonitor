#!/bin/bash

cpu_usage(){
    if ! command -v mpstat &> /dev/null; then
        zenity --error --title="CPU Usage Error" --text="mpstat is not installed or not available."
        exit 1
    fi

    if ! command -v nproc &> /dev/null; then
    zenity --error --title="CPU Core Count Error" --text="nproc is not installed or not available."
    exit 1
    fi

    if ! command -v jq &> /dev/null; then
    zenity --error --title="JSON Parsing Error" --text="jq is not installed or not available."
    exit 1
    fi

    CPU_COUNT=$(nproc)

    LINE_COUNT=$((CPU_COUNT + 2))

    WINDOW_HEIGHT=$((LINE_COUNT * 30 + 50))

    while true; do
        mpstat -P ALL -o JSON 1 1 | jq -r '
            .sysstat.hosts[0].statistics[0]["cpu-load"][] |
            (
                100 - .idle
            ) as $usage |
            "CPU \(.cpu) [" +
            ( ("█" * ($usage / 5 | floor)) + (" " * (20 - ($usage / 5 | floor))) ) +
            "] " + ($usage | round | tostring) + "%"
        '
        echo
        sleep $REFRESH_RATE
    done | zenity --text-info --title="CPU Usage" --width=600 --height=$WINDOW_HEIGHT --auto-scroll --cancel-label="Back"
}
