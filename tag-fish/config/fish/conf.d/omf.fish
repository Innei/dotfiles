
# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Load Oh My Fish configuration.
source $OMF_PATH/init.fish

# alias begin
alias c='clear'
alias e='exit'
alias pip='pip3'
alias proxy='export all_proxy=socks5://127.0.0.1:1080'
alias charles='export http_proxy=http://127.0.0.1:8888;export https_proxy=http://127.0.0.1:8888'
alias hp='export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;'
alias pc='proxychains4 zsh'
alias ga='git status'
alias gc='git clone'
alias gm='git commit -a -m'
alias gp='git push -u origin (git symbolic-ref --short HEAD)'
alias gb='git branch'
alias gpl='git pull'
alias gf='git fetch'
alias gs='git stash'
alias gr='git rebase'
alias gt='git log --graph --oneline --all'
alias gsum='git summary'
alias gco='git checkout'
alias gignore='git update-index --assume-unchanged'
alias gnoignore='git update-index --no-assume-unchanged'
alias gclean='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

alias t='tldr'
alias mkdir='mkdir -p'
alias mkidr='mkdir -p'

alias vf='nvim (fzf)'
alias cdt='cd (find * -type d | fzf)'
alias gct='git checkout (git branch -r | fzf)'

alias cl='cloc . --exclude-dir=node_modules,.nuxt,.next,build,.vscode,dist,release,tmp --exclude-lang=JSON,SVG,XML'

alias r='ranger'
alias q='exit'
alias c='clear'
alias ll='ls -l'

alias tnew='tmux new -s'
alias tkall='tmux kill-session -a'
alias ta='tmux attach-session'
alias yanr='yarn'

alias ss='lsof -Pn -i4 | grep LISTEN'

alias dns8='networksetup -setdnsservers Wi-Fi 8.8.8.8'
alias dns114='networksetup -setdnsservers Wi-Fi 114.114.114.114'
alias dnsali='networksetup -setdnsservers Wi-Fi 223.5.5.5'
alias dns='networksetup -setdnsservers Wi-Fi "Empty"'

alias charge80='sudo bclm write 80'
alias charge60='sudo bclm write 60'
alias charge='sudo bclm write 100'

alias npm='pnpm'
alias npx='pnpx'
alias n='pnpm'
alias nenv='export PATH="$PATH:./node_modules/.bin"'
alias clang++='clang++ --std=c++17'
# alias end




function nvm
  bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

# ~/.config/fish/functions/nvm_find_nvmrc.fish
function nvm_find_nvmrc
  bass source ~/.nvm/nvm.sh --no-use ';' nvm_find_nvmrc
end

# ~/.config/fish/functions/load_nvm.fish
function load_nvm --on-variable="PWD"
  set -l default_node_version (nvm version default)
  set -l node_version (nvm version)
  set -l nvmrc_path (nvm_find_nvmrc)
  if test -n "$nvmrc_path"
    set -l nvmrc_node_version (nvm version (cat $nvmrc_path))
    if test "$nvmrc_node_version" = "N/A"
      nvm install (cat $nvmrc_path)
    else if test nvmrc_node_version != node_version
      nvm use $nvmrc_node_version
    end
  else if test "$node_version" != "$default_node_version"
    echo "Reverting to default Node version"
    nvm use default
  end
end

# ~/.config/fish/config.fish
# You must call it on initialization or listening to directory switching won't work
load_nvm

function fzf --description alias\ fzf\ fzf\ --preview\ \'head\ -100\ \{\}\'\n
	command fzf --preview 'head -100 {}'  $argv;
end