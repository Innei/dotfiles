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

### Mac Migration

全自动 Mac 到 Mac 迁移工具，一条命令将旧 Mac 的配置、应用、数据完整迁移到新 Mac。

```bash
# 旧 Mac：传输数据
~/.dotfiles/migrate/migrate.sh user@newmac-ip

# 新 Mac：初始化
bash ~/migrate/setup.sh
```

详见 [migrate/readme.md](./migrate/readme.md)。