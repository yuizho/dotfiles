#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# alias
alias emacs='emacs -nw'
alias ls='ls -la'
alias sbt='rlwrap sbt'

export PATH=~/.local/bin:$PATH
