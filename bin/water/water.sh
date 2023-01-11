#!/usr/bin/env bash

# this script enables water tracking in tmux status bar via a simple command
usage() {
    cat <<EOF
usage: $0 [-c|r|s|u|h] [WATER]

Options:
  -c, --colorize    enables tmux color options
  -s, --symbol      enables nerdfont compaitable symbol
  -r, --reset       reset the days water to 0
  -u, --undo        removes the last entry
                      can be done repeatedly
  -h, --help        display this message

The WATER arguement is an integer and will be added to the current total.
If a mistake is made, -u can remove the faulty entry.
EOF
}

DATE=$(date +%b_%d_%y)
TIME=$(date +%H:%M:%S)

WATER_DIR="$HOME/.dotfiles/bin/water"
WATERFILE="${WATER_DIR}/${DATE}.csv" # makes it easy to reset on each new day

# make dir on fresh installs
if [[ ! -d "${WATER_DIR}/archive" ]] ; then
    mkdir -p "${WATER_DIR}/archive"
fi

get_current_amt() {
    # gets the current water intake

    if [[ ! -f "$WATERFILE" ]] ; then
        # no waterfile

        # archiving old file
        mv *.csv ${WATER_DIR}/archive
        # creating new file for the day
        printf 'Time, Change, Running Total\n' > "$WATERFILE"
        printf '%s, 0, 0\n' "$TIME" >> "$WATERFILE"
    else
        # waterfile exists
        CURRENT_WATER=$(cat $WATERFILE | tail -n 1 | awk '{print $3}')
    fi
}

update_water() {
    # updates water based on $WATER_CHANGE
    CURRENT_WATER=$(($CURRENT_WATER + $WATER_CHANGE))

    # putting in file
    printf '%s, %d, %d\n' "$TIME" $WATER_CHANGE $CURRENT_WATER >> "$WATERFILE"
}

undo_change() {
    # removes the last entry up to the first

    if [[ $(wc -l < "$WATERFILE") -gt 2 ]] ; then
        # removing last entry
        lastentry=$(cat "$WATERFILE" | tail -n 1)
        ts=$(echo "$lastentry" | awk -F , '{print $1}')
        amt=$(echo "$lastentry" | awk -F , '{print $2}')
        prompt=$(printf 'Are you sure you want to remove the %d fl oz added at %s?(y/n)\n' $amt "$ts")
        read -p "$prompt" -n 1 -r

        if [[ $REPLY =~ ^[Yy]$ ]] ; then
            # remove
            sed -i '$d' "$WATERFILE"
        fi
        echo ""
        get_current_amt
    else
        echo "No changes to undo!"
    fi
}

colorize() {
    # sends water intake level through conditionals to be colorized

    if [[ $1 -lt 32 ]] ; then
        color='#[fg=color1]' # red
    elif [[ $1 -lt 64 ]] ; then
        color='#[fg=color3]' # bad yellow
    elif [[ $1 -lt 96 ]] ; then
        color='#[fg=color226]' # pale yellow
    elif [[ $1 -lt 128 ]] ; then
        color='#[fg=color10]' # light green
    else
        color='#[fg=color21]' # blue 
    fi

    printf '%s' "$color"
}

print_water() {
    # prints total
    if [ "$COLORIZE" = true ] ; then
        dflt="#[default]"
        printf '%s' "$(colorize $CURRENT_WATER)"
    fi

    if [ "$SYMBOL" = true ] ; then
        printf '%s ' $(echo -e '\uf6aa')
    fi

    printf '%d%s\n' $CURRENT_WATER "$dflt"
}

# handle long forms
for arg in "$@"; do
    shift
    case "$arg" in
        '--help')       set -- "$@" "-h"    ;;
        '--colorize')   set -- "$@" "-c"    ;;
        '--reset')      set -- "$@" "-r"    ;;
        '--undo')       set -- "$@" "-u"    ;;
        '--symbol')     set -- "$@" "-s"    ;;
        *)              set -- "$@" "$arg"  ;;
    esac
done

get_current_amt

# parsing args
while getopts "hcrsu" opt ; do
    case "$opt" in 
        'h' )
            usage
            exit 0
            ;;
        'c' )
            COLORIZE=true
            ;;
        's' )
            SYMBOL=true
            ;;
        'u' )
            undo_change
            ;;
        'r' )
            reset_water
            ;;
        '?' )
            usage
            exit 1
            ;;
    esac
done

shift $(($OPTIND - 1))

WATER_CHANGE=$1
if [[ ! -z "$WATER_CHANGE" ]] ; then
    # prevent empty/0 updates
    update_water
fi

print_water
