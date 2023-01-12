#!/usr/bin/env bash

# this script enables water tracking in tmux status bar via a simple command

usage() {
    cat <<EOF
usage: $0 [-chr][-s|S][-u|U QTY] [WATER]

Options:
  -c, --colorize    enables tmux color options
  -s, --symbol      enables static nerdfont compaitable symbol
  -S                enables dynamic nf symbol 
  -u, --undo        removes the last entry
  -U                removes the last QTY entries.
                     use all as QTY to remove all entries
  -r, --reminder    creates a tmux pop up to remind you to hydrate
  -h, --help        display this message

The reminder works based on specified water goals
Defaults to 32 ounces by 10 am, 64 by 1 pm, 96 by 5 pm, and 128 by 8 pm
Goals are defined in the script itself.
If a sub goal is not reached, the reminder will trigger
Reminders have a dismiss option as well as an entry box to enter the water drank
Reminders will pop up every 30 minutes until the goal is reached

The WATER arguement is an integer and will be added to the current total.
If a mistake is made, -u can remove the faulty entry.
EOF
exit $1
}

# Hydration thresholds for reminders, all in fl. oz.
# Triggers reminder if you aren't at GOAL#/INTAKE by the assocaited time
# so in this example, if I don't drink 32 ounces by 10 am, I will get an alert
# 64 ounces by 1 pm, etc.

####################################
GOAL_AMT=128
GOALS=( "10:00" "13:00" "16:00" "20:00" ) 
SNOOZE=$((30 * 60)) # time between reminders (s)
####################################

DATE=$(date +%b_%d_%y)
TIME=$(date +%H:%M:%S)

WATER_DIR="$HOME/.dotfiles/bin/water"
WATERFILE="${WATER_DIR}/${DATE}.csv" # makes it easy to reset on each new day

# make dir on fresh installs
if [[ ! -d "${WATER_DIR}/archive" ]] ; then
    mkdir -p "${WATER_DIR}/archive"
fi

check_reminder() {
    # checks for reminder
    # uses tmux to push reminder

    if [[ -z "$TMUX" ]] ; then
        echo "TMUX required for reminder!"
        exit 1
    fi

    # this will round up
    goal_incr=$((($GOAL_AMT + ${#GOALS[@]}-1) / ${#GOALS[@]}))

    # based on water drank, time to check
    cur_indx=$(($CURRENT_WATER / $goal_incr))

    if [[ $CURRENT_WATER -lt $GOAL_AMT ]] ; then
        # goals not finished, check pace
        time_unix=$(date -d "$TIME" +%s)
        expired=$(( $(date -d "${GOALS[$cur_indx]}" +%s) - $time_unix))
         
        if [[ $expired -lt 0 ]] ; then
            # goal missed, check snooze
            source "$WATER_DIR/.reminder" 2>/dev/null
            # check elapsed
            if [[ $time_unix -gt $REMINDER_SNOOZE ]] ; then
                # trigger reminder
                goal=$(( ($GOAL_AMT * ($cur_indx + 1)) / ${#GOALS[@]}))

                fmt_time=$(date -d "${GOALS[$cur_indx]}" "+%l:%M %P")
                rem_info=$(printf 'You have only drank %d fl. oz. while your goal is to drink %d fl. oz. by %s!\n\nThis reminder will reappear in %d minutes unless you consume fluids!\n\nOr, mute this reminder until tomorrow' $CURRENT_WATER $goal "$fmt_time" $(($SNOOZE/60)))
                tmux display-popup -E\
                    dialog\
                    --title 'DEHYDRATION ALERT'\
                    --yes-label 'Dismiss'\
                    --no-label 'Mute'\
                    --yesno \
                    "$rem_info" 0 0

                # check for mute
                if [[ $? == 1 ]] ; then
                    # muted until tomorrow
                    TTS=$(date -d "tomorrow 00:00:00" +%s)
                else 
                    TTS=$(( $(date +%s) + $SNOOZE))
                fi

                # update last_reminder
                printf 'REMINDER_SNOOZE=%d\n' $TTS > "$WATER_DIR/.reminder"
            fi
        fi
    fi
}

get_current_amt() {
    # gets the current water intake

    if [[ ! -f "$WATERFILE" ]] ; then
        # no waterfile

        # archiving old file
        mv ${WATER_DIR}/*.csv ${WATER_DIR}/archive
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

undo_changes() {
    # removes specifed entries

    # gets the lines of entries
    WATER_LINES=$(($(wc -l < "$WATERFILE") - 2)) 
    if [[ $WATER_LINES -gt 0 ]] ; then
        # removing entries
        if [[ "$1" == "all" || "$1" == "ALL" ]] ; then
            # force a reset
            REMOVAL=$WATER_LINES
        elif [[ $1 =~ ^[0-9]+$ ]] ; then
            # remove $1 changes
            REMOVAL=$1
        else
            printf 'Arguement %s not recognized\n' "$1"
            usage
            exit 1
        fi

        choice=$(bash -c "read -p 'Are you sure you want to remove the changes? (y/n)' -n 1 -r c; echo \$c")
        echo ""

        if [[ $REPLY =~ ^[Yy]$ ]] ; then
            # remove
            if [[ $WATER_LINES -gt $REMOVAL ]] ; then
                # removing specified lines
                last_line=$(($WATER_LINES - $1 + 1)) # account for offset
                sed -i "$last_line ,$ d" "$WATERFILE"
            else 
                # essentially a reset
                printf 'Time, Change, Running Total\n' > "$WATERFILE"
                printf '%s, 0, 0\n' "$TIME" >> "$WATERFILE"
            fi
        fi
    fi
    echo "Done!\n"
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

    # dynamic symbol, uses battery because close enough
    # colors blue to avoid mistaking
    if [ "$DYN_SYMBOL" = true ] ; then
        lvl=$((($CURRENT_WATER * 10) / $GOAL_AMT)) # rounds down to nearst 10%
        # base = full
        SYM='\uf578'

        if [[ $lvl -eq 0 ]] ; then
            SYM='\uf58d'
        elif [[ $lvl -lt 9 ]] ; then
            # leverage consecutive symbols

            SYM=$(printf 'f5%x' $((120+$lvl)))
            SYM=$(echo -e "\u$SYM")
        fi
        if [ "$COLORIZE" = true ] ; then
            clr="#[fg=color21]"
        fi
        printf '%s%s ' "$clr" "$SYM"
    fi

    if [ "$COLORIZE" = true ] ; then
        dflt="#[default]"
        printf '%s' "$(colorize $CURRENT_WATER)"
    fi

    # static symbol
    if [ "$SYMBOL" = true ] ; then
        printf '\uf6aa '
    fi
    
    printf '%d%s\n' $CURRENT_WATER "$dflt"

    # checks for a reminder
    if [[ "$REMINDER" = true ]] ; then
        # reminders enabled
        check_reminder
    fi
}

# handle long forms
for arg in "$@"; do
    shift
    case "$arg" in
        '--help')       set -- "$@" "-h"    ;;
        '--colorize')   set -- "$@" "-c"    ;;
        '--reminder')   set -- "$@" "-r"    ;;
        '--undo')       set -- "$@" "-u"    ;;
        '--symbol')     set -- "$@" "-s"    ;;
        *)              set -- "$@" "$arg"  ;;
    esac
done

get_current_amt

# parsing args
while getopts "hcrsSuU:" opt ; do
    case "$opt" in 
        'c' )
            COLORIZE=true
            ;;
        's' )
            [ -n "$DYN_SYMBOL" ] && usage 1 || SYMBOL=true
            ;;
        'S' )
            [ -n "$SYMBOL" ] && usage 1 || DYN_SYMBOL=true
            ;;
        'u' )
            [ -n "$UNDO" ] && usage 1 || UNDO=1
            ;;
        'U' )
            [ -n "$UNDO" ] && usage 1 || UNDO="$optarg"
            ;;
        'r' )
            REMINDER=true
            ;;
        'h' )
            usage
            ;;
        '?' )
            usage 1 >&2
            ;;
    esac
done

# perform undo
if [[ ! -z "$UNDO" ]] ; then
    undo_changes "$UNDO"
fi

shift $(($OPTIND - 1))

WATER_CHANGE=$1
if [[ ! -z "$WATER_CHANGE" ]] ; then
    # prevent empty/0 updates
    update_water
fi

print_water
