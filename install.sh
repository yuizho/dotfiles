#!/usr/bin/env bash
set -ue

function helpmsg() {
    echo "Usage: ${BASH_SOURCE[0]:-$0} [--debug | -d] [--force | -f] [--help | -h] [--install-packages | -i]"
}

function main() {
    local ln_option="-si"
    local needs_installing_packages="false"

    while [ "$#" -gt 0 ]; do
        case ${1} in
            --debug | -d)
                set -uex
                ;;
            --force | -f)
                ln_option="-sfn"
                ;;
            --help | -h)
                helpmsg
                exit 0
                ;;
            --install-packages | -i)
                needs_installing_packages="true"
                ;;
            *)
                helpmsg 1>&2
                exit 1
                ;;
        esac
        shift
    done

    local current_dir=$(dirname "${BASH_SOURCE[0]:-$0}")

    if [ "$needs_installing_packages" = true ]; then
        case ${OSTYPE} in
            darwin*)
                "${current_dir}/.bin/install_packages_for_mac.sh" $current_dir
                ;;
            linux*)
                "${current_dir}/.bin/install_packages_for_linux.sh" $current_dir
                ;;
            *)
                echo "unsupported OS $OSTYPE"
                exit 1
                ;;
        esac
    fi

    echo "=====> create symlinks for config files"

    local current_abs_dir=$(realpath $current_dir)
    if [ ! -e ~/.config ]; then
        mkdir ~/.config
    fi

    # zsh
    ln $ln_option "${current_abs_dir}/.zshenv" ~/
    ln $ln_option "${current_abs_dir}/.zshrc" ~/
    ln $ln_option "${current_abs_dir}/.p10k.zsh" ~/
    ln $ln_option "${current_abs_dir}/.config/sheldon" ~/.config/

    # emacs
    ln $ln_option "${current_abs_dir}/.config/emacs" ~/.config/

    # pet
    ln $ln_option "${current_abs_dir}/.config/pet" ~/.config/

    # kitty
    ln $ln_option "${current_abs_dir}/.config/kitty" ~/.config/

    # ghostty
    ln $ln_option "${current_abs_dir}/.config/ghostty" ~/.config/

    case ${OSTYPE} in
        darwin*)
            "${current_dir}/.bin/extra_configs_for_mac.sh" $current_dir
            ;;
        linux*)
            "${current_dir}/.bin/extra_configs_for_linux.sh" $ln_option $current_dir
            ;;
        *)
            echo "unsupported OS $OSTYPE"
            exit 1
            ;;
    esac

    echo "=====> instllation is complete!!!"
}

main "$@"
