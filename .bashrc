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
export PATH=~/.npm-global/bin:$PATH

# set bell-style none
set bell-style none

# configurations for powerline
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/lib/python3.7/site-packages/powerline/bindings/bash/powerline.sh
