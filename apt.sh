# Package Manager template for apt

install_zsh() {
    sudo apt-get install zsh
}

install_tmux() {
    sudo apt install tmux
}

install_oh_my_zsh() {
    sh -c "curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
}

install_p10k() {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
}

install_node() {
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

install_yarn() {
    sudo npm install --global yarn
}

install_nvim() {
    sudo apt install neovim
}

install_vim_plug() {
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

install_fzf() {
    sudo apt-get install fzf
}
