# shellcheck disable=2148,2034,2155,1091,2086,1094
zmodload zsh/zprof

# ================ #
# Basic ZSH Config #
# ================ #

export ZDOTDIR=$HOME
[[ -n "$ZSH" ]] || export ZSH="${${(%):-%x}:a:h}"
[[ -n "$ZSH_CUSTOM" ]] || ZSH_CUSTOM="$ZSH/custom"
[[ -n "$ZSH_CACHE_DIR" ]] || ZSH_CACHE_DIR="$ZSH/cache"
if [[ ! -w "$ZSH_CACHE_DIR" ]]; then
  ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/antidote"
fi
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Homebrew Dynamic Root Detection (M1/M2/M3/M4 Architecture Support)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Additional PATHs (Cleaned up from Intel paths to dynamic Homebrew paths)
path=(
  ${ASDF_DATA_DIR:-$HOME/.asdf}/shims
  ${HOMEBREW_PREFIX:-/opt/homebrew}/bin
  ${HOMEBREW_PREFIX:-/opt/homebrew}/sbin
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/make/libexec/gnubin
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/curl/bin
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/ruby/bin
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/postgresql@15/bin
  ${KREW_ROOT:-$HOME/.krew}/bin
  $HOME/.bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  $path
)
export PATH
export XDG_CONFIG_HOME=${HOME}/.config
unset ZSH_AUTOSUGGEST_USE_ASYNC

# Set Locale
export LANG=en_US
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ============= #
#   Autoloaders #
# ============= #
# asdf
export ASDF_PYTHON_DEFAULT_PACKAGES_FILE=~/.dotfiles/requirements.txt

# Modern Antidote Loading (Supports both Homebrew and Manual installation)
if [[ -f ${HOMEBREW_PREFIX:-/opt/homebrew}/share/antidote/antidote.zsh ]]; then
  source ${HOMEBREW_PREFIX:-/opt/homebrew}/share/antidote/antidote.zsh
elif [[ -f $HOME/.antidote/antidote.zsh ]]; then
  source $HOME/.antidote/antidote.zsh
fi

# Initialize Antidote if available
if codepath=$(typeset -f antidote); then
  antidote load
fi

# ================ #
#  PS1 and Random  #
# ================ #
export EDITOR='nvim'
export AWS_PAGER=""
export MANPAGER='nvim +Man!'
export cdpath=(. ~ ~/Repos)
# zsh gh copilot configuration
bindkey '^[|' zsh_gh_copilot_explain # bind Alt+shift+\ to explain
bindkey '^[\' zsh_gh_copilot_suggest # bind Alt+\ to suggest

# ===================== #
# Aliases and Functions #
# ===================== #

for ZSH_FILE in "${ZDOTDIR:-$HOME}"/zsh.d/*.zsh(N); do
    source "${ZSH_FILE}"
done
[[ -f $HOME/corp-aliases.sh ]] && source $HOME/corp-aliases.sh

# ================ #
# Kubectl Contexts #
# ================ #
# Load all contexts
export KUBECONFIG=$HOME/.kube/config
export KUBECTL_EXTERNAL_DIFF="kdiff"
export KUBERNETES_EXEC_INFO='{"apiVersion": "client.authentication.k8s.io/v1beta1"}'

# Starship Prompt Initialization
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi
export PATH="$HOME/.local/bin:$PATH"
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'
