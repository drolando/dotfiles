#!/usr/bin/env zsh

source $(pwd)/common.zsh

PACKAGES=(
    colordiff
    go
    htop
    neovim
    node
    tig
    tmux
    vim
    virtualenv
    zsh-completions
)

# Homebrew
if [[ ! -f $BREW ]]
then
    yellow Installing brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    yellow Updating  brew
    $BREW update &> /dev/null
fi

# .dotfiles folder in the right location
if [[ ! -d $HOME/.dotfiles ]]
then
    red Missing $HOME/.dotfiles folder
    exit 1
else
    green Found $HOME/.dotfiles folder
fi

# ZSH
if [[ ! -d $HOME/.oh-my-zsh ]]
then
    yellow Downloading oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null
else
    green Found $HOME/.oh-my-zsh
fi

link "$CURR_DIR/zsh/drolando.zsh-theme" "$HOME/.oh-my-zsh/themes/drolando.zsh-theme"

if [[ ! -d $CURR_DIR/zsh/zsh-syntax-highlighting ]]
then
    yellow Downloading zsh-syntax-highlighting
    clone "zsh-syntax-highlighting" https://github.com/zsh-users/zsh-syntax-highlighting.git "$CURR_DIR/zsh/zsh-syntax-highlighting"
fi
if [[ -d $CURR_DIR/zsh/zsh-syntax-highlighting ]]
then
    green Found $CURR_DIR/zsh/zsh-syntax-highlighting
fi

link "$CURR_DIR/zsh/zshrc" "$HOME/.zshrc"

# INSTALL DEPENDENCIES
$BREW update > /dev/null
yellow Installing brew packages
$BREW install --quiet ${PACKAGES[@]} > /dev/null
fail_on_error "Failed to install brew packages"
green Installed ${PACKAGES[@]}

for dot in gitconfig tmux.conf vimrc vimrc.plugins
do
  link "$CURR_DIR/$dot" "$HOME/.$dot"
done

# VIM
mkdir -p "$HOME/.vim"
mkdir -p "$HOME/.vim/plugged"
mkdir -p "$HOME/.config/nvim/"
link "$CURR_DIR/vimrc" "$HOME/.config/nvim/init.vim"

# vim: shiftwidth=4 smarttab expandtab
