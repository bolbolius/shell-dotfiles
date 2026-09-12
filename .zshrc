# --- Environment ---
typeset -U PATH path
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nano'
export VISUAL='nano'

# --- Zinit ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    print -P "%F{33}Installing %F{220}ZDHARMA-CONTINUUM%F{33} Zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# --- Options ---
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt GLOB_DOTS

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS

# --- Completions ---
autoload -Uz compinit
ZCOMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$ZCOMPDUMP"(#qN.m+1) ]]; then
  compinit
  zcompile "$ZCOMPDUMP" 2>/dev/null
else
  compinit -C
fi

# --- fzf-tab ---
zstyle ':fzf-tab:*' apply-reset-options true
zstyle ':fzf-tab:complete:*' fzf-flags '--height=60%'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 -a --color=always "$realpath"'
zstyle ':fzf-tab:complete:*' fzf-preview '[[ -d $realpath ]] && eza -1 -a --color=always "$realpath" || head -n 100 "$realpath" 2>/dev/null'
zinit light Aloxaf/fzf-tab

# --- Plugins ---
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'header' yes
zstyle ':omz:plugins:eza' 'icons' yes
zinit snippet OMZP::eza

zinit wait lucid for \
    atload"zicdreplay" blockf zsh-users/zsh-completions \
    atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    zdharma-continuum/fast-syntax-highlighting

# --- Shell Integrations ---
(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd cd)"

# --- Navigation & Keybindings ---
autoload -U select-word-style
select-word-style bash

bindkey -e
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Ctrl+Z foreground toggle
fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# --- Aliases ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias l='eza -lh --icons --git'
alias la='eza -lha --icons --git'
alias lt='eza --tree --level=2 --icons'

alias xi='sudo xbps-install -S'
alias xu='sudo xbps-install -Su'
alias xr='sudo xbps-remove -R'
alias xq='xbps-query -Rs'

function code() {
  command code-oss --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations "$@" >/dev/null 2>&1 &!
}
alias code-oss='code'

# --- Banner & Prompt ---
(( $+commands[fastfetch] )) && [[ -o interactive ]] && fastfetch
eval "$(starship init zsh)"
