# https://github.com/rhysd/dotfiles
# Download dotfiles binary
# Note change the version if needed
curl -L https://github.com/rhysd/dotfiles/releases/download/v0.2.2/dotfiles_linux_amd64.zip -o dotfiles.zip
unzip dotfiles.zip
rm dotfiles.zip
chmod +x dotfiles
sudo mv dotfiles /usr/local/bin

