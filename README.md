# calendarimg.sh
Draw Github Commit Calendar Image Like in Bash.

# features

1. support any shape!
2. customize!
3. draw summary number!

# usage

```bash
# import function
source calendarimg.sh

# set flags

# set data
for i in {0..362};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done

# draw & save to file
calendarimg_generate "output.ppm"
```

![default](examples/default.png)

## FLAGS/CONFIGURATION

Almost all flags/configurations support be set both before/after import, except those array.

### change size

1. `CALENDARIMG_CELL_WIDTH`: the width of calendar item, a calendar item is a square.
2. `CALENDARIMG_BORDER`: the border width of calendar item.
3. `CALENDARIMG_PADDING`: the width between two calendar item.
4. `CALENDARIMG_MARGIN`: the space width between side calendar item and canvas boundary.

### change shape

1. `CALENDARIMG_COLS`: how many columns.
2. `CALENDARIMG_ROWS`: how many rows.
3. `CALENDARIMG_MAJRO`: col major or row marjor, default is `row`.

The default shape is set the direction defined by `CALENDARIMG_MAJOR` to 7, and calculate the other side
by divided by total data size.

If either `CALENDARIMG_COLS` or `CALENDARIMG_ROWS` is set, the other side is calculated.

If both `CALENDARIMG_COLS` and `CALENDARIMG_ROWS` are set, they won't be calcuated, but the product should greater than total data size.


### change style
1. border style: availble values: `solid`, `dashed`, `hidden`

    1. `CALENDARIMG_BORDER_STYLE`: the border style when there is data, default to `solid`
    2. `CALENDARIMG_NODATA_BORDER_STYLE`: the border style when there is no data, default to `dashed`

### change data order

`CALENDARIMG_DATA_ORDER`, default is `normal`, availble choice is `reversed`.

1. when it is `normal`, `${CALENDARIMG_DATA[0]` is set to left-top.
2. when it is `reversed`, `${CALENDARIMG_DATA[0]` is set to right-bottom.

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


# examples

See [examples](examples/)

