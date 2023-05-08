# calendarimg.sh
Draw Github Commit Calendar Image Like in Bash.


# usage

```bash
# import function
source calendarimg.sh

# set data
for i in {0..363};do
    CALENDARIMG_DATA[i]=$(( i % 7 ));
done

# draw & save to file
calendarimg_generate "output.ppm"
```

# Tips

## Convert ppm to png

use `pnm2png` or `pnmtopng`
