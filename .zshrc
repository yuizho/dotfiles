# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# rye config
source "$HOME/.rye/env"

# https://unix.stackexchange.com/questions/339954/zsh-command-not-found-compinstall-compinit-compdef
autoload -Uz compinit && compinit

# load zsh plugins by sheldon
eval "$(sheldon source)"

# a function to register prev command to pet
# https://github.com/knqyf263/pet#zsh-prev-function
function prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}

# alias
alias emacs='emacs -nw'
alias ls='eza --icons --git  -al'
alias sbt='rlwrap sbt'
alias gl='git log --graph --all --format="%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h %C(green) %ar%Creset %C(magenta reverse)%d%Creset %s"'

# set bell-style none
set bell-style none

# confis for each OS
case ${OSTYPE} in
    darwin*)
        # alias
        # jmc
        # https://medium.com/@damian.kolasa/running-jdk-mission-control-on-macos-cb2039700adf
        alias jmc='/Applications/JDK\ Mission\ Control.app/Contents/MacOS/jmc -vm ~/.sdkman/candidates/java/current/lib/jli/libjli.dylib'

        # add keys stored in key-chain to ssh agent
        ssh-add --apple-load-keychain
        # SDKMAN
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        # 1Password Cli
        source $HOME/.config/op/plugins.sh
        ;;
    linux*)
        # alias
        # tmux(byobu)
        alias t2x='tmux save-buffer - | xclip -selection c'
        ;;
esac

# Init mcfly
eval "$(mcfly init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
