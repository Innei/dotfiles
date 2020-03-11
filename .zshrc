# Antigen: https://github.com/zsh-users/antigen
ANTIGEN="$HOME/.local/bin/antigen.zsh"

# Install antigen.zsh if not exist
if [ ! -f "$ANTIGEN" ]; then
  echo "Installing antigen ... please connect the proxy"
  #export all_proxy=socks5://127.0.0.1:1086
  [ ! -d "$HOME/.local" ] && mkdir -p "$HOME/.local" 2> /dev/null
  [ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin" 2> /dev/null
  [ ! -f "$HOME/.z" ] && touch "$HOME/.z"
  URL="http://git.io/antigen"
  TMPFILE="/tmp/antigen.zsh"
  if [ -x "$(which curl)" ]; then
    curl -L "$URL" -o "$TMPFILE"
  elif [ -x "$(which wget)" ]; then
    wget "$URL" -O "$TMPFILE"
  else
    echo "ERROR: please install curl or wget before installation !!"
    exit
  fi
  if [ ! $? -eq 0 ]; then
    echo ""
    echo "ERROR: downloading antigen.zsh ($URL) failed !!"
    exit
  fi;
  echo "move $TMPFILE to $ANTIGEN"
  mv "$TMPFILE" "$ANTIGEN"
fi

# alias begin
alias c='clear'
alias e='exit'
alias pip='pip3'
alias proxy='export all_proxy=socks5://127.0.0.1:1086'
alias pc='proxychains4 zsh'
alias gc='git clone'
alias gm='git commit -a -m'
alias gp='git push'
alias gb='git branch'
alias gpl='git pull'
alias gf='git fetch'
alias gs='git stash'
alias gr='git rebase'
alias gt='git log --graph --oneline --all'

alias t='tldr'
alias mkdir='mkdir -p'
alias mkidr='mkdir -p'
alias dns8='networksetup -setdnsservers Ethernet\ Adaptor\ \(en2\) 8.8.8.8 8.8.4.4'
alias dns='networksetup -setdnsservers "802.11n NIC" empty'
alias dns114='networksetup -setdnsservers "802.11n NIC" 114.114.114.114'
alias dnstx='networksetup -setdnsservers "802.11n NIC" 119.29.29.29'
alias sshproxy="ssh -o 'ProxyCommand=nc -X 5 -x localhost:1086 %h %p'"

alias vf='nvim $(fzf)'
alias cdt='cd $(find * -type d | fzf)'
alias gct='git checkout $(git branch -r | fzf)'

alias cl='cloc . --exclude-dir=node_modules,.nuxt,build,.vscode,dist --exclude-lang=JSON'

alias r='ranger'
alias q='exit'
alias c='clear'
alias ll='ls -l'
# alias python='python3'
# alias end

VISUAL=nvim; export VISUAL EDITOR=nvim; export EDITOR

# fzf
export FZF_DEFAULT_OPTS='--bind ctrl-e:down,ctrl-u:up --preview "[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (ccat --color=always {} || highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500"'
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git --ignore-dir=node_modules -g ""'
export FZF_COMPLETION_TRIGGER='\'
export FZF_TMUX_HEIGHT='80%'
export FZF_PREVIEW_COMMAND='[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (ccat --color=always {} || highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500'


export LSCOLORS=exfxcxdxbxexexxxxxxxxx
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US

# Initialize command prompt
#export PS1="%n@%m:%~%# "

# Enable 256 color to make auto-suggestions look nice
export TERM="xterm-256color"


# Load local bash/zsh compatible settings
_INIT_SH_NOFUN=1
#[ -f "$HOME/.local/etc/init.sh" ] && source "$HOME/.local/etc/init.sh"

# exit for non-interactive shell
#[[ $- != *i* ]] && return

# WSL (aka Bash for Windows) doesn't work well with BG_NICE
#[ -d "/mnt/c" ] && [[ "$(uname -a)" == *Microsoft* ]] && unsetopt BG_NICE

# Initialize antigen
source "$ANTIGEN"


# Initialize oh-my-zsh
antigen use oh-my-zsh

# default bundles
# visit https://github.com/unixorn/awesome-zsh-plugins
antigen bundle pip
antigen bundle svn-fast-info

antigen bundle colorize
antigen bundle github
antigen bundle python
antigen bundle rupa/z z.sh
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle sobolevn/wakatime-zsh-plugin

antigen bundle willghatch/zsh-cdr

antigen theme xxf
#syntax color definition
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

typeset -A ZSH_HIGHLIGHT_STYLES

#ZSH_HIGHLIGHT_STYLES[command]=fg=white,bold
#ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'

ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=009
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=009,standout
ZSH_HIGHLIGHT_STYLES[alias]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[builtin]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[function]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[command]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[commandseparator]=none
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=009
ZSH_HIGHLIGHT_STYLES[path]=fg=214,underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=063
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[assign]=none

# load local config
[ -f "$HOME/.local/etc/config.zsh" ] && source "$HOME/.local/etc/config.zsh"
[ -f "$HOME/.local/etc/local.zsh" ] && source "$HOME/.local/etc/local.zsh"
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
[ -f "$HOME/.config/zsh/zshrc" ] && source "$HOME/.config/zsh/zshrc"

antigen apply


# default keymap
bindkey -s '\ee' 'nvim\n'
bindkey '\eh' backward-char
bindkey '\el' forward-char
bindkey '\ej' down-line-or-history
bindkey '\ek' up-line-or-history
# bindkey '\eu' undo
bindkey '\eH' backward-word
bindkey '\eL' forward-word
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

bindkey -s '\eo' 'cd ..\n'
bindkey -s '\e;' 'll\n'

bindkey '\e[1;3D' backward-word
bindkey '\e[1;3C' forward-word
bindkey '\e[1;3A' beginning-of-line
bindkey '\e[1;3B' end-of-line

# options
unsetopt correct_all

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY # Don't execute immediately upon history expansion.

# less highlight for man page
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# ignore complition
zstyle ':completion:*:complete:-command-:*:*' ignored-patterns '*.pdf|*.exe|*.dll'
zstyle ':completion:*:*sh:*:' tag-order files

setopt nonomatch

# Use beam shape cursor on startup.
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt.
preexec() {
  echo -ne '\e[5 q'
}

_fix_cursor() {
  echo -ne '\e[5 q'
}
precmd_functions+=(_fix_cursor)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:~/go/bin:~/library/Python/3.7/bin:~/.local/bin:$PATH"
export python=python3
