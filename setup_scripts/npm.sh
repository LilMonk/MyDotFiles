curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# The script will add the NodeSource signing key to your system, create an apt repository file, install all necessary packages, and refresh the apt cache.
# If you need another Node.js version, for example, 16.x, change the setup_18.x with setup_16.x

sudo apt install nodejs

# Here is a way to install packages globally for a given user.
# 1. Create a directory for global packages

mkdir "${HOME}/.npm-packages"

# 2. Tell npm where to store globally installed packages

npm config set prefix "${HOME}/.npm-packages"

# 3. Ensure npm will find installed binaries and man pages

# Add the following to your .bashrc/.zshrc:

NPM_PACKAGES="${HOME}/.npm-packages"

export PATH="$PATH:$NPM_PACKAGES/bin"

# # Preserve MANPATH if you already defined it somewhere in your config.
# # Otherwise, fall back to `manpath` so we can inherit from `/etc/manpath`.
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"