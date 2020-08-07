# Innei's Dotfiles

### Usage

Install rcm first. then run 

```bash
cd
git clone https://github.com/Innei/dotfiles --depth=1 ~/.dotfiles
rcup -t base
```

After, you will get normal config. (Eg. Tmux, zsh, git ...)

### Set up other config

nvim, ranger config can set up with `-t`

```sh
rcup -t nvim
rcup -t ranger
```

NeoVim docs following this: 

[Readme](./tag-nvim/config/nvim/README.md)