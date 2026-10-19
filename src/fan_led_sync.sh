#!/bin/bash

PIN_LOW=22   # Green
PIN_MED=23   # Yellow
PIN_HIGH=24  # Red

pinctrl set $PIN_LOW op dl
pinctrl set $PIN_MED op dl
pinctrl set $PIN_HIGH op dl

# Find cooling device node
STATE_PATH=""
for dev in /sys/class/thermal/cooling_device*; do
    if grep -q "fan" "$dev/type" 2>/dev/null; then
        STATE_PATH="$dev/cur_state"
        break
    fi
done

# Fallback to hwmon pwm1
if [ -z "$STATE_PATH" ]; then
    STATE_PATH=$(ls /sys/class/hwmon/hwmon*/pwm1 2>/dev/null | head -n 1)
fi

cleanup() {
    pinctrl set $PIN_LOW dl
    pinctrl set $PIN_MED dl
    pinctrl set $PIN_HIGH dl
    exit 0
}
trap cleanup SIGINT SIGTERM

while true; do
    if [ -n "$STATE_PATH" ] && [ -f "$STATE_PATH" ]; then
        VAL=$(cat "$STATE_PATH" 2>/dev/null || echo 0)

        # Handle 0-4 stage mapping
        if [ "$VAL" -le 4 ]; then
            case "$VAL" in
                0) pinctrl set $PIN_LOW dl; pinctrl set $PIN_MED dl; pinctrl set $PIN_HIGH dl ;;
                1) pinctrl set $PIN_LOW dh; pinctrl set $PIN_MED dl; pinctrl set $PIN_HIGH dl ;;
                2|3) pinctrl set $PIN_LOW dl; pinctrl set $PIN_MED dh; pinctrl set $PIN_HIGH dl ;;
                4) pinctrl set $PIN_LOW dl; pinctrl set $PIN_MED dl; pinctrl set $PIN_HIGH dh ;;
            esac
        else
            # Handle 0-255 PWM mapping
            if [ "$VAL" -eq 0 ]; then
                pinctrl set $PIN_LOW dl; pinctrl set $PIN_MED dl; pinctrl set $PIN_HIGH dl
            elif [ "$VAL" -le 85 ]; then
                pinctrl set $PIN_LOW dh; pinctrl set $PIN_MED dl; pinctrl set $PIN_HIGH dl
            elif [ "$VAL" -le 170 ]; then
                pinctrl set $PIN_LOW dl; pinctrl set $PIN_MED dh; pinctrl set $PIN_HIGH dl
            else
                pinctrl set $PIN_LOW dl; pinctrl set $PIN_MED dl; pinctrl set $PIN_HIGH dh
            fi
        fi
    fi
    sleep 1.5
done