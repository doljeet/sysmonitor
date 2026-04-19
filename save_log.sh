#!/bin/bash
save_log(){
  user_input=$(zenity --forms --title="System Report Settings" \
  --text="Set the data collection interval and total duration (in seconds)" \
  --add-entry="Interval (seconds)" \
  --add-entry="Duration (seconds)")

  INTERVAL=$(echo "$user_input" | cut -d'|' -f1)
  DURATION=$(echo "$user_input" | cut -d'|' -f2)

  if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || ! [[ "$DURATION" =~ ^[0-9]+$ ]]; then
    zenity --error --text="Please enter numeric values."
    exit 1
  fi
  
  mkdir -p "$LOG_DIR"
  REPORT_FILE="$LOG_DIR/system_report_$(date '+%Y-%m-%d_%H-%M-%S').txt"

  echo "System Report - $(date)" > $REPORT_FILE
  echo "==================================================" >> $REPORT_FILE
  echo "" >> $REPORT_FILE

  LOOPS=$((DURATION / INTERVAL))

  for ((i=1; i<=LOOPS; i++))
  do

    cpu_freq=$(cat /proc/cpuinfo | grep "cpu MHz" | awk '{print "Core " NR ": " $4 " MHz"}')
    ram_usage=$(free -h)
    disk_usage=$(df -h | awk '{print $1, $4, $5}')
    
    echo "Report $i - $(date)" >> $REPORT_FILE
    echo "CPU Frequency:" >> $REPORT_FILE
    echo "$cpu_freq" >> $REPORT_FILE
    echo "Disk Space:" >> $REPORT_FILE
    echo "$disk_usage" >> $REPORT_FILE
    echo "RAM Usage:" >> $REPORT_FILE
    echo "$ram_usage" >> $REPORT_FILE
    echo "==================================================" >> $REPORT_FILE
    
    sleep $INTERVAL
  done

  echo "Report generated and saved to $REPORT_FILE"

}
