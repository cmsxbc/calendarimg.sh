#!/bin/bash

source calendarimg.sh

# CALENDARIMG_MAJOR="row"
# CALENDARIMG_COLS=14
# CALENDARIMG_ROWS=26
# CALENDARIMG_SUMMARY_NUMBER="disabled"

for i in {0..363};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
CALENDARIMG_LEVEL_LIMITS[0]=2
CALENDARIMG_LEVEL_LIMITS[1]=5

calendarimg_generate "output.ppm"
