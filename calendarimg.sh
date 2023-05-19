#! /bin/bash

set -e

declare CALENDARIMG_ITEM_WIDTH CALENDARIMG_TOTAL_WIDTH CALENDARIMG_TOTAL_HEIGTH CALENDARIMG_TOTAL
declare -a CALENDARIMG_DATA
declare -a CALENDARIMG_LEVEL_LIMITS
declare -a CALENDARIMG_LEVEL_COLORS
declare -a CALENDARIMG_NUMBERS_DATA

CALENDARIMG_CELL_WIDTH=${CALENDARIMG_CELL_WIDTH:-15}
CALENDARIMG_BORDER=${CALENDARIMG_BORDER:-5}
CALENDARIMG_PADDING=${CALENDARIMG_PADDING:-4}
CALENDARIMG_MARGIN=${CALENDARIMG_MARGIN:-20}
CALENDARIMG_BORDER_STYLE=${CALENDARIMG_BORDER_STYLE:-solid}
CALENDARIMG_NODATA_BORDER_STYLE=${CALENDARIMG_NODATA_BORDER_STYLE:-dashed}

CALENDARIMG_COLS=${CALENDARIMG_COLS:-0}
CALENDARIMG_ROWS=${CALENDARIMG_ROWS:-0}

CALENDARIMG_SUMMARY_NUMBER=${CALENDARIMG_SUMMARY_NUMBER:-disabled}

CALENDARIMG_COLOR_BG=${CALENDARIMG_COLOR_BG:-"255 255 255"}
CALENDARIMG_COLOR_BR=${CALENDARIMG_COLOR_BR:-"0 0 0"}
CALENDARIMG_COLOR_NR=${CALENDARIMG_COLOR_NR:-"192 0 0"}


CALENDARIMG_MAJOR=${CALENDARIMG_MAJOR:-row}
CALENDARIMG_DATA_ORDER=${CALENDARIMG_DATA_ORDER:-normal}

CALENDARIMG_LAST_LEVEL=0


function calendarimg_reset_default {
    CALENDARIMG_CELL_WIDTH=15
    CALENDARIMG_BORDER=5
    CALENDARIMG_PADDING=4
    CALENDARIMG_MARGIN=20
    CALENDARIMG_BORDER_STYLE=solid
    CALENDARIMG_NODATA_BORDER_STYLE=dashed
    CALENDARIMG_SUMMARY_NUMBER=disabled
    CALENDARIMG_COLOR_BG="255 255 255"
    CALENDARIMG_COLOR_BR="0 0 0"
    CALENDARIMG_COLOR_NR="192 0 0"
    CALENDARIMG_MAJOR="row"
    CALENDARIMG_DATA_ORDER="normal"
    CALENDARIMG_COLS=0
    CALENDARIMG_ROWS=0
    unset CALENDARIMG_LEVEL_LIMITS
    unset CALENDARIMG_LEVEL_COLORS
    declare -a CALENDARIMG_LEVEL_LIMITS
    declare -a CALENDARIMG_LEVEL_COLORS
}


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
        if [[ $pad1 -gt 0 ]];then
            pc4="$(printf "0%.0s" $(seq 1 $pad1))"
        fi
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


function calendarimg_draw_border {
    local style array_name row_start_idx col_start_idx i j i_end k l row_start_idx1 col_start_idx1
    style="$1"
    array_name="$2"
    row_start_idx=$3
    col_start_idx=$4
    if [[ $style == "solid" ]];then
        for ((i=0;i<CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER*2;i++));do
            for ((j=0;j<CALENDARIMG_BORDER;j++));do
                echo "${array_name}[\"$((row_start_idx+j)),$((col_start_idx+i))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx + CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER + j)),$((col_start_idx+i))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx+i)),$((col_start_idx+j))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx+i)),$((col_start_idx + CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER +j))\"]=\"$CALENDARIMG_COLOR_BR\""
            done
        done
    elif [[ $style == "dashed" ]];then
        ((row_start_idx1=row_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER*2-1))
        ((col_start_idx1=col_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER*2-1))
        ((i_end=CALENDARIMG_CELL_WIDTH/2+CALENDARIMG_BORDER+1))
        for ((i=0;i<i_end;i++));do
            if [[ $(( (i / CALENDARIMG_BORDER) % 2 )) -gt 0 ]];then
                # echo "$i skipped\n\n"
                continue;
            fi
            for ((j=0;j<CALENDARIMG_BORDER;j++));do

                echo "${array_name}[\"$((row_start_idx+j)),$((col_start_idx+i))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx+i)),$((col_start_idx+j))\"]=\"$CALENDARIMG_COLOR_BR\""

                echo "${array_name}[\"$((row_start_idx+i)),$((col_start_idx1-j))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx+j)),$((col_start_idx1-i))\"]=\"$CALENDARIMG_COLOR_BR\""


                echo "${array_name}[\"$((row_start_idx1-j)),$((col_start_idx+i))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx1-i)),$((col_start_idx+j))\"]=\"$CALENDARIMG_COLOR_BR\""

                echo "${array_name}[\"$((row_start_idx1-j)),$((col_start_idx1-i))\"]=\"$CALENDARIMG_COLOR_BR\""
                echo "${array_name}[\"$((row_start_idx1-i)),$((col_start_idx1-j))\"]=\"$CALENDARIMG_COLOR_BR\""

            done
        done
    fi
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
    local addition_items data_total
    addition_items=0
    if [[ ${CALENDARIMG_SUMMARY_NUMBER^^} == "ENABLED" ]];then
        addition_items=2
    fi

    data_total=${#CALENDARIMG_DATA[@]}

    if [[ $CALENDARIMG_COLS -eq 0 && $CALENDARIMG_ROWS -eq 0 ]];then
        if [[ $CALENDARIMG_MAJOR == "row" ]];then
            CALENDARIMG_ROWS=7
        else
            CALENDARIMG_COLS=7
        fi
    fi

    if [[ $CALENDARIMG_COLS -le 0 && $CALENDARIMG_ROWS -le 0 ]];then
        echo "CALENDARIMG_ROWS=$CALENDARIMG_ROWS, CALENDARIMG_COLS=$CALENDARIMG_COLS, both <= 0" >&2
        exit 1
    elif [[ $CALENDARIMG_COLS -le 0 ]];then
        ((CALENDARIMG_COLS=data_total/CALENDARIMG_ROWS))
        if [[ $((CALENDARIMG_COLS * CALENDARIMG_ROWS)) -lt data_total ]];then
            ((CALENDARIMG_COLS+=1))
        fi
    elif [[ $CALENDARIMG_ROWS -le 0 ]];then
        ((CALENDARIMG_ROWS=data_total/CALENDARIMG_COLS))
        if [[ $((CALENDARIMG_COLS * CALENDARIMG_ROWS)) -lt data_total ]];then
            ((CALENDARIMG_ROWS+=1))
        fi
    elif [[ $((CALENDARIMG_COLS * CALENDARIMG_ROWS)) -lt data_total ]];then
        echo "Too small shape, there is $data_total values, but shape (rows * cols) is $CALENDARIMG_ROWS * $CALENDARIMG_COLS" >&2
        exit 1
    fi


    CALENDARIMG_ITEM_WIDTH=$((CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER * 2 + CALENDARIMG_PADDING))
    CALENDARIMG_TOTAL_WIDTH=$((CALENDARIMG_ITEM_WIDTH * (CALENDARIMG_COLS + addition_items) - CALENDARIMG_PADDING + CALENDARIMG_MARGIN * 2))
    CALENDARIMG_TOTAL_HEIGTH=$((CALENDARIMG_ITEM_WIDTH * (CALENDARIMG_ROWS + addition_items) - CALENDARIMG_PADDING + CALENDARIMG_MARGIN * 2))
    CALENDARIMG_TOTAL=$((CALENDARIMG_COLS * CALENDARIMG_ROWS))
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

    calendarimg_init


    local cur_index row_col_idx cur_row cur_col points row_start_idx col_start_idx w h i j col_counts row_counts color_idx data_total style
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

    data_total=${#CALENDARIMG_DATA[@]}

    for ((cur_index=0;cur_index<CALENDARIMG_TOTAL;cur_index++)); do
        if [[ $CALENDARIMG_DATA_ORDER == "reversed" ]];then
            row_col_idx=$((CALENDARIMG_TOTAL-1-cur_index))
        else
            row_col_idx=$cur_index
        fi
        if [[ $CALENDARIMG_MAJOR == "row" ]];then
            cur_col=$((row_col_idx / CALENDARIMG_ROWS))
            cur_row=$((row_col_idx % CALENDARIMG_ROWS))
        else
            cur_col=$((row_col_idx % CALENDARIMG_COLS))
            cur_row=$((row_col_idx / CALENDARIMG_COLS))
        fi
        row_start_idx=$((cur_row * CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))
        col_start_idx=$((cur_col * CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))
        if [[ $cur_index -lt data_total ]];then
            style="$CALENDARIMG_BORDER_STYLE"
        else
            style="$CALENDARIMG_NODATA_BORDER_STYLE"
        fi
        eval "$(calendarimg_draw_border "$style" points $row_start_idx $col_start_idx)"

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
