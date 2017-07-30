local ret_status="%(?:%{$fg_bold[green]%}~> :%{$fg_bold[red]%}~> %s)"
NEWLINE=$'\n'
PROMPT='${NEWLINE}%{$fg[red]%}%n%{$fg[blue]%}@%{$fg[green]%}%m %{$fg_bold[blue]%}%c $(git_prompt_info)${NEWLINE}${ret_status}%b % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%b%{$fg[yellow]%}(git "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=") %{$fg[yellow]%}±"
ZSH_THEME_GIT_PROMPT_CLEAN=") %{$fg[green]%}✓"
