# calendarimg.sh Examples

## Default

```bash
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![default](default.png)

## Modify cell width

```bash
CALENDARIMG_CELL_WIDTH=40
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_cell_width](modify_cell_width.png)

## Modify border

```bash
CALENDARIMG_BORDER=1
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_border](modify_border.png)

## Modify border style

```bash
CALENDARIMG_BORDER_STYLE="dashed"
CALENDARIMG_NODATA_BORDER_STYLE="solid"
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_border_style](modify_border_style.png)

## Modify border style by direction

```bash
CALENDARIMG_BORDER_STYLE="dashed solid"
CALENDARIMG_NODATA_BORDER_STYLE="solid dashed"
for i in {0..20};do
    if [[ $((i % 2)) -gt 0 ]];then
        continue
    fi
    CALENDARIMG_DATA[i]=1;
done
```

![modify_border_style_by_direction](modify_border_style_by_direction.png)

## Modify border style by side

```bash
CALENDARIMG_BORDER_STYLE="dashed solid hidden dashed"
CALENDARIMG_NODATA_BORDER_STYLE="solid hidden dashed solid"
for i in {0..20};do
    if [[ $((i % 2)) -gt 0 ]];then
        continue
    fi
    CALENDARIMG_DATA[i]=1;
done
```

![modify_border_style_by_side](modify_border_style_by_side.png)

## Modify padding

```bash
CALENDARIMG_PADDING=10
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_padding](modify_padding.png)

## Modify margin and background color

```bash
CALENDARIMG_MARGIN=50
CALENDARIMG_COLOR_BG="0 0 192"
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_margin_and_background_color](modify_margin_and_background_color.png)

## Modify major

```bash
CALENDARIMG_MAJOR="col"
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_major](modify_major.png)

## Modify rows

```bash
CALENDARIMG_ROWS=15
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_rows](modify_rows.png)

## Modify cols

```bash
CALENDARIMG_COLS=30
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done
```

![modify_cols](modify_cols.png)

## Modify level colors

```bash
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
```

![modify_level_colors](modify_level_colors.png)

## Show summary number

```bash
CALENDARIMG_SUMMARY_NUMBER=enabled
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7));
done
```

![show_summary_number](show_summary_number.png)

## Reversed data

```bash
CALENDARIMG_DATA_ORDER=reversed
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7));
done
```

![reversed_data](reversed_data.png)

## Lack of item

```bash
CALENDARIMG_COLOR_BR="192 192 0"
CALENDARIMG_COLOR_NDBR="0 0 192"
for i in {0..362};do
    if [[ $((i % 13)) -eq 0 ]];then
        continue
    fi
    CALENDARIMG_DATA[i]=$(( i % 7));
done
```

![lack_of_item](lack_of_item.png)
