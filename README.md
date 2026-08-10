# AkironZsh

基于 [zimfw](https://github.com/zimfw/zimfw) 框架构建的个人 zsh 使用环境，集成自定义 prompt 主题、Git 增强命令、Nix/NixOS 集成、fzf 生态等丰富功能模块，让终端使用更加高效顺手。

## 功能模块

| 模块             | 说明                                                                                         |
| ---------------- | -------------------------------------------------------------------------------------------- |
| **akzsh**        | 核心模块，配置补全系统、历史记录管理、终端按键绑定、grep 优化、目录跳转、Hook 脚本等基础功能 |
| **asciiship**    | 终端提示符主题模块，支持 `compact`（紧凑）和 `segments`（分段）两种风格，集成 git 状态显示   |
| **extract**      | 文件解压缩模块，支持 `tar.gz`、`zip`、`rar`、`7z`、`deb` 等 20+ 种压缩格式的一键解压         |
| **fzf**          | 基于 fzf 的命令行模糊搜索模块，提供智能补全、文件预览、图片预览、进程管理等功能              |
| **fzf-tab-hook** | fzf-tab 的 Hook 脚本，用于增强 Tab 补全体验                                                  |
| **git**          | Git 增强模块，提供约 80 个常用 git 命令别名（统一 `g` 前缀命名），以及彩色 git log 输出      |
| **nix**          | Nix/NixOS 集成模块，提供 `nixos-rebuild`、`home-manager`、垃圾回收、包搜索等快捷命令         |
| **sudo**         | 快捷 sudo 模块，按 `Esc` 两次自动在命令前添加 `sudo` 前缀                                    |

此外还整合了以下社区插件：

| 插件                                                                            | 说明                   |
| ------------------------------------------------------------------------------- | ---------------------- |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)         | 基于历史的命令自动建议 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令行语法高亮         |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab)                                    | 使用 fzf 增强 Tab 补全 |
| [z.lua](https://github.com/skywind3000/z.lua)                                   | 基于频率的智能目录跳转 |

## 目录结构

```
.
├── init.zsh              # 入口脚本，初始化 zimfw 并加载配置
├── LICENSE
├── modules
│   ├── asciiship         # 提示符主题模块
│   ├── akzsh              # 核心功能模块
│   │   ├── akzsh.zsh          #   模块入口
│   │   ├── aliases.zsh        #   命令别名
│   │   ├── completion.zsh     #   补全系统配置
│   │   ├── dev.zsh            #   个人开发配置
│   │   ├── directories.zsh    #   目录操作别名
│   │   ├── grep.zsh         #   grep 配置
│   │   ├── history.zsh      #   历史记录配置
│   │   ├── hooks.zsh        #   Hook 脚本
│   │   ├── key-bindings.zsh #   按键绑定
│   │   └── theme-appearence.zsh  # 主题外观
│   ├── extract           # 解压缩模块
│   ├── fzf               # fzf 集成模块
│   ├── fzf-tab-hook      # fzf-tab Hook 模块
│   ├── git               # Git 增强模块
│   ├── nix               # Nix 集成模块
│   └── sudo              # sudo 快捷模块
├── README.md
└── zimrc                 # zimfw 模块加载配置
```

## 环境依赖

### 必需依赖

| 依赖     | 说明                                            |
| -------- | ----------------------------------------------- |
| **zsh**  | 默认 Shell，框架运行的基础                      |
| **curl** | 用于下载 zimfw 插件管理器                       |
| **git**  | 版本控制工具，同时也是 zimfw 插件管理的必备条件 |

### 推荐依赖（可选，启用后将获得更好的体验）

| 依赖         | 说明                                       | 用途                                             |
| ------------ | ------------------------------------------ | ------------------------------------------------ |
| **fd**       | 高性能文件查找工具                         | fzf 模块的默认文件搜索后端，替代 `find`          |
| **bat**      | 带语法高亮的文件查看工具                   | `cat` 命令增强，fzf 文件预览                     |
| **eza**      | 现代化的 ls 替代品                         | 文件列表预览，目录树展示                         |
| **fzf**      | 命令行模糊搜索工具                         | Tab 补全增强、历史搜索、文件搜索                 |
| **jq**       | 命令行 JSON 处理工具                       | nix 模块的 `nxsearch` 包搜索格式化               |
| **lua**      | 轻量脚本语言                               | z.lua 目录跳转插件的运行环境                     |
| **lsd**      | 带图标和颜色的 ls 替代品（eza 的替代选择） | 美化目录列表输出（`l`/`ls`/`la` 等别名）         |
| **file**     | 文件类型检测工具                           | fzf 文件预览确定文件类型                         |
| **ueberzug** | 终端图片预览工具                           | fzf 模块的图片预览（可选，仅用于终端内图片预览） |

## 安装使用

### 方式一：NixOS / nix-darwin（推荐）

通过 Home Manager 模块引入，自动管理依赖和配置。

1.  在你的 `flake.nix` 中添加 `akiron-zsh` 作为输入：

    ```nix
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        akiron-zsh.url = "github:pomeluce/akiron-zsh";
      };
    }
    ```

2.  在 Home Manager 配置中导入模块并启用：

    ```nix
    {
      homeManagerModules = [
        akiron-zsh.homeManagerModules.default
      ];
    
      programs.akzsh = {
        enable = true;
    
        # 可选：添加额外依赖包
        extraPackages = with pkgs; [
          lsd
          jq
          nodePackages.pnpm
        ];
    
        # 可选：自定义配置目录
        configDir = ".config/akzsh";
      };
    }
    ```

3.  应用配置：

    ```bash
    home-manager switch --flake .
    ```

#### Nix 可用参数

以下参数可通过 `programs.akzsh` 的选项进行配置，无需手动设置环境变量：

| 参数                 | 类型                          | 默认值                                  | 说明                                                |
| -------------------- | ----------------------------- | --------------------------------------- | --------------------------------------------------- |
| `enable`             | boolean                       | `false`                                 | 启用 AkironZsh                                      |
| `package`            | package                       | `self.packages.${system}.default`       | 指定 akiron-zsh 包                                  |
| `configDir`          | string                        | `".config/akzsh"`                       | 相对于 `$HOME` 的配置目录路径                       |
| `extraPackages`      | list of package               | `[]`                                    | 额外的可选依赖包                                    |
| `grepExcludeFolders` | string                        | `"{.bzr,CVS,.git,.hg,.svn,.idea,.tox}"` | grep 命令要忽略的目录列表                           |
| `zshCacheDir`        | string                        | `"$HOME/.cache/akzsh"`                  | zsh 缓存目录路径                                    |
| `caseSensitive`      | boolean                       | `false`                                 | Tab 补全时是否大小写敏感                            |
| `autoInLastDir`      | boolean                       | `false`                                 | 启动终端时是否自动进入上次退出时的目录              |
| `historyShow`        | boolean                       | `true`                                  | 是否绑定 `Ctrl + R` 快捷键展示搜索历史命令          |
| `promptStyle`        | enum `["compact" "segments"]` | `"compact"`                             | 提示符风格：`compact` 紧凑风格，`segments` 分段风格 |

完整配置示例：

```nix
{
  programs.akzsh = {
    enable = true;
    extraPackages = with pkgs; [
      lsd
      jq
      nodePackages.pnpm
    ];
    grepExcludeFolders = "{.git,.hg,.svn,.idea,.tox,node_modules,target}";
    caseSensitive = false;
    autoInLastDir = true;
    historyShow = true;
    promptStyle = "segments";
  };
}
```

### 方式二：非 NixOS 手动安装

1.  确保默认 Shell 为 zsh：

    ```zsh
    # 查看可用的 zsh 路径
    chsh -l | grep zsh

    # 切换默认 Shell（路径以实际输出为准）
    chsh -s /usr/bin/zsh
    ```

2.  安装环境依赖项（根据你的系统选择对应包管理器）：

    **Arch Linux：**

    ```zsh
    sudo pacman -S fd bat eza fzf jq lua git curl file
    # 可选
    sudo pacman -S lsd ueberzug
    ```

    **Debian / Ubuntu：**

    ```zsh
    sudo apt install -y fd-find bat eza fzf jq lua5.4 git curl file
    # 可选
    sudo apt install -y lsd ueberzug
    ```

    **Fedora：**

    ```zsh
    sudo dnf install -y fd-find bat eza fzf jq lua git curl file
    # 可选
    sudo dnf install -y lsd ueberzug
    ```

    **macOS（Homebrew）：**

    ```zsh
    brew install fd bat eza fzf jq lua git curl file
    # 可选
    brew install lsd
    ```

3.  克隆仓库并加载配置：

    ```zsh
    # 拉取仓库
    git clone https://github.com/pomeluce/akiron-zsh.git ~/.config/akzsh

    # 将加载指令写入 .zshrc
    echo 'source ~/.config/akzsh/init.zsh' >> ~/.zshrc

    # 重新加载终端环境
    source ~/.zshrc
    ```

## 可选配置（非 NixOS 环境变量方式）

如果你通过手动安装方式使用，在 `~/.zshrc` 中 `source init.zsh` **之前**设置以下环境变量即可自定义行为：

```zsh
# 设置 grep 忽略的目录
export EXC_FOLDERS="{.git,.hg,.svn,.idea,.tox,node_modules,target}"

# 设置 zsh 缓存目录
export ZSH_CACHE_DIR="$HOME/.cache/my-zsh"

# 设置 Tab 补全大小写敏感
export CASE_SENSITIVE=true

# 启动终端时自动进入上次目录
export AKIRON_ZSH_IN_LASTDIR=true

# 禁用 Ctrl+R 历史搜索
export AKIRON_ZSH_HISTORY_SHOW=false

# 切换提示符风格为分段式
export AKIRON_ZSH_PROMPT_STYLE=segments

# 最后加载 AkironZsh
source ~/.config/akzsh/init.zsh
```

| 参数                      | 默认值                                | 说明                                         |
| ------------------------- | ------------------------------------- | -------------------------------------------- |
| `EXC_FOLDERS`             | `{.bzr,CVS,.git,.hg,.svn,.idea,.tox}` | 设置 grep 命令要忽略的目录                   |
| `ZSH_CACHE_DIR`           | `$HOME/.cache/akzsh`                  | 设置 zsh 缓存目录                            |
| `CASE_SENSITIVE`          | `false`                               | 设置 Tab 补全时大小写是否敏感                |
| `AKIRON_ZSH_IN_LASTDIR`   | `false`                               | 是否在启动时自动进入上次退出时的目录         |
| `AKIRON_ZSH_HISTORY_SHOW` | `true`                                | 是否绑定 `Ctrl + R` 快捷键展示搜索历史命令   |
| `AKIRON_ZSH_PROMPT_STYLE` | `compact`                             | 设置提示符风格，可选 `compact` 或 `segments` |

## 提示符风格

**紧凑风格（compact）**— 默认，行内纯文本 + 连接词：

```
# 本地 + Git 仓库
 ~/project on  main ↑? 

# SSH 远程 + Git + venv
user at host in  /etc/nixos on  main ↑ via myenv 
```

**分段风格（segments）**— 每模块独立背景色 pill，无连接词：

```
# 本地 + Git 仓库
[  ~/project ] [  main ↑? ] 

# SSH 远程 + Git + venv
[ user ] [  /etc/nixos ] [  main ↑ ] [  myenv ] 
```

通过 `AKIRON_ZSH_PROMPT_STYLE` 环境变量或 Nix 选项 `promptStyle` 切换。

## Git 快捷命令

所有命令统一采用 `g` + 类别首字母的命名约定。简单命令为别名，带参数拼接的为函数。

> **破坏性变更**：早期版本的部分别名已重命名（如 `gc`→`gcl`、`gpu`→`gp`、`gpd`→`gpl`），旧名不再可用。

### 克隆 / 初始化

| 别名              | 说明      |
| ----------------- | --------- |
| `gcl <url> [dir]` | git clone |
| `gin`             | git init  |

### 暂存 / 提交

| 别名           | 说明                                             |
| -------------- | ------------------------------------------------ |
| `ga <path...>` | git add（支持多文件）                            |
| `gaa`          | git add --all（含删除）                          |
| `gm <msg>`     | git commit -m                                    |
| `gam <msg>`    | git add --all && git commit -m（暂存全部并提交） |
| `gca`          | git commit --amend --no-edit（修补上次提交）     |
| `gcam <msg>`   | git commit --amend -m（修补并改写提交信息）      |

### 分支 / 检出 / 切换

| 别名                   | 说明                              |
| ---------------------- | --------------------------------- |
| `gb`                   | git branch                        |
| `gba`                  | git branch --all                  |
| `gbd <branch>`         | git branch -d（删除）             |
| `gbD <branch>`         | git branch -D（强制删除）         |
| `gco`                  | git checkout                      |
| `gcb <branch> [start]` | git checkout -b（新建并检出分支） |
| `gsw`                  | git switch                        |
| `gswc <branch>`        | git switch -c（新建并切换）       |

### 推送 / 拉取 / 获取

| 别名  | 说明                                                                  |
| ----- | --------------------------------------------------------------------- |
| `gp`  | git push（按已配置的上游）                                            |
| `gpf` | git push --force-with-lease（比 --force 更安全）                      |
| `gpt` | git push origin --tags                                                |
| `gpl` | git pull --ff-only                                                    |
| `gf`  | git fetch                                                             |
| `gfa` | git fetch --all --prune                                               |
| `gfr` | git fetch --all && git reset --hard origin/\<branch\>（强制同步远端） |

### 差异 / 状态

| 别名  | 说明                         |
| ----- | ---------------------------- |
| `gd`  | git diff（无 pager）         |
| `gdc` | git diff --cached（已暂存）  |
| `gs`  | git status（无 pager）       |
| `gss` | git status -s                |
| `gsb` | git status -sb（含分支信息） |

### 远端

| 别名               | 说明               |
| ------------------ | ------------------ |
| `grv`              | git remote -v      |
| `gra <name> <url>` | git remote add     |
| `grmv <old> <new>` | git remote rename  |
| `grrm <name>`      | git remote remove  |
| `grs <name> <url>` | git remote set-url |

### 标签

| 别名             | 说明                        |
| ---------------- | --------------------------- |
| `gt <tag> <msg>` | git tag -a -m（带注释标签） |
| `gtl`            | git tag 列表（按日期排序）  |
| `gtd <tag>`      | git tag -d（删除标签）      |

### 日志

| 别名         | 说明                                    |
| ------------ | --------------------------------------- |
| `gll [n]`    | git log 简洁版（默认 10 条，彩色）      |
| `glla [n]`   | git log 详细版（含时间、作者）          |
| `glo [n]`    | git log --oneline --graph（默认 15 条） |
| `glf <file>` | git log --follow（某文件的完整历史）    |

### 查看

| 别名                  | 说明                                         |
| --------------------- | -------------------------------------------- |
| `gsh [commit]`        | git show                                     |
| `gsn [commit]`        | git show --name-only（仅变更文件列表）       |
| `gsd <commit> <file>` | git show（查看指定 commit 中指定文件的变更） |

### 储藏（stash）

| 别名                | 说明            |
| ------------------- | --------------- |
| `gst [-u] [-m msg]` | git stash push  |
| `gsta <stash>`      | git stash apply |
| `gstp <stash>`      | git stash pop   |
| `gstl`              | git stash list  |
| `gstd <stash>`      | git stash drop  |
| `gstc`              | git stash clear |

### 变基 / 合并 / 樱桃挑选

| 别名            | 说明                           |
| --------------- | ------------------------------ |
| `grb`           | git rebase                     |
| `grbi [n]`      | git rebase -i HEAD~n（默认 3） |
| `grbc`          | git rebase --continue          |
| `grbs`          | git rebase --skip              |
| `grba`          | git rebase --abort             |
| `gmrg <branch>` | git merge                      |
| `gmrgc`         | git merge --continue           |
| `gmrga`         | git merge --abort              |
| `gcp <commit>`  | git cherry-pick                |
| `gcpc`          | git cherry-pick --continue     |
| `gcpa`          | git cherry-pick --abort        |

### 重置 / 撤销 / 清理

| 别名            | 说明                                                           |
| --------------- | -------------------------------------------------------------- |
| `grh [ref]`     | git reset --hard（丢弃工作区改动）                             |
| `gundo [n]`     | git reset --soft HEAD~n（撤销最近 n 次提交，保留改动，默认 1） |
| `grev <commit>` | git revert（生成反向提交）                                     |
| `gcln`          | git clean -nd（预览将删除的未跟踪文件）                        |
| `gclnf`         | git clean -fd（强制删除未跟踪文件和目录）                      |

### 冲突处理

| 别名                | 说明                                      |
| ------------------- | ----------------------------------------- |
| `gours <file...>`   | git checkout --ours（冲突中保留本地版本） |
| `gtheirs <file...>` | git checkout --theirs（采用对方版本）     |

### 追溯 / 引用日志 / 二分

| 别名         | 说明             |
| ------------ | ---------------- |
| `gbl <file>` | git blame        |
| `grl`        | git reflog       |
| `gbs`        | git bisect start |
| `gbsg`       | git bisect good  |
| `gbsb`       | git bisect bad   |
| `gbsr`       | git bisect reset |

### 工作树 / 子模块 / 搜索

| 别名                   | 说明                                    |
| ---------------------- | --------------------------------------- |
| `gwt`                  | git worktree                            |
| `gwta <path> <branch>` | git worktree add（添加工作树）          |
| `gwtl`                 | git worktree list                       |
| `gwtr <path>`          | git worktree remove                     |
| `gsm`                  | git submodule                           |
| `gsma <url> [path]`    | git submodule add                       |
| `gsmu`                 | git submodule update --init --recursive |
| `gg <pattern>`         | git grep                                |

## Nix 模块命令（仅 Nix/NixOS 环境可用）

以下命令仅在系统安装 Nix 包管理器后才会加载。

### 系统构建（NixOS 专属）

| 命令       | 说明                                                         |
| ---------- | ------------------------------------------------------------ |
| `nxswitch` | `sudo nixos-rebuild switch --flake .` 应用系统配置           |
| `nxtest`   | `sudo nixos-rebuild test --flake .` 测试系统配置（不持久化） |
| `nxboot`   | `sudo nixos-rebuild boot --flake .` 应用系统配置（重启生效） |

### 包管理与搜索

| 命令                           | 说明                                                      |
| ------------------------------ | --------------------------------------------------------- |
| `nxsearch <name>`              | 在 nixpkgs 中搜索包，显示名称、版本和描述                 |
| `nxrun <pkg> [-- args...]`     | `nix run` 快捷方式，包名自动映射到 nixpkgs，支持传递参数  |
| `nx <pkgs...>`                 | 使用指定包进入 nix shell 临时环境                         |
| `nxhash [--both] [type] <url>` | 获取文件 URL 的 SRI 格式哈希值（用于编写 Nix derivation） |

### Flake 管理

| 命令       | 说明                                |
| ---------- | ----------------------------------- |
| `nxupdate` | `nix flake update` 更新 flake 依赖  |
| `nxshow`   | `nix flake show` 查看 flake 输出    |
| `nxcheck`  | `nix flake check` 检查 flake 正确性 |
| `nxdev`    | `nix develop` 进入开发环境          |

### 垃圾回收

| 命令                     | 说明                                    |
| ------------------------ | --------------------------------------- |
| `nxgc [older_than]`      | Nix 系统垃圾回收，默认清理 7 天前的数据 |
| `nxgc --all` / `nxgc -a` | 清理所有 Nix 历史并执行完整垃圾回收     |

### Home Manager 集成

| 命令                     | 说明                                                        |
| ------------------------ | ----------------------------------------------------------- |
| `hm`                     | `home-manager` 快捷别名                                     |
| `hmswitch`               | `home-manager switch --flake .#$(hostname -s)` 应用用户配置 |
| `hmhistory`              | 查看 home-manager profile 历史                              |
| `hmgc [older_than]`      | 清理 home-manager 旧版本，默认保留 7 天                     |
| `hmgc --all` / `hmgc -a` | 清理所有 home-manager 历史并执行垃圾回收                    |

## 其他常用别名

| 别名/命令                | 说明                                         |
| ------------------------ | -------------------------------------------- |
| `...` / `....` / `.....` | 快捷跳转到上 2/3/4 层目录                    |
| `-` / `1`..`9`           | 快捷跳转到目录栈中的目录                     |
| `md <dir>`               | `mkdir -p` 创建目录（含父目录）              |
| `rd <dir>`               | `rmdir` 删除空目录                           |
| `rrf <path>`             | `rm -rf` 强制删除                            |
| `lnk <src> <dst>`        | `ln -s` 创建软链接                           |
| `rlnk <src> <dst>`       | `ln -snf` 强制更新软链接                     |
| `ds`                     | 按大小排序显示当前目录下各项目占用的磁盘空间 |
| `d [n]`                  | 显示目录栈（默认前 10 条）                   |
| `rp <cmd>`               | 显示命令的完整路径（`realpath`）             |
| `x <file>`               | 解压缩文件（`extract` 的别名）               |
| `Esc+Esc`                | 在当前命令前添加/移除 `sudo`                 |

## License

[GNU General Public License v3.0](LICENSE)
