# Innei's Dotfiles

### Usage

Install [rcm](https://github.com/thoughtbot/rcm) first. then run 

```bash
cd
git clone https://github.com/Innei/dotfiles --depth=1 ~/.dotfiles
rcup -t base
```

You also need to install [starship](https://github.com/starship/starship), [zoxide](https://github.com/ajeetdsouza/zoxide) and [thefuck](https://github.com/nvbn/thefuck).

If you encounter problems where symbols cannot be displayed correctly, please install [Nerd Font](https://www.nerdfonts.com/#home) and set it as your terminal / editor(vscode) font.

> Nerd Font includes a series of symbol fonts, such as icons for node, github, linux, etc.
>
> If your terminal(not computer) cannot display the following symbols properly, please install it:
>
>   

After, you will get normal config. (Eg. Tmux, zsh, git ...)

### Set up other config

nvim, ranger config can set up with `-t`

```sh
rcup -t nvim
rcup -t ranger
```

NeoVim docs following this: 

[Readme](./tag-nvim/config/nvim/README.md)
