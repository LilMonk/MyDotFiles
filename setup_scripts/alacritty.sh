# Alacritty PPA
sudo add-apt-repository ppa:aslatter/ppa
sudo apt update

# Install Alacritty
sudo apt install alacritty


#### Manual installation
# Download rust and cargo
sudo curl https://sh.rustup.rs -sSf | sh

# Clone the Alacritty repository
git clone https://github.com/jwilm/alacritty.git

# Change to the Alacritty directory
cd alacritty

# Build Alacritty
cargo build --release

# To confirm, the Alacritty terminal is installed without any error, run:
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
infocmp alacritty

# Copy the Alacritty binary to a directory in your PATH
sudo cp target/release/alacritty /usr/local/bin

# Copy the logos to a directory where your desktop environment will be able to find them
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg

# Copy the Alacritty desktop file to a directory where your desktop environment will be able to find it
sudo desktop-file-install extra/linux/Alacritty.desktop

# Update the desktop database
sudo update-desktop-database

# Install the shell completions
# echo "source $(pwd)/extra/completions/alacritty.bash" >> ~/.bashrc

# Uninstall Alacritty
# sudo rm /usr/local/bin/alacritty
# sudo rm /usr/share/pixmaps/Alacritty.svg
# sudo rm /usr/share/applications/Alacritty.desktop
# sudo update-desktop-database