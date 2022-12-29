source ~/.zplug/init.zsh

# Load theme
zplug "mafredri/zsh-async", from:github
zplug "jackharrisonsherlock/common", as:theme
#zplug sindresorhus/pure, use:pure.zsh, from:github, as:theme

# Load plugins
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "plugins/git",   from:oh-my-zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

# alias
alias emacs='emacs -nw'
alias ls='ls -la --color=auto'
alias sbt='rlwrap sbt'

# env variables
export PATH=~/.local/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.cargo/bin:$PATH
export PATH=~/go/bin:$PATH

# zash history config
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY

# set bell-style none
set bell-style none
