#!/usr/bin/env bash
get_qotd() {
    # needs $quotes_json to be set
    len=$(echo "$quotes_json" | gojq '. | length ')
    qotd=$(( $RANDOM % $len ))
    quote=$(echo "$quotes_json" | gojq -r ".[$qotd].q")
    author=$(echo "$quotes_json" | gojq -r ".[$qotd].a")
}

cur_date=$(date +%m-%d)
quotes_file="$HOME/.dotfiles/bin/startup/$cur_date.json"
if [[ ! -f $quotes_file ]] ; then
    # quotes file doesn't exist
    # remove old files and create new one
    quotes_json=$(curl --silent -fL "https://zenquotes.io/api/quotes/")
    old_files="$HOME"/.dotfiles/bin/startup/*.json
    if [[ ! -z $old_files ]] ; then
        rm "$HOME"/.dotfiles/bin/startup/*.json
    fi
    echo "$quotes_json" > "$HOME/.dotfiles/bin/startup/$cur_date.json"
else
    # quotes file doesn't exist
    quotes_json=$(cat "$quotes_file")
fi

get_qotd # sets quote and author
printf '"%s"\n   - %s\n' "$quote" "$author" | fold -s
