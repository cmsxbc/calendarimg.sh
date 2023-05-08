#!/bin/bash


source calendarimg.sh

CALENDARIMG_COLS=21
CALENDARIMG_ROWS=9
# CALENDARIMG_MAJOR="row"

# CALENDARIMG_SUMMARY_NUMBER="disabled"

for i in {0..62};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
CALENDARIMG_LEVEL_LIMITS[0]=2
CALENDARIMG_LEVEL_LIMITS[1]=5

calendarimg_generate "output.ppm"
