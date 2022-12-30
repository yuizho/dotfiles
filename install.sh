#!/usr/bin/env bash
set -ue

function helpmsg() {
    echo "Usage: ${BASH_SOURCE[0]:-$0} [--force | -f] [--help | -h]" 0>&2
}

function main() {
    local ln_option="-si"

    while [ $# -gt 0 ]; do
        case ${1} in
            --force | -f)
                ln_option="-sf"
                ;;
            --help | -h)
                helpmsg
                exit 0
                ;;
            *)
                helpmsg
                exit 1
                ;;
        esac
        shift
    done

    # zsh
    ln $ln_option "$(pwd)/.zshenv" ~
    ln $ln_option "$(pwd)/.zshrc" ~
    ln $ln_option "$(pwd)/.p10k.zsh" ~
    mkdir -p ~/.config/sheldon
    ln $ln_option "$(pwd)/.config/sheldon/plugins.toml" ~/.config/sheldon/

    # emacs
    ln $ln_option "$(pwd)/.emacs.d" ~

    echo "install completed!!"
}

main "$@"
