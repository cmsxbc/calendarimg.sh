#!/bin/bash

set -e

SELF_PATH="$0"
README_PATH="examples/README.md"

function topng {
    local src dst
    src="$1"
    dst="examples/${src%ppm}png"
    if type pnm2png > /dev/null 2>&1;then
        pnm2png "$src" > "$dst"
    else
        pnmtopng "$src" > "$dst"
    fi
}

function get_script {
    local name
    name="$1"
    grep -Pzo "function ${name} {(\n|.)+?\n}" "$SELF_PATH" | tail +2 | head -n-1 | cut -c 5-
}

source calendarimg.sh

function gen {
    local name name4func
    name="${1}.ppm"
    name4func="config_$1"
    calendarimg_reset_default
    eval "$name4func"
    calendarimg_generate "$name"
    topng "$name"
}

function config_default {
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_cell_width {
    CALENDARIMG_CELL_WIDTH=40
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_border {
    CALENDARIMG_BORDER=1
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_border_style {
    CALENDARIMG_BORDER_STYLE="dashed"
    CALENDARIMG_NODATA_BORDER_STYLE="solid"
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_border_style_by_direction {
    CALENDARIMG_BORDER_STYLE="dashed solid"
    CALENDARIMG_NODATA_BORDER_STYLE="solid dashed"
    for i in {0..20};do
        if [[ $((i % 2)) -gt 0 ]];then
            continue
        fi
        CALENDARIMG_DATA[i]=1;
    done
}

function config_modify_border_style_by_side {
    CALENDARIMG_BORDER_STYLE="dashed solid hidden dashed"
    CALENDARIMG_NODATA_BORDER_STYLE="solid hidden dashed solid"
    for i in {0..20};do
        if [[ $((i % 2)) -gt 0 ]];then
            continue
        fi
        CALENDARIMG_DATA[i]=1;
    done
}

function config_modify_padding {
    CALENDARIMG_PADDING=10
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_margin_and_background_color {
    CALENDARIMG_MARGIN=50
    CALENDARIMG_COLOR_BG="0 0 192"
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_major {
    CALENDARIMG_MAJOR="col"
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_rows {
    CALENDARIMG_ROWS=15
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_cols {
    CALENDARIMG_COLS=30
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function config_modify_level_colors {
    CALENDARIMG_LEVEL_LIMITS[0]=2
    CALENDARIMG_LEVEL_LIMITS[1]=3
    CALENDARIMG_LEVEL_LIMITS[2]=4
    CALENDARIMG_LEVEL_LIMITS[3]=5
    CALENDARIMG_LEVEL_LIMITS[4]=6
    CALENDARIMG_LEVEL_LIMITS[5]=7

    CALENDARIMG_LEVEL_COLORS[0]="255 0 0"
    CALENDARIMG_LEVEL_COLORS[1]="255 165 0"
    CALENDARIMG_LEVEL_COLORS[2]="255 255 0"
    CALENDARIMG_LEVEL_COLORS[3]="0 128 0"
    CALENDARIMG_LEVEL_COLORS[4]="0 0 255"
    CALENDARIMG_LEVEL_COLORS[5]="75 0 130"
    CALENDARIMG_LEVEL_COLORS[6]="238 130 238"

    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 + 1));
    done
}

function config_show_summary_number {
    CALENDARIMG_SUMMARY_NUMBER=enabled
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7));
    done
}

function config_reversed_data {
    CALENDARIMG_DATA_ORDER=reversed
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7));
    done
}

function config_lack_of_item {
    CALENDARIMG_COLOR_BR="192 192 0"
    CALENDARIMG_COLOR_NDBR="0 0 192"
    for i in {0..362};do
        if [[ $((i % 13)) -eq 0 ]];then
            continue
        fi
        CALENDARIMG_DATA[i]=$(( i % 7));
    done
}

function config_enable_connected {
    CALENDARIMG_CONNECTED=enabled
    # CALENDARIMG_PADDING=0
    # CALENDARIMG_BORDER=1
    for i in {0..362};do
        if [[ $((i % 13)) -gt 7 ]];then
            continue
        fi
        CALENDARIMG_DATA[i]=$(( i % 7));
    done
}

function config_enable_connected_reversed {
    CALENDARIMG_CONNECTED=enabled
    CALENDARIMG_DATA_ORDER="reversed"
    for i in {0..362};do
        if [[ $((i % 13)) -gt 7 ]];then
            continue
        fi
        CALENDARIMG_DATA[i]=$(( i % 7));
    done
}

function config_enable_connected_2 {
    CALENDARIMG_CONNECTED=enabled
    CALENDARIMG_ROWS=7
    CALENDARIMG_COLS=7
    for i in {0..31};do
        CALENDARIMG_DATA[i]=$(( i % 7));
    done
}

function gen_readme_item {
    local name name4human name4func
    name="$1"
    name4human="${name//_/ }"
    name4func="config_$name"
    echo -e "\n## ${name4human^}\n"
    echo '```bash'
    get_script "$name4func"
    echo '```'
    echo -e "\n![${name}](${name}.png)"
}

function gen_readme {
    echo "# calendarimg.sh Examples" > "$README_PATH"
    grep "^function config_" "$SELF_PATH" | awk '{print $2}' | cut -c8- | while read -r item; do
        local -i start_time end_time
        echo -n "deal $item ..."
        start_time=$(date +'%s')
        gen "$item"
        end_time=$(date +'%s')
        gen_readme_item "$item" >> "$README_PATH"
        echo " ... $((end_time - start_time)) s"
    done
}

if [[ -n "$1" ]];then
    gen "$1"
else
    rm -r examples
    mkdir examples
    gen_readme
fi
