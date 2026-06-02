# macOS 轻量 Codex CLI Agent VM

这是一个基于 Lima 的轻量、可持续使用的 Linux 虚拟机环境，用于在 macOS 上隔离运行 Codex CLI。

## 设计

- 虚拟机：Lima + Ubuntu 24.04，默认 4 CPU、6 GiB 内存、48 GiB 磁盘。
- 共享目录：macOS 的 `~/Documents/Codex-${CODEX_AGENT_VM_NAME:-codex-agent}` 挂载到 VM 的 `/workspace`，可读写。
- Codex 状态：保存在 VM 内的 `~/.codex`，包括 `auth.json`、`config.toml`、日志和会话。
- 权限默认值：`workspace-write` + `on-request`，适合长期本地开发；自动化入口使用 `codex exec`。
- Linux 沙箱：安装 `bubblewrap`，让 Codex CLI 在 Linux VM 内继续使用自己的 sandbox。

## 前置条件

macOS 主机需要 Homebrew。脚本会在缺少 Lima 时尝试执行：

```bash
brew install lima
```

## 启动

在本目录执行：

```bash
./bin/bootstrap-host.sh
```

默认 VM 名称是 `codex-agent`，因此默认宿主机共享目录是 `~/Documents/Codex-codex-agent`。可以通过环境变量覆盖：

```bash
CODEX_AGENT_VM_NAME=my-agent ./bin/bootstrap-host.sh
```

也可以直接指定宿主机共享目录：

```bash
CODEX_AGENT_HOST_WORKSPACE=~/Documents/Codex-my-agent ./bin/bootstrap-host.sh
```

## 放置项目

推荐把真实项目目录放在宿主机共享目录下，例如：

```bash
~/Documents/Codex-codex-agent/my-repo
```

这样 VM 内可以直接访问：

```bash
cd /workspace/my-repo
codex
```

如果希望在本机保留原来的工作区路径，可以在本机其他位置创建指向共享目录内真实项目的软链接：

```bash
ln -s ~/Documents/Codex-codex-agent/my-repo ~/Workspace/Sandbox/my-repo
```

不要反过来只在共享目录里放一个指向宿主机其他目录的软链接；VM 内会按 Linux 路径解析软链接目标，通常看不到 `/Users/...` 下未挂载的目录。

进入 VM：

```bash
./bin/enter.sh
```

首次登录 Codex：

```bash
codex login --device-auth
```

登录完成后，在 VM 内进入 workspace：

```bash
cd /workspace
codex --sandbox workspace-write --ask-for-approval on-request
```

## 主机侧快速运行

交互式进入 Codex：

```bash
./bin/run-codex.sh
```

非交互执行一个任务：

```bash
./bin/run-codex.sh "summarize this repository and list risky areas"
```

默认工作目录是 VM 内的 `/workspace`。可以覆盖：

```bash
CODEX_AGENT_WORKDIR=/workspace/my-repo ./bin/run-codex.sh
```

## 健康检查

```bash
./bin/doctor.sh
```

这会检查 `codex`、Node、npm、Git、bubblewrap，并运行 `codex doctor --summary --ascii`。

## 更新 Codex CLI

进入 VM 后执行：

```bash
npm install -g @openai/codex@latest
codex doctor --summary --ascii
```

如果当前 Codex CLI 版本支持自更新，也可以尝试：

```bash
codex update
```

## 认证选择

推荐长期交互使用：

```bash
codex login --device-auth
```

推荐一次性自动化使用 API key，并且只暴露给单次命令：

```bash
CODEX_API_KEY=... codex exec --sandbox workspace-write --ask-for-approval never "review this change"
```

不要把 API key 写进 shell 配置、项目文件或 VM 镜像。

## 安全边界

这个方案有两层边界：

1. Lima VM 隔离 macOS 主机环境。
2. Codex CLI 在 VM 内使用 `workspace-write` sandbox，只能写 `/workspace` 和 `/home/ubuntu/work`。

不要把 `~`、`~/.ssh`、`~/.codex` 或敏感目录挂载到 VM。需要访问私有仓库时，优先使用只读 deploy key 或临时凭据。

## 常用维护

停止 VM：

```bash
limactl stop codex-agent
```

启动已存在 VM：

```bash
limactl start codex-agent
```

查看状态：

```bash
limactl list
```

进入 shell：

```bash
limactl shell codex-agent
```

删除 VM 会清除 VM 内的 Codex 登录缓存和会话：

```bash
limactl delete codex-agent
```

删除前确认不再需要 VM 内的 `~/.codex`。
