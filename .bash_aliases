# Alias definitions.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# Default
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

alias cls='clear'
alias cmd='gnome-terminal'
alias psa='ps -a'
alias e='exit'

# Others
alias warpon='warp-cli connect'
alias warpoff='warp-cli disconnect'

alias nano='nano -l -T 4'
alias less='less -N'

hgrep(){ history | grep $1 }
fgrep(){ find . | grep $1 }

alias flush_dns='sudo resolvectl flush-caches'
alias upgrade='sudo apt update && sudo apt upgrade'
alias pyenv='source ~/.local/env/bin/activate'
