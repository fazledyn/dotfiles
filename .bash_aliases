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
alias tmx='tmux'
alias kctl='kubectl'

hgrep() {
    history | grep $1
}

# Methods
alias flush_dns='sudo resolvectl flush-caches'
alias pyenv='source ~/.local/env/bin/activate'

# Hosts
## Azure
webserver='ataf@20.46.232.163'
services='ataf@13.86.113.162'
devserver='ataf@20.98.128.123'
driftwood='ataf@dks.pcb.dev.openrefactory.com'

## Home
laptop='root@192.168.1.106'

## Client
eraserver='era@27.147.147.106'

## BUETCTF
# virtual machines
server='root@68.183.185.177'
