#!/bin/bash

# import zsh configs
export ZSH="$HOME/.config/oh-my-zsh"
ZSH_THEME="refined"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# import aliases
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# import paths
if [ -f ~/.zsh_path ]; then
    . ~/.zsh_path
fi

# Start Tmux
# If not running interactively, do not do anything
# [[ $- != *i* ]] && return
# [[ -z "$TMUX" ]] && exec tmux

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
