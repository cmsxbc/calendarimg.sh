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
CALENDARIMG_COLOR_NDBR=${CALENDARIMG_COLOR_NDBR:-"0 0 0"}
CALENDARIMG_COLOR_NR=${CALENDARIMG_COLOR_NR:-"192 0 0"}


CALENDARIMG_MAJOR=${CALENDARIMG_MAJOR:-row}
CALENDARIMG_DATA_ORDER=${CALENDARIMG_DATA_ORDER:-normal}
CALENDARIMG_CONNECTED=${CALENDARIMG_CONNECTED:-disabled}

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
    CALENDARIMG_COLOR_NDBR="0 0 0 "
    CALENDARIMG_MAJOR="row"
    CALENDARIMG_DATA_ORDER="normal"
    CALENDARIMG_CONNECTED=disabled
    CALENDARIMG_COLS=0
    CALENDARIMG_ROWS=0
    unset CALENDARIMG_LEVEL_LIMITS
    unset CALENDARIMG_LEVEL_COLORS
    unset CALENDARIMG_DATA
    declare -a CALENDARIMG_LEVEL_LIMITS
    declare -a CALENDARIMG_LEVEL_COLORS
    declare -a CALENDARIMG_DATA
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


function calendarimg_extend_4_array {
    local name src_name ifs
    name="$1"
    src_name="$2"
    ifs="${3:- }"
    cat <<end
    IFS="${ifs}" read -r -a $name <<< "\${${src_name}^^}"
if [[ \${#${name}[@]} -eq 1 ]];then
    for ((i=1;i<4;i++));do
        ${name}[i]="\${${name}[0]}"
    done
elif [[ \${#${name}[@]} -eq 2 ]];then
    for ((i=0;i<2;i++));do
        ${name}[i+2]="\${${name}[i]}"
    done
fi
end
}


function calendarimg_draw_border {
    local i j i_end k l row_start_idx1 col_start_idx1 si valid_sis need_skip
    ((row_start_idx1=row_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER*2-1))
    ((col_start_idx1=col_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER*2-1))
    ((i_end=CALENDARIMG_CELL_WIDTH/2+CALENDARIMG_BORDER+1))
    valid_sis=""
    for ((si=0;si<4;si++));do
        if [[ "${border_styles[si]}" == "HIDDEN" ]];then
            continue
        fi
        valid_sis="$valid_sis $si"
    done
    for ((i=0;i<i_end;i++));do
        if [[ $(( (i / CALENDARIMG_BORDER) % 2 )) -gt 0 ]];then
            need_skip=1
        else
            need_skip=0
        fi
        for ((j=0;j<CALENDARIMG_BORDER;j++));do
            for si in $valid_sis;do
                if [[ "${border_styles[$si]}" == "DASHED" && $need_skip -gt 0 ]];then
                    continue;
                elif [[ "${border_styles[$si]}" == "EDGE" && $i -lt $CALENDARIMG_BORDER ]];then
                    continue;
                fi
                case $si in
                    0 )
                        points["$((row_start_idx+j)),$((col_start_idx+i))"]="${border_colors[si]}"
                        points["$((row_start_idx+j)),$((col_start_idx1-i))"]="${border_colors[si]}"
                        ;;
                    1 )
                        points["$((row_start_idx+i)),$((col_start_idx1-j))"]="${border_colors[si]}"
                        points["$((row_start_idx1-i)),$((col_start_idx1-j))"]="${border_colors[si]}"
                        ;;
                    2 )
                        points["$((row_start_idx1-j)),$((col_start_idx+i))"]="${border_colors[si]}"
                        points["$((row_start_idx1-j)),$((col_start_idx1-i))"]="${border_colors[si]}"
                        ;;
                    3 )
                        points["$((row_start_idx+i)),$((col_start_idx+j))"]="${border_colors[si]}"
                        points["$((row_start_idx1-i)),$((col_start_idx+j))"]="${border_colors[si]}"
                        ;;
                esac
            done
        done
    done
}


function calendarimg_draw_corner {
    # 0 1
    # 3 2
    local rs cs
    local -i i j k
    for i in {0..3};do
        if [[ ${draw_corners[i]} -le 0 ]];then
            continue
        fi
        case $i in
            0 )
                rs=$row_start_idx
                cs=$col_start_idx
                ;;
            1 )
                rs=$row_start_idx
                cs=$((col_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER))
                ;;
            2 )
                rs=$((row_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER))
                cs=$((col_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER))
                ;;
            3 )
                rs=$((row_start_idx+CALENDARIMG_CELL_WIDTH+CALENDARIMG_BORDER))
                cs=$col_start_idx
                ;;
        esac
        for ((j=0;j<CALENDARIMG_BORDER;j++));do
            for ((k=0;k<CALENDARIMG_BORDER;k++));do
                points["$((rs+j)),$((cs+k))"]="${corner_colors[i]}"
            done
        done
    done
}


function calendarimg_check_colors {
    if [[ -z "${CALENDARIMG_LEVEL_LIMITS[*]}" ]];then
        CALENDARIMG_LEVEL_LIMITS[0]=1
        CALENDARIMG_LEVEL_LIMITS[1]=3
        CALENDARIMG_LEVEL_LIMITS[2]=7
    fi

    if [[ -z "${CALENDARIMG_LEVEL_COLORS[*]}" ]];then
        CALENDARIMG_LEVEL_COLORS[0]="$CALENDARIMG_COLOR_BG"
        CALENDARIMG_LEVEL_COLORS[1]="0 192 0"
        CALENDARIMG_LEVEL_COLORS[2]="192 192 0"
        CALENDARIMG_LEVEL_COLORS[3]="255 0 0"
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

    data_total=$(( $(echo "${!CALENDARIMG_DATA[*]}" | awk '{print $NF}') + 1))

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
        return 1
    fi
    if ! calendarimg_check_colors;then
        return 1
    fi

    calendarimg_init

    local cur_index row_col_idx cur_row cur_col points row_start_idx col_start_idx w h i j k col_counts row_counts color_idx data_total
    declare -A points
    declare -a col_counts
    declare -a row_counts
    declare -a color_indices
    local -i side_idx
    local -a border_base_styles border_base_nodata_styles base_styles base_color
    local -A side_indices side_connected
    local -a corner_colors draw_corners border_styles border_colors

    eval "$(calendarimg_extend_4_array border_base_styles CALENDARIMG_BORDER_STYLE ' ')"
    eval "$(calendarimg_extend_4_array border_base_nodata_styles CALENDARIMG_NODATA_BORDER_STYLE ' ')"

    for ((cur_index=0;cur_index<CALENDARIMG_TOTAL;cur_index++));do
        if [ ! ${CALENDARIMG_DATA[cur_index]+notexist} ];then
            color_indices[cur_index]=-1
            continue
        fi
        color_idx=0
        for ((;color_idx<CALENDARIMG_LAST_LEVEL;color_idx++));do
            if [[ "${CALENDARIMG_DATA[$cur_index]}" -lt ${CALENDARIMG_LEVEL_LIMITS[$color_idx]} ]];then
                break;
            fi
        done
        color_indices[cur_index]=$color_idx
    done
    if [[ "${CALENDARIMG_CONNECTED^^}" == "ENABLED" ]];then
        for ((cur_index=0;cur_index<CALENDARIMG_TOTAL;cur_index++)); do
            if [[ ${CALENDARIMG_DATA_ORDER^^} == "REVERSED" ]];then
                row_col_idx=$((CALENDARIMG_TOTAL-1-cur_index))
            else
                row_col_idx=$cur_index
            fi
            if [[ ${CALENDARIMG_MAJOR^^} == "ROW" ]];then
                cur_col=$((row_col_idx / CALENDARIMG_ROWS))
                cur_row=$((row_col_idx % CALENDARIMG_ROWS))
                side_indices["$cur_index,0"]=$(( row_col_idx - 1 ))
                side_indices["$cur_index,1"]=$(( row_col_idx + CALENDARIMG_ROWS ))
                side_indices["$cur_index,2"]=$(( row_col_idx + 1 ))
                side_indices["$cur_index,3"]=$(( row_col_idx - CALENDARIMG_ROWS ))
            else
                cur_col=$((row_col_idx % CALENDARIMG_COLS))
                cur_row=$((row_col_idx / CALENDARIMG_COLS))
                side_indices["$cur_index,0"]=$(( row_col_idx - CALENDARIMG_COLS ))
                side_indices["$cur_index,1"]=$(( row_col_idx + 1 ))
                side_indices["$cur_index,2"]=$(( row_col_idx + CALENDARIMG_COLS ))
                side_indices["$cur_index,3"]=$(( row_col_idx - 1 ))
            fi
            if [[ ${CALENDARIMG_DATA_ORDER^^} == "REVERSED" ]];then
                for j in {0..3};do
                    side_indices["$cur_index,$j"]=$(( CALENDARIMG_TOTAL-1-side_indices["$cur_index,$j"] ))
                done
            fi
            color_idx=${color_indices[cur_index]}
            for j in {0..3};do
                side_idx=${side_indices["$cur_index,$j"]}
                if [[ $cur_row -eq 0 && $j -eq 0 ]];then
                    side_connected["$cur_index,$j"]=0
                elif [[ $cur_row -eq $(( CALENDARIMG_ROWS - 1 )) && $j -eq 2 ]];then
                    side_connected["$cur_index,$j"]=0
                elif [[ $cur_col -eq $(( CALENDARIMG_COLS - 1 )) && $j -eq 1 ]];then
                    side_connected["$cur_index,$j"]=0
                elif [[ $cur_col -eq 0 && $j -eq 3 ]];then
                    side_connected["$cur_index,$j"]=0
                elif [[ ${color_indices[side_idx]} -eq $color_idx ]];then
                    side_connected["$cur_index,$j"]=1
                else
                    side_connected["$cur_index,$j"]=0
                fi
            done
        done
    fi


    for ((i=0;i<CALENDARIMG_COLS;i++));do
        col_counts[i]=0
    done
    for ((i=0;i<CALENDARIMG_ROWS;i++));do
        row_counts[i]=0
    done

    for ((cur_index=0;cur_index<CALENDARIMG_TOTAL;cur_index++)); do
        if [[ ${CALENDARIMG_DATA_ORDER^^} == "REVERSED" ]];then
            row_col_idx=$((CALENDARIMG_TOTAL-1-cur_index))
        else
            row_col_idx=$cur_index
        fi
        if [[ ${CALENDARIMG_MAJOR^^} == "ROW" ]];then
            cur_col=$((row_col_idx / CALENDARIMG_ROWS))
            cur_row=$((row_col_idx % CALENDARIMG_ROWS))
        else
            cur_col=$((row_col_idx % CALENDARIMG_COLS))
            cur_row=$((row_col_idx / CALENDARIMG_COLS))
        fi
        row_start_idx=$((cur_row * CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))
        col_start_idx=$((cur_col * CALENDARIMG_ITEM_WIDTH + CALENDARIMG_MARGIN))

        color_idx=${color_indices[cur_index]}
        if [[ "${CALENDARIMG_CONNECTED^^}" == "ENABLED" ]];then
            if [[ $color_idx -ge 0 ]];then
                IFS=' ' read -r -a base_styles <<< "${border_base_styles[@]}"
                base_color="$CALENDARIMG_COLOR_BR"
            else
                IFS=' ' read -r -a base_styles <<< "${border_base_nodata_styles[@]}"
                base_color="$CALENDARIMG_COLOR_NDBR"
            fi
            for j in {0..3};do
                if [[ ${side_connected["$cur_index,$j"]} -eq 0 ]];then
                    border_styles[j]="${base_styles[j]}"
                    border_colors[j]="${base_color}"
                else
                    if [[ $color_idx -ge 0 ]];then
                        border_styles[j]="EDGE"
                    else
                        border_styles[j]="HIDDEN"
                    fi
                    border_colors[j]="${CALENDARIMG_LEVEL_COLORS[color_idx]}"
                fi
            done
            for j in {0..3};do
                k=$(( (j + 3) % 4 ))
                if [[ ${side_connected["$cur_index,$j"]} -gt 0 && ${side_connected["$cur_index,$k"]} -gt 0 ]];then
                    if [[ ${side_connected["${side_indices["$cur_index,$j"]},$k"]} -gt 0 && ${side_connected["${side_indices["$cur_index,$k"]},$j"]} -gt 0 ]];then
                        if [[ $color_idx -ge 0 ]];then
                            draw_corners[j]=1
                            corner_colors[j]="${CALENDARIMG_LEVEL_COLORS[color_idx]}"
                        else
                            draw_corners[j]=0
                            corner_colors[j]="${base_color}"
                        fi
                    else
                        draw_corners[j]=1
                        corner_colors[j]="${base_color}"
                    fi
                else
                    draw_corners[j]=0
                    corner_colors[j]="${base_color}"
                fi
            done
            calendarimg_draw_border
            calendarimg_draw_corner
        elif [[ $color_idx -ge 0 ]];then
            IFS=' ' read -r -a border_styles <<< "${border_base_styles[@]}"
            border_colors[0]="$CALENDARIMG_COLOR_BR"
            border_colors[1]="$CALENDARIMG_COLOR_BR"
            border_colors[2]="$CALENDARIMG_COLOR_BR"
            border_colors[3]="$CALENDARIMG_COLOR_BR"
            calendarimg_draw_border
        else
            IFS=' ' read -r -a border_styles <<< "${border_base_nodata_styles[@]}"
            border_colors[0]="$CALENDARIMG_COLOR_NDBR"
            border_colors[1]="$CALENDARIMG_COLOR_NDBR"
            border_colors[2]="$CALENDARIMG_COLOR_NDBR"
            border_colors[3]="$CALENDARIMG_COLOR_NDBR"
            calendarimg_draw_border
        fi

        if [[ $color_idx -lt 0 ]];then
            continue
        fi

        if [[ ${CALENDARIMG_DATA[cur_index]} -ne 0 ]];then
            ((col_counts[cur_col]+=1))
            ((row_counts[cur_row]+=1))
        fi


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
            if [ ${points["$h,$w"]+exist} ];then
                echo "${points["$h,$w"]}" >> "$1"
            else
                echo "$CALENDARIMG_COLOR_BG" >> "$1"
            fi
        done
    done
}
