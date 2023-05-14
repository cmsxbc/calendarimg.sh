#!/bin/bash


source calendarimg.sh

CALENDARIMG_DATA_ORDER="reversed"
CALENDARIMG_COLS=30
# CALENDARIMG_ROWS=20
CALENDARIMG_MAJOR="row"

CALENDARIMG_CELL_WIDTH=23

CALENDARIMG_SUMMARY_NUMBER="enabled"

for i in {0..10};do
    for j in {0..11};do
        idx=$((i*12+j))
        CALENDARIMG_DATA[idx]=$idx;
    done
done
CALENDARIMG_LEVEL_LIMITS[0]=2
CALENDARIMG_LEVEL_LIMITS[1]=5

calendarimg_generate "output.ppm"
