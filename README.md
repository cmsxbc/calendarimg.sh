# calendarimg.sh
Draw Github Commit Calendar Image Like in Bash.


# usage

```bash
# import function
source calendarimg.sh

# set flags

# set data
for i in {0..363};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done

# draw & save to file
calendarimg_generate "output.ppm"
```

## FLAGS/CONFIGURATION

### change size

1. `CALENDARIMG_CELL_WIDTH`: the width of calendar item, a calendar item is a square.
2. `CALENDARIMG_BORDER`: the border width of calendar item.
3. `CALENDARIMG_PADDING`: the width between two calendar item.
4. `CALENDARIMG_MARGIN`: the space width between side calendar item and canvas boundary.

### change shape

1. `CALENDARIMG_COLS`: how many columns.
2. `CALENDARIMG_ROWS`: how many rows.
3. `CALENDARIMG_MAJRO`: col major or row marjor, default is `row`.

### change level & colors

1. `CALENDARIMG_LEVEL_LIMITS`: limits for every level except last.
2. `CALENDARIMG_LEVEL_COLORS`: colors for every level, in format of `{r} {g} {b}`. e.g. `192 192 192`

`CALENDARIMG_LEVEL_COLORS` and `CALENDARIMG_LEVEL_LIMITS` are arrays.

`${#CALENDARIMG_LEVEL_COLORS[@]} = ${#CALENDARIMG_LEVEL_LIMITS[@]} + 1`.

### change other colors

1. `CALENDARIMG_COLOR_BG`: backgroud color
2. `CALENDARIMG_COLOR_BR`: border color
3. `CALENDARIMG_COLOR_NR`: number color

### summary number

show a summary number for every rows and cols.

`CALENDARIMG_SUMMARY_NUMBER=enabled`

# Tips

## Convert ppm to png

use `pnm2png` or `pnmtopng`
