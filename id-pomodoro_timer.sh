#!/bin/bash

# Colors
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
WHITE='\033[97m'
ENDC='\033[0m'

# Default values
WORK_MINUTES=25
BREAK_MINUTES=5
LONG_BREAK_MINUTES=15

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--work)
            WORK_MINUTES="$2"
            shift 2
            ;;
        -b|--break)
            BREAK_MINUTES="$2"
            shift 2
            ;;
        -l|--long-break)
            LONG_BREAK_MINUTES="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "  -w, --work <minutes>        Work duration in minutes (default: 25)"
            echo "  -b, --break <minutes>       Short break duration in minutes (default: 5)"
            echo "  -l, --long-break <minutes>  Long break duration in minutes (default: 15)"
            echo "  -h, --help                  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Convert minutes to seconds
WORK_DURATION=$((WORK_MINUTES * 60))
BREAK_DURATION=$((BREAK_MINUTES * 60))
LONG_BREAK_DURATION=$((LONG_BREAK_MINUTES * 60))

sessions_completed=0

countdown() {
    local duration=$1
    local session_type=$2
    local remaining=$duration
    
    while [ $remaining -ge 0 ]; do
        mins=$((remaining / 60))
        secs=$((remaining % 60))
        printf "\r${session_type} - %02d:%02d" "$mins" "$secs"
        sleep 1
        remaining=$((remaining - 1))
    done
    
    if [ "$session_type" = "Work" ]; then
        echo -e "\n\n${session_type} completed! Time to take a break.\n"
    else
        echo -e "\n\n${session_type} completed! Time to get back to work."
    fi
}

# Clear the screen
clear

echo -e "${WHITE}id Pomodoro Timer Has Started! Press Ctrl+C to stop.${ENDC}"

# Trap Ctrl+C to handle cleanup
trap 'echo -e "\n\n${WHITE}id Pomodoro session ended. Completed $((sessions_completed-1)) work sessions.${ENDC}"; exit 0' INT

while true; do
    sessions_completed=$((sessions_completed + 1))
    
    echo -e "\n${BLUE}:: Session ${sessions_completed}\n"
    countdown $WORK_DURATION "Work"
    
    if (( sessions_completed % 4 == 0 )); then
        echo "Taking a long break..."
        countdown $LONG_BREAK_DURATION "Long Break"
    else
        echo "Taking a short break..."
        countdown $BREAK_DURATION "Short Break"
    fi
done
