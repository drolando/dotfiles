local ret_status="%(?:%{$fg_bold[green]%}~> :%{$fg_bold[red]%}~> %s)"
PROMPT='%{$fg_bold[blue]%}%~ $(git_prompt_info)${ret_status}%b % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%b%{$fg[yellow]%}(git "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=") %{$fg[yellow]%}± "
ZSH_THEME_GIT_PROMPT_CLEAN=") %{$fg[green]%}✓ "
