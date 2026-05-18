# -- oh-my-zsh -----------------------------------------------------------------
export ZSH="/home/$USER/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_UNICODE=true

HISTCONTROL=ignoredups:ignorespace
HIST_STAMPS="dd.mm.yyyy"

DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# rebuild completions once per day, use cache otherwise
autoload -Uz compinit
ZCOMP_DUMP="${ZDOTDIR:-$HOME}/.zcompdump"
_zrc_dump_doy() {
  stat --version &>/dev/null \
    && stat -c '%y' "$1" 2>/dev/null | xargs -I{} date -d '{}' +%j 2>/dev/null \
    || stat -f '%Sm' -t '%j' "$1" 2>/dev/null
}
if [[ -f "$ZCOMP_DUMP" ]] && [[ $(_zrc_dump_doy "$ZCOMP_DUMP") == $(date +%j) ]]; then
  compinit -C
else
  compinit
fi
unfunction _zrc_dump_doy

plugins=(
  zshfl
  docker-compose
  z
  extract
  git
  kubectl
  fzf
  history
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=243,underline"
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"


# -- environment ----------------------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export GPG_TTY=$TTY
export DOTFILES_REPO_PATH="~/gitRepos/MyDotFiles"
export CLOUDSDK_PYTHON="$HOME/miniconda3/envs/ckers/bin/python3"
export VCPKG_ROOT="$HOME/.local/share/vcpkg"
export M2_HOME=/usr/local/apache-maven
export NPM_PACKAGES="$HOME/.npm-packages"
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'


# -- path -----------------------------------------------------------------------
export PATH="$HOME/miniconda3/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$NPM_PACKAGES/bin:$PATH"
export PATH="$M2_HOME/bin:$PATH"
export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/opt/nvim/bin"
export MANPATH="/usr/local/man:${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
export M2_HOME=/usr/local/apache-maven/apache-maven-3.8.5
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

# -- fzf ------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules}/*" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"


# -- aliases --------------------------------------------------------------------
# editors
alias vim="nvim" vi="nvim" svi="sudo nvim"
alias ncim='NVIM_APPNAME=nvim-custom nvim'
alias zshconf="nvim ~/.zshrc"

# shell
alias zshsrc="source ~/.zshrc"
alias c="clear"
alias python="python3"
alias copy="xclip -sel clip"
alias tm="tmux"
alias todo="dooit"
alias lc="colorls"
alias rng="ranger-cd"

# build
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n="ninja"

# pacman
alias update="sudo pacman -Syu"
alias rmpkg="sudo pacman -Rsn"
alias cleanch="sudo pacman -Scc"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias cleanup="sudo pacman -Rsn $(pacman -Qtdq)"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias jctl="journalctl -p 3 -xb"

# tools
alias lzd="lazydocker"
alias lzg="lazygit"

# To get info about the git commits in local repo.
alias gitinfo="git log --oneline | fzf --preview 'git show --name-only {1}'"

# To get info about processess.
alias psinfo="ps axo pid,rss,comm --no-headers | fzf --preview 'ps o args {1}; ps mu {1}'"

alias kctx="kubectx"
alias csup="captain ls | fzf | xargs -I {} captain start {}"
alias csd="captain ls | fzf | xargs -I {} captain stop {}"
alias awspf=set_aws_profile

# To get info about apt dependencies.
# alias dependinfo="apt-cache search . | fzf --preview 'apt-cache depends {1}'"


# -- functions ------------------------------------------------------------------
mkcd() { mkdir -p "$@" && cd "$@"; }

ranger-cd() {
  local IFS=$'\t\n'
  local tempfile="$(mktemp -t tmp.XXXXXX)"
  command ranger --cmd="map Q chain shell echo %d > $tempfile; quitall" "$@"
  if [[ -f "$tempfile" && "$(cat -- "$tempfile")" != "$(pwd)" ]]; then
    cd -- "$(cat "$tempfile")" || return
  fi
  command rm -f -- "$tempfile" 2>/dev/null
}

set_aws_profile() {
  local selected
  selected=$(aws configure list-profiles | fzf --prompt="AWS Profile: ") || return
  export AWS_PROFILE="$selected"
  echo "AWS Profile: $AWS_PROFILE"
}


# -- lazy loaders ---------------------------------------------------------------
conda() {
  unfunction conda
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
  conda "$@"
}

activate() {
  unfunction activate 2>/dev/null
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
  conda activate "$@"
}

kubectl() {
  unfunction kubectl
  source "$ZSH_CACHE_DIR/completions/_kubectl"
  kubectl "$@"
}

terraform() {
  unfunction terraform
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/bin/terraform terraform
  terraform "$@"
}


# -- zoxide ---------------------------------------------------------------------
_zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide-init.zsh"
if [[ ! -f "$_zoxide_cache" || "$commands[zoxide]" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh >| "$_zoxide_cache"
fi
source "$_zoxide_cache"
unset _zoxide_cache


# -- jenv ----------------------------------------------------------------------
# Try to find jenv, if it's not on the path
export JENV_ROOT="${JENV_ROOT:=${HOME}/.jenv}"
if ! type jenv > /dev/null && [ -f "${JENV_ROOT}/bin/jenv" ]; then
    export PATH="${JENV_ROOT}/bin:${PATH}"
fi

# # Lazy load jenv
# if type jenv > /dev/null; then
#     export PATH="${JENV_ROOT}/bin:${JENV_ROOT}/shims:${PATH}"
#     function jenv() {
#         unset -f jenv
#         eval "$(command jenv init -)"
#         jenv $@
#     }
# fi

# # lazy loading prevent the JAVA_HOME to be set.
# # we have to load jenv inorder to set JAVA_HOME.

# eval "$(jenv init -)"