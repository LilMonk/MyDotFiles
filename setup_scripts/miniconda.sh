# Download miniconda from : https://docs.conda.io/en/latest/miniconda.html#linux-installers 
# If you'd prefer that conda's base environment not be activated on startup,
# set the auto_activate_base parameter to false: (run this only once)

curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
sha256sum miniconda.sh
chmod +x miniconda.sh
./miniconda.sh
# conda config --set auto_activate_base false

# chmod +x <where miniconda is downloaded>
# ./<miniconda installer script>

# Add this to the ~/.zshrc
# source ~/miniconda3/etc/profile.d/conda.sh
# if [[ -z ${CONDA_PREFIX+x} ]]; then
#     export PATH="~/miniconda3/bin:$PATH"
# fi

# Default config for ~/.bashrc or ~/.zshrc
# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/sentinel/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/sentinel/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/sentinel/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/sentinel/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

# Change download channel to conda-forge
# conda config --add channels conda-forge
# conda config --set channel_priority strict