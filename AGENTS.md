# AGENTS.md — game-design-portfolio

## 项目

作品集仓库(系统策划方向,2026-08-11 校准)。

- GitHub: `git@github.com:toki247/game-design-portfolio.git`
- 单源真相:`portfolio-plan-2026-08-11.md`(106 行规划)
- 用户偏好:`mavis-memory/user.md`
- Mavis 经验:`mavis-memory/MEMORY.md`

---

## 当前活跃任务:portfolio-overview mini app(2026-09-09 启动)

### 设计

- **pluginId**:`portfolio-overview`
- **数据源**:本地静态 JSON — `portfolio-overview.json`(仓库根,手动维护)
- **内容**:4 个 section 只读 dashboard — 拆解 / demo / 视频 / 链接
- **第一版不做**:自动拉 Notion / GitHub API(避免集成工作量,以后真要再加)

### 启动步骤(切到本 session 继续时)

1. workspace = 仓库根,用 `git rev-parse --show-toplevel` 确认(本机 `D:\portfolio`;另一台机器可能是 `D:\portfolio\game-design-portfolio`)
2. 在 chat 里说"做 portfolio-overview mini app"
3. Mavis 会:读这份 AGENTS.md → `miniapp init` → 写 client → `publish` → 给 URL

### 第一份 JSON 模板(`portfolio-overview.json`)

```json
{
  "sections": {
    "拆解": [
      {"title": "哈迪斯 2 系统视角拆解", "status": "收尾 + 待升级", "link": ""}
    ],
    "demo": [
      {"title": "1v1 boss 战 demo", "status": "重新定位中", "link": ""}
    ],
    "视频": [],
    "链接": [
      {"title": "Notion 作品集主页", "url": ""},
      {"title": "GitHub 仓库", "url": ""}
    ]
  }
}
```

---

## 重要约束(跟 user.md / MEMORY.md 一致)

- ❌ **不主动改作品集内容文件**(GDD / 拆解 / demo 设计文档)。等用户明确"写入"再写。
- ❌ **不编造游戏内具体数据 / 机制 / 帧数**。拆解只给问题清单 + 填空模板。
- ✅ 公司电脑不限制(2026-08-21 调整后,"随性一点")
- ✅ Mavis memory 同步流程见 `mavis-memory/MEMORY.md` 末尾的"Mavis memory 同步流程(2026-09-08)"
- ✅ `.last-sync` 已加入 `.gitignore`,不提交
