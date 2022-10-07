# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null

# Key bindings
# ------------
[[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]] && source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ -f "/usr/local/opt/fzf/shell/completion.zsh" ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2>/dev/null

# Key bindings
# ------------
[[ -f "/usr/local/opt/fzf/shell/completion.zsh" ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2>/dev/null
