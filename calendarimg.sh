#! /bin/bash

set -e

CALENDARIMG_CELL_WIDTH=${CALENDARIMG_CELL_WIDTH:-15}
CALENDARIMG_BORDER=${CALENDARIMG_BORDER:-5}
CALENDARIMG_PADDING=${CALENDARIMG_PADDING:-4}
CALENDARIMG_MARGIN=${CALENDARIMG_MARGIN:-20}

CALENDARIMG_COLS=${CALENDARIMG_COLS:-52}
CALENDARIMG_ROWS=${CALENDARIMG_ROWS:-7}

CALENDARIMG_SUMMARY_NUMBER=${CALENDARIMG_SUMMARY_NUMBER:-disabled}

declare CALENDARIMG_ITEM_WIDTH CALENDARIMG_TOTAL_WIDTH CALENDARIMG_TOTAL_HEIGTH CALENDARIMG_TOTAL

CALENDARIMG_COLOR_BG=${CALENDARIMG_COLOR_BG:-"255 255 255"}
CALENDARIMG_COLOR_BR=${CALENDARIMG_COLOR_BR:-"0 0 0"}
CALENDARIMG_COLOR_NR=${CALENDARIMG_COLOR_NR:-"192 0 0"}


CALENDARIMG_MAJOR=${CALENDARIMG_MAJOR:-row}



declare -a CALENDARIMG_DATA
declare -a CALENDARIMG_LEVEL_LIMITS
declare -a CALENDARIMG_LEVEL_COLORS
CALENDARIMG_LAST_LEVEL=0
declare -a CALENDARIMG_NUMBERS_DATA


function calendarimg_init_number_data {
    local scale_ratio pad0 pad1 i j k l idx number_sources number_base_data pc0 pc1 pc2 pc3 pc4
    declare -a number_sources=(
        33080895
        4329604
        32570911
        32570431
        18414625
        33061951
        33062463
        32539681
        33095231
        33094719
    )
    if [[ $CALENDARIMG_CELL_WIDTH -lt 5 ]];then
        echo "CALENDARIMG_CELL_WIDTH is too small, should be at least 5, but got $CALENDARIMG_CELL_WIDTH" >&2
        exit 1
    fi
    ((scale_ratio=CALENDARIMG_CELL_WIDTH / 5))
    pad0=0
    pad1=0
    pc3=""
    pc4=""
    if [[ $((CALENDARIMG_CELL_WIDTH - scale_ratio * 5)) -ne 0 ]];then
        pad0=$(((CALENDARIMG_CELL_WIDTH - 5 * scale_ratio + 1) / 2))
        pad1=$((CALENDARIMG_CELL_WIDTH - 5 * scale_ratio - pad0))
        # echo "scale_ratio=$scale_ratio, pad0=$pad0, pad1=$pad1"
        pc3="$(printf "0%.0s" $(seq 1 $pad0))"
        pc4="$(printf "0%.0s" $(seq 1 $pad1))"
    fi
    pc0="$(printf "0%.0s" $(seq 1 $scale_ratio))"
    pc1="$(printf "1%.0s" $(seq 1 $scale_ratio))"
    pc2="$(printf "0%.0s" $(seq 1 "$CALENDARIMG_CELL_WIDTH"))"


    for i in {0..9};do
        number_base_data="$(echo "obase=2;${number_sources[i]} + 33554432" | bc)"
        number_base_data="${number_base_data:1}"
        CALENDARIMG_NUMBERS_DATA[i]=""
        for ((j=0;j<pad0;j++));do
            CALENDARIMG_NUMBERS_DATA[i]="${CALENDARIMG_NUMBERS_DATA[i]}$pc2"
        done
        for j in {0..4};do
            for ((k=0;k<scale_ratio;k++));do
                CALENDARIMG_NUMBERS_DATA[i]="${CALENDARIMG_NUMBERS_DATA[i]}$pc3"
                for l in {0..4};do
                    idx=$((j * 5 + l ))
                    if [[ "${number_base_data:idx:1}" -gt 0 ]];then
                        CALENDARIMG_NUMBERS_DATA[i]="${CALENDARIMG_NUMBERS_DATA[i]}$pc1"
                    else
                        CALENDARIMG_NUMBERS_DATA[i]="${CALENDARIMG_NUMBERS_DATA[i]}$pc0"
                    fi
                done
                CALENDARIMG_NUMBERS_DATA[i]="${CALENDARIMG_NUMBERS_DATA[i]}$pc4"
            done
        done
        for ((j=0;j<pad1;j++));do
            CALENDARIMG_NUMBERS_DATA[i]="${CALENDARIMG_NUMBERS_DATA[i]}$pc2"
        done
        if [[ "${#CALENDARIMG_NUMBERS_DATA[i]}" -ne $((CALENDARIMG_CELL_WIDTH * CALENDARIMG_CELL_WIDTH)) ]];then
            echo "fatal numbers, please report to dev with your parameters: $CALENDARIMG_CELL_WIDTH, ${#CALENDARIMG_NUMBERS_DATA[i]}"
            exit 1
        fi
    done
}

function calendarimg_draw_number {
    local number array_name direction idx row_start_idx col_start_idx number_var_name tidx

    number=$1
    array_name=$2
    direction=$3
    idx=$4
    if [[ "$direction" == "row" ]];then
        ((row_start_idx=idx*CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN + CALENDARIMG_BORDER))
        ((col_start_idx=CALENDARIMG_ITEM_WIDTH*CALENDARIMG_COLS + CALENDARIMG_MARGIN))
    elif [[ "$direction" == "col" ]];then
        ((row_start_idx=CALENDARIMG_ITEM_WIDTH*CALENDARIMG_ROWS + CALENDARIMG_MARGIN))
        ((col_start_idx=idx*CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN + CALENDARIMG_BORDER))
    else
        echo "Invalid directions: $direction"
        exit 1;
    fi
    echo "row_start_idx=$row_start_idx"
    echo "col_start_idx=$col_start_idx"
    for ((ci=0;ci<${#number};ci++));do
        number_var_name="${number:$ci:1}"
        for ((i=0;i<CALENDARIMG_CELL_WIDTH;i++));do
            for ((j=0;j<CALENDARIMG_CELL_WIDTH;j++));do
                ((tidx=i*CALENDARIMG_CELL_WIDTH+j))
                if [[ "${CALENDARIMG_NUMBERS_DATA[number_var_name]:tidx:1}" -gt 0 ]];then
                    echo "${array_name}[\"$((i + row_start_idx)),$((j + col_start_idx))\"]=\"$CALENDARIMG_COLOR_NR\""
                fi
            done
        done
        if [[ "$direction" == "row" ]];then
            ((col_start_idx+=CALENDARIMG_ITEM_WIDTH))
        else
            ((row_start_idx+=CALENDARIMG_ITEM_WIDTH))
        fi
    done
}


function calendarimg_check_colors {
    if [[ -z "${CALENDARIMG_LEVEL_LIMITS[*]}" ]];then
        CALENDARIMG_LEVEL_LIMITS[0]=3
        CALENDARIMG_LEVEL_LIMITS[1]=7
    fi

    if [[ -z "${CALENDARIMG_LEVEL_COLORS[*]}" ]];then
        CALENDARIMG_LEVEL_COLORS[0]="0 192 0"
        CALENDARIMG_LEVEL_COLORS[1]="192 192 0"
        CALENDARIMG_LEVEL_COLORS[2]="255 0 0"
    fi

    CALENDARIMG_LEVEL_COUNTS="${#CALENDARIMG_LEVEL_COLORS[@]}"
    CALENDARIMG_LAST_LEVEL="${#CALENDARIMG_LEVEL_LIMITS[@]}"

    if [[ $((CALENDARIMG_LEVEL_COUNTS - CALENDARIMG_LAST_LEVEL)) -ne 1 ]];then
        echo "colors != limits + 1" >&2;
        return 1;
    fi
    return 0;
}


function calendarimg_init {
    local addition_items
    addition_items=0
    if [[ ${CALENDARIMG_SUMMARY_NUMBER^^} == "ENABLED" ]];then
        addition_items=2
    fi
    CALENDARIMG_ITEM_WIDTH=$((CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER * 2 + CALENDARIMG_PADDING))
    CALENDARIMG_TOTAL_WIDTH=$((CALENDARIMG_ITEM_WIDTH * (CALENDARIMG_COLS + addition_items) - CALENDARIMG_PADDING + CALENDARIMG_MARGIN * 2))
    CALENDARIMG_TOTAL_HEIGTH=$((CALENDARIMG_ITEM_WIDTH * (CALENDARIMG_ROWS + addition_items) - CALENDARIMG_PADDING + CALENDARIMG_MARGIN * 2))
    calendarimg_init_number_data
}


function calendarimg_generate {

    if [[ -z "$1" ]];then
        echo "lack of output filepath" >&2;
        return
    fi
    if ! calendarimg_check_colors;then
        return
    fi

    CALENDARIMG_TOTAL=$((CALENDARIMG_COLS * CALENDARIMG_ROWS))

    if [[ ${#CALENDARIMG_DATA[@]} -ne $CALENDARIMG_TOTAL ]];then
        echo "data length: ${#CALENDARIMG_DATA[@]} != $CALENDARIMG_TOTAL" >&2;
        return
    fi

    calendarimg_init


    local cur_index cur_row cur_col points row_start_idx col_start_idx w h i j col_counts row_counts color_idx
    declare -A points
    for ((h=0;h<CALENDARIMG_TOTAL_HEIGTH;h++));do
        for ((w=0;w<CALENDARIMG_TOTAL_WIDTH;w++));do
            points["$h,$w"]="$CALENDARIMG_COLOR_BG"
        done
    done
    declare -a col_counts
    declare -a row_counts

    for ((i=0;i<CALENDARIMG_COLS;i++));do
        col_counts[i]=0
    done
    for ((i=0;i<CALENDARIMG_ROWS;i++));do
        row_counts[i]=0
    done

    for ((cur_index=0;cur_index<CALENDARIMG_TOTAL;cur_index++)); do
        if [[ $CALENDARIMG_MAJOR == "row" ]];then
            cur_col=$((cur_index / CALENDARIMG_ROWS))
            cur_row=$((cur_index % CALENDARIMG_ROWS))
        else
            cur_col=$((cur_index % CALENDARIMG_COLS))
            cur_row=$((cur_index / CALENDARIMG_COLS))
        fi
        row_start_idx=$((cur_row * CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))
        col_start_idx=$((cur_col * CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))
        for ((i=0;i<CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER*2;i++));do
            for ((j=0;j<CALENDARIMG_BORDER;j++));do
                points["$((row_start_idx+j)),$((col_start_idx+i))"]="$CALENDARIMG_COLOR_BR"
                points["$((row_start_idx + CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER + j)),$((col_start_idx+i))"]="$CALENDARIMG_COLOR_BR"
                points["$((row_start_idx+i)),$((col_start_idx+j))"]="$CALENDARIMG_COLOR_BR"
                points["$((row_start_idx+i)),$((col_start_idx + CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER +j))"]="$CALENDARIMG_COLOR_BR"
            done
        done

        if [[ ${CALENDARIMG_DATA[$cur_index]} -eq 0 ]];then
            continue
        fi
        ((col_counts[cur_col]+=1))
        ((row_counts[cur_row]+=1))

        color_idx=0
        for ((;color_idx<CALENDARIMG_LAST_LEVEL;color_idx++));do
            if [[ "${CALENDARIMG_DATA[$cur_index]}" -lt ${CALENDARIMG_LEVEL_LIMITS[$color_idx]} ]];then
                break;
            fi
        done

        for ((i=0;i<CALENDARIMG_CELL_WIDTH;i++));do
            for ((j=0;j<CALENDARIMG_CELL_WIDTH;j++));do
                points["$((row_start_idx+CALENDARIMG_BORDER+j)),$((col_start_idx+CALENDARIMG_BORDER+i))"]="${CALENDARIMG_LEVEL_COLORS[$color_idx]}"
            done
        done
    done

    if [[ ${CALENDARIMG_SUMMARY_NUMBER^^} == "ENABLED" ]];then
        for ((i=0;i<CALENDARIMG_COLS;i++));do
            eval "$(calendarimg_draw_number "${col_counts[i]}" points col $i)"
        done
        for ((i=0;i<CALENDARIMG_ROWS;i++));do
            eval "$(calendarimg_draw_number "${row_counts[i]}" points row $i)"
        done
    fi

    echo -e "P3\n${CALENDARIMG_TOTAL_WIDTH} ${CALENDARIMG_TOTAL_HEIGTH}\n255\n" > "$1"
    for ((h=0;h<CALENDARIMG_TOTAL_HEIGTH;h++));do
        for ((w=0;w<CALENDARIMG_TOTAL_WIDTH;w++));do
            echo "${points["$h,$w"]}" >> "$1"
        done
    done
}
