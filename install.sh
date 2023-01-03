#!/usr/bin/env bash
set -ue

function helpmsg() {
    echo "Usage: ${BASH_SOURCE[0]:-$0} [--force | -f] [--help | -h]"
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

    local current_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
    local current_abs_dir=$(realpath $current_dir)

    # zsh
    ln $ln_option "${current_abs_dir}/.zshenv" ~/
    ln $ln_option "${current_abs_dir}/.zshrc" ~/
    ln $ln_option "${current_abs_dir}/.p10k.zsh" ~/
    ln $ln_option "${current_abs_dir}/.config/sheldon" ~/.config/

    # emacs
    ln $ln_option "${current_abs_dir}/.emacs.d" ~/

    # pet
    ln $ln_option "${current_abs_dir}/.config/pet" ~/.config/

    echo "install completed!!"
}

main "$@"
