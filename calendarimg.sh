#! /bin/bash

set -e

CALENDARIMG_CELL_WIDTH=${CALENDARIMG_CELL_WIDTH:-15}
CALENDARIMG_BORDER=${CALENDARIMG_BORDER:-5}
CALENDARIMG_PADDING=${CALENDARIMG_PADDING:-4}
CALENDARIMG_MARGIN=${CALENDARIMG_MARGIN:-20}

CALENDARIMG_COLS=${CALENDARIMG_COLS:-52}
CALENDARIMG_ROWS=${CALENDARIMG_ROWS:-7}

CALENDARIMG_SUMMARY_NUMBER=${CALENDARIMG_SUMMARY_NUMBER:-disabled}

declare CALENDARIMG_ITEM_WIDTH CALENDARIMG_TOTAL_WIDTH CALENDARIMG_TOTAL_HEIGTH

CALENDARIMG_COLOR_BG="255 255 255"
CALENDARIMG_COLOR_BR="0 0 0"
CALENDARIMG_COLOR_NR="192 0 0"


CALENDARIMG_MAJOR=${CALENDARIMG_MAJOR:-row}



declare -a CALENDARIMG_DATA
declare -a CALENDARIMG_LEVEL_LIMITS
declare -a CALENDARIMG_LEVEL_COLORS
CALENDARIMG_LAST_LEVEL=0

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER0=(
    "111111111111111"
    "111111111111111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111111111111111"
    "111111111111111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER1=(
    "000000000000000"
    "000000111000000"
    "000001111000000"
    "000011111000000"
    "000110111000000"
    "001100111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "000000111000000"
    "001111111111100"
    "001111111111100"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER2=(
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "111111111111111"
    "111111111111111"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111111111111111"
    "111111111111111"
)


# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER3=(
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "111111111111111"
    "111111111111111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER4=(
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER5=(
    "111111111111111"
    "111111111111111"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "111111111111111"
    "111111111111111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER6=(
    "111111111111111"
    "111111111111111"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111000000000000"
    "111111111111111"
    "111111111111111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111111111111111"
    "111111111111111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER7=(
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER8=(
    "111111111111111"
    "111111111111111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111111111111111"
    "111111111111111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111111111111111"
    "111111111111111"
)

# shellcheck disable=SC2034
declare -a CALENDARIMG_NUMBER9=(
    "111111111111111"
    "111111111111111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111000000000111"
    "111111111111111"
    "111111111111111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "000000000000111"
    "111111111111111"
    "111111111111111"
)


function calendarimg_draw_number {
    local number array_name direction idx row_start_idx col_start_idx number_var_name number_array
    number=$1
    array_name=$2
    direction=$3
    idx=$4
    if [[ "$direction" == "row" ]];then
        row_start_idx=$((idx*CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))
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
        declare -n number_array="CALENDARIMG_NUMBER${number_var_name}"
        for ((i=0;i<CALENDARIMG_CELL_WIDTH+2*CALENDARIMG_BORDER;i++));do
            for ((j=0;j<CALENDARIMG_CELL_WIDTH;j++));do
                if [[ "${number_array[i]:j:1}" -gt 0 ]];then
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


function calendarimg_init_size {
    local addition_items
    addition_items=0
    if [[ ${CALENDARIMG_SUMMARY_NUMBER^^} == "ENABLED" ]];then
        addition_items=2
    fi
    CALENDARIMG_ITEM_WIDTH=$((CALENDARIMG_CELL_WIDTH + CALENDARIMG_BORDER * 2 + CALENDARIMG_PADDING))
    CALENDARIMG_TOTAL_WIDTH=$((CALENDARIMG_ITEM_WIDTH * (CALENDARIMG_COLS + addition_items) - CALENDARIMG_PADDING + CALENDARIMG_MARGIN * 2))
    CALENDARIMG_TOTAL_HEIGTH=$((CALENDARIMG_ITEM_WIDTH * (CALENDARIMG_ROWS + addition_items) - CALENDARIMG_PADDING + CALENDARIMG_MARGIN * 2))
}


function calendarimg_generate {

    if [[ -z "$1" ]];then
        echo "lack of output filepath" >&2;
        return
    fi
    if ! calendarimg_check_colors;then
        return
    fi

    if [[ $((CALENDARIMG_COLS * CALENDARIMG_ROWS)) -ne 364 ]];then
        echo "cols * rows != 364" >&2;
        return
    fi
    calendarimg_init_size


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

    for cur_index in {0..363}; do
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

        for ((i=0;i<CALENDARIMG_CELL_WIDTH;i++));do
            for ((j=0;j<CALENDARIMG_CELL_WIDTH;j++));do
                for ((color_idx=0;color_idx<CALENDARIMG_LAST_LEVEL;color_idx++));do
                    if [[ "${CALENDARIMG_DATA[$cur_index]}" -lt ${CALENDARIMG_LEVEL_LIMITS[$color_idx]} ]];then
                        points["$((row_start_idx+CALENDARIMG_BORDER+j)),$((col_start_idx+CALENDARIMG_BORDER+i))"]="${CALENDARIMG_LEVEL_COLORS[$color_idx]}"
                        continue 2;
                    fi
                done
                points["$((row_start_idx+CALENDARIMG_BORDER+j)),$((col_start_idx+CALENDARIMG_BORDER+i))"]="${CALENDARIMG_LEVEL_COLORS[$CALENDARIMG_LAST_LEVEL]}"
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
