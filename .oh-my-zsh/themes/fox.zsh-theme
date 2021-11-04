# fox.zsh-theme

PROMPT='%{%F{13}%}┌[%{%B%F{15}%}%n%{$reset_color%}%{%F{13}%}@%{%B%F{15}%}%M%{$reset_color%}%{%F{13}%}]%{$fg[white]%}-%{%F{13}%}(%{%B%F{15}%}%~%{$reset_color%}%{%F{13}%})$(git_prompt_info)
└> % %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="-[%{$reset_color%}%{%F{15}%}git://%{%B%F{15}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{%F{13}%}]-"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$reset_color%}"
