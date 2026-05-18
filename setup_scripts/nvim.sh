# Install the nvim from the official github page
# https://github.com/neovim/neovim 
# sudo dpkg -i package_file.deb
# sudo add-apt-repository ppa:neovim-ppa/stable
# sudo apt update
# sudo apt install neovim


# Follow the instructions from this.
# https://github.com/neovim/neovim/wiki/Installing-Neovim

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo mv /opt/nvim-linux64 /opt/nvim
sudo ln -s /opt/nvim/bin/nvim /usr/bin/nvim

sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor