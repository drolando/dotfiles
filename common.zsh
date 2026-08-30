#!/usr/bin/env zsh
#
autoload -Uz colors && colors

CURR_DIR=$(pwd)
BREW=/opt/homebrew/bin/brew

# macOS uses Homebrew for package management; Ubuntu devboxes don't have it
# and packages there are provisioned separately (outside this repo), so
# scripts should check IS_MAC before doing anything Homebrew-specific.
OS=$(uname -s)
IS_MAC=false
[[ "$OS" == "Darwin" ]] && IS_MAC=true

function yellow() {
    print -- $fg_bold[yellow]$*$reset_color
}

function red() {
    print -- $fg_bold[red]$*$reset_color
}

function green() {
    print -- $fg_bold[green]$*$reset_color
}

function fail_on_error {
    if [[ $? -ne 0 ]]
    then
        red $ERROR $1
        exit 1
    fi
}

# Clone a repository and exit on failure
function clone {
    NAME=$1
    REPO=$2
    TARGET_DIR=$3

    git clone "$REPO" "$TARGET_DIR" > /dev/null
    fail_on_error "Failed to download $NAME"
}

# Create a symbolic link and exit on failure
function link {
    SOURCE_FILE=$1
    TARGET_FILE=$2

    if [[ -L $TARGET_FILE ]]
    then
        # Already a symlink -- if it points somewhere else, there's nothing
        # to lose by overwriting it, so force-relink without backing up.
        if [[ $(readlink -f "$TARGET_FILE") != $(readlink -f "$SOURCE_FILE") ]]
        then
            yellow Relinking $TARGET_FILE
            ln -sf "$SOURCE_FILE" "$TARGET_FILE"
            fail_on_error "Failed to relink $TARGET_FILE"
        fi
    elif [[ -f $TARGET_FILE ]]
    then
        # A real file with actual content -- back it up before replacing it
        yellow Backing up old file as $TARGET_FILE.old
        mv "$TARGET_FILE" "$TARGET_FILE.old"
        fail_on_error "Failed to backup $TARGET_FILE"

        yellow Linking $TARGET_FILE
        ln -s "$SOURCE_FILE" "$TARGET_FILE"
        fail_on_error "Failed to create symlink $TARGET_FILE"
    else
        yellow Linking $TARGET_FILE
        ln -s "$SOURCE_FILE" "$TARGET_FILE"
        fail_on_error "Failed to create symlink $TARGET_FILE"
    fi

    if [[ -L $TARGET_FILE && $(readlink -f "$TARGET_FILE") == $(readlink -f "$SOURCE_FILE") ]]
    then
        green $TARGET_FILE was correctly linked
    else
        red Failed to link $TARGET_FILE
    fi
}

# Update a repository and exit on failure
function update {
    NAME=$1
    TARGET_DIR=$2

    cd "$TARGET_DIR" || exit
    git fetch origin > /dev/null
    git pull > /dev/null
    fail_on_error "Failed to update $NAME"
    cd "$CURR_DIR" || exit > /dev/null
    green Successfully updated $NAME
}

function update_or_clone() {
    NAME=$1
    REPO=$2
    TARGET_DIR=$3

    if [ ! -d "$TARGET_DIR" ]
    then
        yellow Downloading $NAME
        clone $NAME $REPO $TARGET_DIR
    else
        yellow Updating $NAME
        update $NAME $TARGET_DIR
    fi
}
