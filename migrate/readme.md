# Mac Migration

全自动 Mac 到 Mac 迁移工具。一条命令将旧 Mac 的配置、应用、数据完整迁移到新 Mac。

## 快速开始

### 1. 旧 Mac：传输数据

```bash
cd ~/.dotfiles/migrate
./migrate.sh user@newmac-ip        # 实际传输
./migrate.sh --dry-run user@newmac # 干跑预览
```

### 2. 新 Mac：初始化

```bash
bash ~/migrate/setup.sh           # 执行全部步骤
bash ~/migrate/setup.sh 03 09     # 只执行指定步骤
bash ~/migrate/setup.sh 03-09     # 执行范围
bash ~/migrate/setup.sh --list    # 查看所有步骤
bash ~/migrate/setup.sh --dry-run # 干跑预览
```

## 迁移了什么

| 类别 | 内容 |
|------|------|
| **系统设置** | Dock、Finder、键盘/触控板、Gatekeeper、电源管理、音量、Control Center |
| **开发环境** | Homebrew 包、Node.js (n)、pnpm、全局 npm 包、VS Code 扩展、dotfiles symlinks |
| **应用** | Homebrew casks、App Store (mas)、.pkg 安装包、直接 rsync 的 App |
| **配置 & 数据** | SSH/GPG keys、git config、zsh config、编辑器设置、字体、App 偏好 |
| **App 偏好** | Dock 图标顺序、Finder sidebar/layout、通知权限、Raycast Keychain |

## 步骤一览

| # | 步骤 | 说明 |
|---|------|------|
| 00 | macOS Settings | Dock/Finder/键盘/触控板/Gatekeeper/电源/音量/Control Center |
| 01 | Fix Permissions | 修复 SSH/GPG 目录权限 |
| 02 | Xcode CLI | 安装命令行工具 |
| 03 | Homebrew | 安装 Homebrew |
| 04 | Brewfile | `brew bundle` 恢复所有包 |
| 05 | Dotfile Symlinks | `rcup` 建立 dotfiles 软链接 |
| 06 | Node.js | 安装 n + Node |
| 07 | pnpm | 启用 corepack |
| 08 | Global Packages | 参考 npm/pnpm 全局包列表，手动安装 |
| 09 | Editor Extensions | VS Code 扩展批量安装 |
| 10 | .pkg Apps | GPG Suite / 搜狗输入法 / OpenVPN Connect |
| 11 | Install Apps | mas (App Store) + rsync apps |
| 12 | Dock Restore | 从 `dock-layout.json` 恢复 Dock 图标顺序 |
| 13 | GPG Import | 导入公钥/私钥/ownertrust |
| 14 | Clear Quarantine | 清除迁移 App 的 `com.apple.quarantine` 标记 |
| 15 | Notification Prefs | 恢复通知权限偏好 |
| 16 | Finder State | 恢复 Finder sidebar 和 layout |
| 17 | Re-authenticate | 需要手动重新登录的服务清单 |

## 目录结构

```
migrate/
├── migrate.sh              # 旧 Mac 执行：rsync 传输数据到新 Mac
├── setup.sh                # 新 Mac 执行：编排所有步骤
├── exclude.txt             # rsync 排除列表
├── data/                   # 导出的数据文件
│   ├── Brewfile            # 手工维护的 Homebrew 包列表
│   ├── mas-apps.txt        # App Store 应用 ID 列表
│   ├── rsync-apps.txt      # 需直接 rsync 的 App 列表
│   ├── dock-layout.json    # Dock 图标排列
│   ├── notification-prefs.plist
│   ├── npm-global.txt      # 全局 npm 包参考列表
│   ├── pnpm-global.txt     # 全局 pnpm 包参考列表
│   └── vscode-extensions.txt
├── steps/                  # 各步骤脚本
│   ├── lib.sh              # 共享函数库（颜色、dry-run 拦截等）
│   ├── 00-macos-settings.sh
│   ├── ...
│   └── 16-finder-state.sh
└── references/             # 维护文档
    ├── architecture.md     # 架构设计与数据流
    ├── data-files.md       # 数据文件格式与更新方法
    ├── macos-settings.md   # 系统设置项参考
    ├── app-coverage.md     # 应用安装方式矩阵
    └── troubleshooting.md  # 常见问题排查
```

## 环境变量

| 变量 | 说明 |
|------|------|
| `MIGRATE_SUDO_PASSWORD` | 新 Mac sudo 密码（两边相同时也可用于旧 Mac） |
| `MIGRATE_SOURCE_SUDO_PASSWORD` | 旧 Mac sudo 密码 |
| `MIGRATE_REMOTE_SUDO_PASSWORD` | 新 Mac sudo 密码 |
| `MIGRATE_SKIP_POWER_PREFLIGHT=1` | 跳过 sudo 校验和防休眠设置 |
| `MIGRATE_SKIP_RSYNC_PREFLIGHT=1` | 跳过 rsync 版本检查和自动升级 |

## 维护

- **添加应用**：确定来源（brew/mas/rsync/pkg），更新对应 data 文件
- **添加系统设置**：编辑 `steps/00-macos-settings.sh`
- **添加步骤**：在 `steps/` 创建脚本，更新 `setup.sh` 的 `STEPS` 数组
- **排除文件**：编辑 `exclude.txt`
- **更新数据**：`data/Brewfile` 手工维护；编辑器/npm/pnpm 列表按需重新导出

详细文档见 [references/](references/) 目录。
