# Mavis Memory 同步

这个目录用来同步 Mavis 的记忆文件,跨公司/家里电脑。

## 文件说明

- `user.md` — 用户级记忆(用户偏好、工作方式等)
- `MEMORY.md` — Mavis agent 级记忆(技术栈、踩坑、配置等)

## 同步流程

- **早上到公司 / 晚上回家**:开 Mavis,第一句话 `Mavis,pull 一下 memory`
- **改完记忆**:跟 Mavis 说 `Mavis,push 一下 memory`

## 源文件位置(本地)

- `~/.mavis/memory/user.md`
- `~/.mavis/agents/mavis/memory/MEMORY.md`

## ⚠️ 注意

- 只同步 `memory/` 目录,不要整个 `~/.mavis/` 一起同步
- `sessions/` 跟电脑绑定(进程 ID、临时文件)
- 改完记得 push,否则另一台电脑 pull 不到
