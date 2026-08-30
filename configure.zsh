#!/usr/bin/env zsh
#
# Single entry point for both fresh-machine setup and updating an existing
# one. Every step below is idempotent -- installs what's missing, updates
# what's already there -- so this is safe to (re)run on any box, any time.

CURR_DIR=~/.dotfiles
source $CURR_DIR/common.zsh

# ===============================================================================
# ================================  HOMEBREW  ====================================
# ===============================================================================
if $IS_MAC
then
    if [[ ! -f $BREW ]]
    then
        yellow Installing brew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        yellow Updating brew
        $BREW update &> /dev/null
    fi
else
    yellow Skipping Homebrew -- not on macOS
fi

# ===============================================================================
# ================================  UPDATE REPO  ================================
# ===============================================================================
update .dotfiles .

# ===============================================================================
# ===================================  ZSH  =====================================
# ===============================================================================
if [[ ! -d $HOME/.oh-my-zsh ]]
then
    yellow Downloading oh-my-zsh
    # --unattended (RUNZSH=no CHSH=no) so the installer doesn't try to exec
    # into a fresh interactive shell or change the login shell -- both of
    # which hang/misbehave when this script isn't run interactively.
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null
    fail_on_error "Failed to install oh-my-zsh"
    green Installed oh-my-zsh
else
    yellow Updating oh-my-zsh
    ZSH="$HOME/.oh-my-zsh" zsh -f "$HOME/.oh-my-zsh/tools/upgrade.sh" -v silent > /dev/null
fi

link "$CURR_DIR/zsh/drolando.zsh-theme" "$HOME/.oh-my-zsh/themes/drolando.zsh-theme"

update_or_clone "zsh-syntax-highlighting" https://github.com/zsh-users/zsh-syntax-highlighting.git "$CURR_DIR/zsh/zsh-syntax-highlighting"

link "$CURR_DIR/zsh/zshrc" "$HOME/.zshrc"

# ===============================================================================
# ================================  HOMEBREW PACKAGES  ==========================
# ===============================================================================
if $IS_MAC
then
    yellow Installing brew packages
    $BREW bundle install --quiet --file="$CURR_DIR/Brewfile" > /dev/null
    fail_on_error "Failed to install brew packages"
    green Installed homebrew packages
else
    yellow Skipping Homebrew packages -- apt packages on this box are provisioned separately
fi

# ===============================================================================
# ================================  DOTFILE SYMLINKS  ===========================
# ===============================================================================
for dot in gitconfig tmux.conf
do
  link "$CURR_DIR/$dot" "$HOME/.$dot"
done

# vimrc and vimrc.plugins live under vim/, but vimrc's own
# `source ~/.vimrc.plugins` line expects that exact target name in $HOME,
# so these still link to ~/.vimrc / ~/.vimrc.plugins, just from that source.
link "$CURR_DIR/vim/vimrc" "$HOME/.vimrc"
link "$CURR_DIR/vim/vimrc.plugins" "$HOME/.vimrc.plugins"

mkdir -p "$HOME/.vim"
mkdir -p "$HOME/.vim/plugged"
mkdir -p "$HOME/.config/nvim/"
link "$CURR_DIR/vim/vimrc" "$HOME/.config/nvim/init.vim"

# ===============================================================================
# =============================  VIM CONFIGURATION  =============================
# ===============================================================================
update_or_clone "vim-plug" https://github.com/junegunn/vim-plug.git "$HOME/.vim/autoload"

which nvim &> /dev/null
if [[ $? -eq 0 ]]
then
    mkdir -p "$HOME/.local/share/nvim/site"
    link "$HOME/.vim/autoload" "$HOME/.local/share/nvim/site/autoload"
fi

# Install solarized
# ------------------
update_or_clone solarized https://github.com/altercation/solarized.git "$CURR_DIR/solarized"

VIM_COLORS="$HOME/.vim/colors/"
NVIM_COLORS="$HOME/.config/nvim/colors/"

mkdir -p "$HOME/.vim/colors/"
cp "$CURR_DIR/solarized/vim-colors-solarized/colors/solarized.vim" $VIM_COLORS
mkdir -p "$HOME/.config/nvim/colors/"
cp "$CURR_DIR/solarized/vim-colors-solarized/colors/solarized.vim" $NVIM_COLORS
if [[ -f $VIM_COLORS/solarized.vim && -f $NVIM_COLORS/solarized.vim ]]
then
    green Successfully installed solarized colors
else
    red Failed to install solarized colors
    exit 1
fi

# Install plugins
# ---------------
# Note: LSP servers (pyright, gopls, etc.) are NOT installed here -- CoC's
# npm-based auto-install was replaced with native Neovim LSP (vim/vimrc.lsp).
# Install the servers you need directly on each box, e.g.
# `pip install pyright` / `go install golang.org/x/tools/gopls@latest`.
for VIM in vim nvim
do
    $VIM +PlugUpgrade +qall
    $VIM +"PlugClean! --sync" +qall
    $VIM +"PlugInstall --sync" +qall
    $VIM +"PlugUpdate --sync" +qall
done

green Vim plugins updated

# Download patched fonts
# ----------------------
update_or_clone fonts https://github.com/powerline/fonts.git "$CURR_DIR/fonts"

# Install patched fonts
cd "$CURR_DIR/fonts" || exit
./install.sh > /dev/null
fail_on_error "Failed to install patched fonts"
green Patched fonts updated
cd "$CURR_DIR" || exit

# vim: shiftwidth=4 smarttab expandtab
