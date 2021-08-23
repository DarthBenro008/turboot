#!/bin/bash

# Setting User Global configs
MODS=("zsh" "tmux" "oh_my_zsh" "node" "yarn" "nvim" "vim_plug" "python") # Global Mod, add your mod here
DEFAULT_MODS=("zsh" "tmux" "oh_my_zsh" "node" "yarn" "nvim" "vim_plug")  # Set of default mods, subset of MODS
CONF_FILE="$HOME/.turbootrc"                                             # Location to find your config file
PACKAGE_MANAGER="apt"                                                    # Default Fallback Package Manager

# Setting Turboot configs
DATE=$(date --iso-8601=seconds)
IS_CONFIG_PRESENT=0
CWD=$(pwd)
ADDITIONAL_MODS=()
FORCE=0

# Setting term colors
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)

# Setting up loggers
e_header() {
    printf "\n${bold}${tan}==========  %s  ==========${reset}\n\n" "$@"
}
e_shameless_plug() {
    printf "➜ $@\n${reset}"
}
e_arrow() {
    printf "  ➜ $@\n"
}
e_success() {
    printf "${green}✔ %s${reset}\n" "$@"
}
e_error() {
    printf "${red}✖ %s${reset}\n" "$@"
}
e_warning() {
    printf "${tan}➜ %s${reset}\n" "$@"
}
e_underline() {
    printf "${underline}${bold}%s${reset}\n" "$@"
}
e_heading() {
    printf "${underline}${bold}${blue}${reset}${blue}%s${reset}\n" "$@"
}

# Utility Functions
prompt_user() {
    e_warning "$@ (y/n)? "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$(while ! head -c 1 | grep -i '[ny]'; do true; done)
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^y"; then
        return 1
    else
        return 0
    fi
}

contains_element() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 1; done
    return 0
}

print_array() {
    for elements in $@; do
        printf "${tan} - $elements${reset}\n"
    done
    printf "\n"
}

detect_config() {
    if [ -f "$CONF_FILE" ]; then
        IS_CONFIG_PRESENT=1
    else
        IS_CONFIG_PRESENT=0
    fi
}

read_config() {
    if [ -f $CONF_FILE ]; then
        . /etc/os-release
    else
        e_error "Cannot find the conf file"
    fi
}

write_config() {
    printf "OS=%s\nPACKAGE_MANAGER=%s\nCREATED_AT=%s" "$OS" "$PACKAGE_MANAGER" "$DATE" >>$CONF_FILE
}

find_package_manager() {
    if echo $@ | grep -iqF ubuntu; then
        PACKAGE_MANAGER="apt"
    elif echo $@ | grep -iqF ubuntu; then
        PACKAGE_MANAGER="dnf"
    elif echo $@ | grep -iqF ubuntu; then
        PACKAGE_MANAGER="pacman"
    else
        e_error "Cannot find your package manager, please enter name: "
    fi
}

find_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    fi
}

add_custom_modules() {
    e_arrow "Enter all the modules you want to install seperated by spaces"
    read custom_mods
    for cmod in $custom_mods; do
        contains_element "$cmod" "${MODS[@]}"
        if [ $? -eq 1 ]; then
            ADDITIONAL_MODS+=("$cmod")
        fi
    done

}

print_all_mods() {
    if [ ${#ADDITIONAL_MODS[@]} -eq 0 ]; then
        e_arrow "No valid custom modules detected"
    else
        printf "${underline}${bold}${blue}Additional modules detected:${reset} \n"
        print_array "${ADDITIONAL_MODS[@]}"
    fi
}

print_config_for_confirmation() {
    e_heading "OS Detection"
    e_arrow "$OS"
    e_heading "Package Manager Detection"
    e_arrow "$PACKAGE_MANAGER"
    e_heading "The following modules are set for default installation"
    print_array "${DEFAULT_MODS[@]}"

}

create_symlinks() {
    # Creating Symlinks
    ln -sf $CWD/.alacritty.yml ~/.alacritty.yml
    ln -sf $CWD/nvim ~/.config/nvim
    ln -sf $CWD/.zshrc ~/.zshrc
    ln -sf $CWD/.p10k ~/.p10k
    e_success "Created symlinks to configs"
}

get_setup() {
    e_arrow "Which OS are you running on?: "
    read os
    OS=$os
    e_arrow "what is the shorthand of your package manager? (eg: apt, dnf, pacman, yay, etc)"
    read pm
    PACKAGE_MANAGER=$pm
}

source_installation_file() {
    source "$PACKAGE_MANAGER".sh 2>/dev/null
    if [ $? -eq 1 ]; then
        e_error "Cannot find installation files for $PACKAGE_MANAGER, generate one using \$(./turboot -g $PACKAGE_MANAGER)"
        exit 1
    fi
}

echo " _              _                 _
| |_ _   _ _ __| |__   ___   ___ | |_
| __| | | | '__| '_ \ / _ \ / _ \| __|
| |_| |_| | |  | |_) | (_) | (_) | |_
 \__|\__,_|_|  |_.__/ \___/ \___/ \__|"

e_header "Highly extensible and configurable dotfiles setup manager"
e_shameless_plug "Authored by: Hemanth Krishna (https://github.com/DarthBenro008)"
while getopts f flag; do
    case "${flag}" in
    f) FORCE=1 ;;
    esac
done
detect_config
if [ $IS_CONFIG_PRESENT -eq 1 ] && [ $FORCE -eq 0 ]; then
    . $CONF_FILE
    e_warning "Turboot config found which was created on: $CREATED_AT"
    printf "\n"
    print_config_for_confirmation
else
    find_os
    find_package_manager $OS
    printf "\n"
    print_config_for_confirmation
    prompt_user "Are these configs correct?"
    if [ $? -eq 1 ]; then
        echo yes
        write_config
    else
        get_setup
        print_config_for_confirmation
        write_config
    fi
    prompt_user "Do you want to symlink configs of this root folder?"
    if [ $? -eq 1 ]; then
        create_symlinks
    else
        e_error "Symlinks not setup"
    fi
fi

# Source installation scripts
source_installation_file

# Installation for custom modules
prompt_user "Do you want to add some custom modules?"
if [ $? -eq 1 ]; then
    add_custom_modules
fi

# Final confirmation of modules and installation
print_all_mods
prompt_user "Do you want to proceed with installation with the above modules?"
if [ $? -eq 1 ]; then
    e_heading "Installing Modules"
    for modules in "${DEFAULT_MODS[@]}"; do
        eval "install_$modules"
    done
    for modules in "${ADDITIONAL_MODS[@]}"; do
        eval "install_$modules"
    done
else
    e_error "Aye, not installing, you better read the script first!"
fi
