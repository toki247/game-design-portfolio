# Mavis Memory 同步

这个目录用来同步 Mavis 的记忆文件,跨公司/家里电脑。

## 文件说明

- `user.md` — 用户级记忆(用户偏好、工作方式等)
- `MEMORY.md` — Mavis agent 级记忆(技术栈、踩坑、配置等)
- `.last-sync` — 最近一次同步时间(本地状态,不提交,已加 `.gitignore`)

## 源文件位置(本地)

- `~/.mavis/memory/user.md`
- `~/.mavis/agents/mavis/memory/MEMORY.md`
- `C:\Users\admin\.minimax\agents\mavis\memory\MEMORY.md` — MiniMax Code activeDataDir 副本(三份 SHA256 始终一致,9-08 验证)

## 同步流程

跟 Mavis 说 `Mavis,pull 一下 memory` 或 `Mavis,push 一下 memory`,Mavis 会执行下面的 PowerShell 命令。

### Pull(早上到公司 / 晚上回家)

```powershell
cd D:\portfolio\game-design-portfolio
git pull origin main
Copy-Item -Path mavis-memory\user.md -Destination C:\Users\admin\.mavis\memory\user.md -Force
Copy-Item -Path mavis-memory\MEMORY.md -Destination C:\Users\admin\.mavis\agents\mavis\memory\MEMORY.md -Force
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
Set-Content -Path mavis-memory\.last-sync -Value $ts -Encoding utf8
```

### Push(改完 user.md / MEMORY.md 后)

```powershell
# 1. 改本地(Mavis memory 工具或直接编辑 home 下的文件)
# 2. cp 到仓库
Copy-Item -Path C:\Users\admin\.mavis\memory\user.md -Destination D:\portfolio\game-design-portfolio\mavis-memory\user.md -Force
Copy-Item -Path C:\Users\admin\.mavis\agents\mavis\memory\MEMORY.md -Destination D:\portfolio\game-design-portfolio\mavis-memory\MEMORY.md -Force
# 3. 更新 .last-sync + commit + push
cd D:\portfolio\game-design-portfolio
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
Set-Content -Path mavis-memory\.last-sync -Value $ts -Encoding utf8
git add mavis-memory/
git commit -m "docs(memory): sync $(Get-Date -Format 'MM-dd HH:mm')"
git push origin main
```

## ⚠️ 注意

- 只同步 `mavis-memory/` 目录,不要整个 `~/.mavis/` 一起同步
- `sessions/` 跟电脑绑定(进程 ID、临时文件)
- 改完记得 push,否则另一台电脑 pull 不到
- `.last-sync` 是仓库内的本地状态文件,不提交(`.gitignore` 已加 `# mavis memory 工具同步标记`)
- 6-30 旧流程(假定 `~/.mavis/memory` 是 sparse-checkout 仓库)已废止 2026-09-08,见 MEMORY.md 同步流程条目
