# env variables
export PATH=~/.local/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.cargo/bin:$PATH
export PATH=~/go/bin:$PATH
case ${OSTYPE} in
    darwin*)
        export PATH=~/Library/Python/$(python3 --version | cut -d ' ' -f 2 | sed -E 's/^(.+)\.(.+)\.(.+)$/\1\.\2/')/bin:$PATH
        export PATH=/opt/homebrew/bin:$PATH
        ;;
esac

# zesh history config
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY

case ${OSTYPE} in
    darwin*)
        export JAVA_HOME="/Users/yui-ito/.sdkman/candidates/java/current"
        ;;
    linux*)
        export JAVA_HOME="/usr/lib/jvm/default"
        ;;
esac
