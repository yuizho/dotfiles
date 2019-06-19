#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# git-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
    source ~/dotfiles/git-completion
fi

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# alias
alias emacs='emacs -nw'
alias ls='ls -la'
alias sbt='rlwrap sbt'

export PATH=~/.local/bin:$PATH
export PATH=~/.npm-global/bin:$PATH

# set bell-style none
set bell-style none

# configurations for powerline
function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
