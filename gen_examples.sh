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
    local name
    name="${1}.ppm"
    calendarimg_generate "$name"
    topng "$name"
}

function default {
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function modify_cell_width {
    CALENDARIMG_CELL_WIDTH=40
    for i in {0..362};do
        CALENDARIMG_DATA[i]=$(( i % 7 ));
    done
}

function gen_readme_item {
    local name
    name="$1"
    calendarimg_reset_default
    eval "$name"
    gen "$name"
    echo -e "\n## ${name}\n"
    echo '```bash'
    get_script "$name"
    echo '```'
    echo -e "\n![${name}](${name}.png)"
}

function gen_readme {
    echo "# calendarimg.sh Examples" > "$README_PATH"
    gen_readme_item "default" >> "$README_PATH"
    gen_readme_item "modify_cell_width" >> "$README_PATH"
}

rm -r examples
mkdir examples
gen_readme
