# Maid RPG 文档站

把 `projects/maid-rpg/` 下的五层设计文档渲染成一个静态站点（深色主题、侧边固定导航 + 右侧章节目录）。

## 零依赖

`build.py` **不依赖任何第三方包**，自带 Markdown 解析器（标题 / 段落 / 表格 / 围栏代码块 / 引用 / 嵌套列表 / 分割线 / 行内代码·粗体·斜体·链接）。

不装 `markdown`、`pip install` 都不用，改完文档直接跑就能重建。

## 重建

```powershell
cd D:\portfolio\game-design-portfolio\projects\maid-rpg\site
C:\Users\admin\AppData\Local\Python\bin\python.exe build.py
```

产物输出到 `site/dist/`：

| 文件 | 来源 |
|---|---|
| `index.html` | `idea.md`（索引页）+ 首页 hero + 五层结构卡片 |
| `01-GDD.html` | `01-GDD.md` |
| `02-系统设计.html` | `02-系统设计.md` |
| `03-内容设计.html` | `03-内容设计.md` |
| `04-关卡设计.html` | `04-关卡设计.md` |
| `05-数值与配置.html` | `05-数值与配置.md` |
| `系统规格书.html` | `系统规格书.md` |
| `assets/style.css` | 内联在 `build.py` 里的主题样式 |

## 改内容后的流程

1. 改 `../idea.md` / `../01-GDD.md` 等源文档（源文档是唯一真相，站点只是渲染产物）
2. 跑一次 `build.py`
3. `git add` 源文档 + `dist/` 产物，一起 commit

## 本地预览

直接用浏览器打开 `site/dist/index.html` 即可（`file://` 协议，无需起服务器）。

## 发布

站点是纯静态产物，`dist/` 目录可直接丢到任意静态托管（GitHub Pages / Vercel / Netlify / 对象存储）。
