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
alias warp='warp-cli'
alias nano='nano -l -T 4'
alias less='less -N'

hgrep() {
    history | grep $1
}

# Methods
alias flush_dns='sudo resolvectl flush-caches'
alias pyenv='source ~/.local/env/bin/activate'

# Host
## Home
laptop='root@192.168.1.106'
