#!/usr/bin/env bash

set -uex

MAIN=$(xrandr | awk '$3=="primary" {print $1}')
CONNECTED_DISPLAYS=$(xrandr | awk '$2=="connected" && $3!="primary" {print $1}')
DICSONNECTED_DISPLAYS=$(xrandr | awk '$2=="disconnected" && $3!="primary" {print $1}')

for CONNECTED in $CONNECTED_DISPLAYS; do
    [[ $CONNECTED == DP* ]] && xrandr --output $MAIN --primary --output $CONNECTED --auto --right-of $MAIN --mode 3840x2160
    [[ $CONNECTED == HDMI* ]] && xrandr --output $MAIN --primary --output $CONNECTED --set audio on --auto --right-of $MAIN
done

for DISCONNECTED in $DICSONNECTED_DISPLAYS; do
    xrandr --output $DISCONNECTED --off
done

leftwm command SoftReload
