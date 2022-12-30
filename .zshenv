# env variables
export PATH=~/.local/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.cargo/bin:$PATH
export PATH=~/go/bin:$PATH

# zesh history config
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
