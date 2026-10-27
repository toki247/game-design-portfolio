# -*- coding: utf-8 -*-
"""Maid RPG 文档站生成器 —— 零依赖(md -> html 自带转换)。

用法:
    python build.py

输入:同目录上一级的 7 个 .md
输出:./dist/  (index.html + 各文档页 + assets/)

设计文档是"看"的东西,所以首页额外加一个 hero + 五层结构卡片;
每页右侧带 h2/h3 目录(02 系统设计有 1000+ 行,必须有导航)。
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.dirname(HERE)
DIST = os.path.join(HERE, "dist")

DOCS = [
    ("01-GDD", "① GDD", "01-GDD.md", "游戏总体设计",
     "定位 · 核心体验 · 核心玩法 · 核心循环 · 3C",
     "✅ 全部已定稿 · 核心循环 10-27 转正", "ok"),
    ("02-系统设计", "② 系统设计", "02-系统设计.md", "7 套系统 · 13 项策划案",
     "战斗 / 构筑 / 养成 / 改装 / 探索 / 对话 / 线索",
     "✅ 战斗系统完整 · 🔶 构筑框架 · 🔴 其余 5 套骨架", "part"),
    ("03-内容设计", "③ 内容设计", "03-内容设计.md", "模块 / 敌人 / 角色 / 剧情",
     "18 个模块 + 27 构筑验证",
     "✅ 模块 18/18 · 🔴 敌人 / 角色 / 道具空白", "part"),
    ("04-关卡设计", "④ 关卡设计", "04-关卡设计.md", "结构 · 挑战 · 引导 · 难度",
     "3 章节 × 1 地图",
     "🔴 最薄弱的一层,仅章节骨架", "weak"),
    ("05-数值与配置", "⑤ 数值与配置", "05-数值与配置.md", "公式 · 配置入口 · 待定登记",
     "所有数值全走 Godot .tres",
     "🔶 公式已定 · 🔴 14 项数值待填", "part"),
    ("系统规格书", "执行层", "系统规格书.md", "S1-S12 开发拆分",
     "代码怎么拆、先做哪一块",
     "✅ 拆分完成", "exec"),
]

NAV = [("index", "总览")] + [(k, lbl) for k, lbl, _, _, _, _, _ in DOCS]

# ---------------------------------------------------------------- 基础工具
ESC = {"&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;"}


def esc(s):
    return "".join(ESC.get(c, c) for c in s)


def slug(text):
    s = re.sub(r"[`*_~\[\]()#!]", "", text)
    s = re.sub(r"\s+", "-", s.strip())
    return s.lower()[:80] or "sec"


INLINE_CODE = re.compile(r"`([^`]+)`")
BOLD = re.compile(r"\*\*(.+?)\*\*", re.S)
ITAL = re.compile(r"(?<![\w*])\*([^*\n]+)\*(?!\*)")
LINK = re.compile(r"(?<!!)\[([^\]]*)\]\(([^)\s]+)\)")


def _inner(text):
    """只处理 代码 / 粗体 / 斜体,不处理链接(用于链接 label)。"""
    codes = []

    def _code(m):
        codes.append(m.group(1))
        return "\x00C%d\x00" % (len(codes) - 1)

    work = INLINE_CODE.sub(_code, text)
    work = esc(work)
    work = BOLD.sub(r"<strong>\1</strong>", work)
    work = ITAL.sub(r"<em>\1</em>", work)
    for i, c in enumerate(codes):
        work = work.replace("\x00C%d\x00" % i, "<code>%s</code>" % esc(c))
    return work


def inline(text):
    """行内转换。链接先抽取(因为 label 里可能有代码),再处理代码 / 粗体 / 斜体。

    用占位符切分,避免「代码里的 * 打断加粗」和「链接被代码抽取拆散」两个坑。
    """
    links = []

    def _link(m):
        links.append((m.group(2), m.group(1)))
        return "\x00L%d\x00" % (len(links) - 1)

    work = LINK.sub(_link, text)
    work = _inner(work)
    for i, (href, label) in enumerate(links):
        if href.startswith(("http://", "https://")):
            html = '<a href="%s" target="_blank" rel="noopener">%s</a>' % (href, _inner(label))
        elif href.startswith("#"):
            html = '<a href="%s">%s</a>' % (href, _inner(label))
        else:
            target = "index.html" if href == "idea.md" else href.replace(".md", ".html")
            html = '<a href="%s">%s</a>' % (target, _inner(label))
        work = work.replace("\x00L%d\x00" % i, html)
    return work


# ---------------------------------------------------------------- 块级解析
HEAD = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
FENCE = re.compile(r"^```")
HR = re.compile(r"^\s*(-{3,}|\*{3,}|_{3,})\s*$")
LIST = re.compile(r"^(\s*)([-*+]|\d+[.)])\s+(.*)$")
TABLE_SEP = re.compile(r"^\s*\|?[\s:|-]+\|[\s:|-]*$")


def split_row(line):
    line = line.strip()
    if line.startswith("|"):
        line = line[1:]
    if line.endswith("|"):
        line = line[:-1]
    return [c.strip() for c in line.split("|")]


def parse_list(lines, i):
    """解析(可嵌套)列表。栈里每层记 [indent, tag, li_open]。"""
    out = []
    stack = []
    while i < len(lines):
        ln = lines[i]
        if not ln.strip():
            j = i
            while j < len(lines) and not lines[j].strip():
                j += 1
            if j < len(lines) and LIST.match(lines[j]):
                i = j
                continue
            break
        m = LIST.match(ln)
        if not m:
            break
        indent, marker, text = len(m.group(1)), m.group(2), m.group(3)
        tag = "ol" if marker[0].isdigit() else "ul"
        if not stack:
            stack.append([indent, tag, False])
            out.append("<%s>" % tag)
        elif indent > stack[-1][0]:
            stack.append([indent, tag, False])
            out.append("<%s>" % tag)
        else:
            while len(stack) > 1 and stack[-1][0] > indent:
                lvl = stack.pop()
                if lvl[2]:
                    out.append("</li>")
                out.append("</%s>" % lvl[1])
            lvl = stack[-1]
            if lvl[2]:
                out.append("</li>")
                lvl[2] = False
        lvl = stack[-1]
        if not lvl[2]:
            out.append("<li>")
            lvl[2] = True
        out.append(inline(text))
        i += 1
    while stack:
        lvl = stack.pop()
        if lvl[2]:
            out.append("</li>")
        out.append("</%s>" % lvl[1])
    return "".join(out), i


def md_to_html(text):
    lines = text.replace("\r\n", "\n").split("\n")
    out = []
    toc = []
    i = 0
    while i < len(lines):
        ln = lines[i]

        # fenced code
        if FENCE.match(ln):
            lang = ln[3:].strip()
            i += 1
            buf = []
            while i < len(lines) and not FENCE.match(lines[i]):
                buf.append(lines[i])
                i += 1
            i += 1
            out.append('<pre class="code"><code data-lang="%s">%s</code></pre>'
                       % (esc(lang), esc("\n".join(buf))))
            continue

        # heading
        m = HEAD.match(ln)
        if m:
            lvl = len(m.group(1))
            raw = m.group(2)
            aid = slug(raw)
            if lvl <= 3:
                toc.append((lvl, raw, aid))
            out.append('<h%d id="%s">%s</h%d>' % (lvl, aid, inline(raw), lvl))
            i += 1
            continue

        # hr
        if HR.match(ln):
            out.append("<hr>")
            i += 1
            continue

        # table
        if ln.strip().startswith("|") and i + 1 < len(lines) and TABLE_SEP.match(lines[i + 1]):
            head = split_row(lines[i])
            i += 2
            body = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                body.append(split_row(lines[i]))
                i += 1
            h = ["<table><thead><tr>"]
            for c in head:
                h.append("<th>%s</th>" % inline(c))
            h.append("</tr></thead><tbody>")
            for row in body:
                h.append("<tr>")
                for c in row:
                    h.append("<td>%s</td>" % inline(c))
                h.append("</tr>")
            h.append("</tbody></table>")
            out.append("".join(h))
            continue

        # blockquote
        if ln.startswith(">"):
            buf = []
            while i < len(lines) and (lines[i].startswith(">") or not lines[i].strip()):
                if not lines[i].strip():
                    nxt = i + 1
                    while nxt < len(lines) and not lines[nxt].strip():
                        nxt += 1
                    if nxt >= len(lines) or not lines[nxt].startswith(">"):
                        break
                    i = nxt
                    continue
                buf.append(re.sub(r"^\s*>\s?", "", lines[i]))
                i += 1
            body = inline("\n".join(buf)).replace("\n", "<br>")
            out.append("<blockquote>%s</blockquote>" % body)
            continue

        # list
        if LIST.match(ln):
            html, i = parse_list(lines, i)
            out.append(html)
            continue

        # paragraph
        if not ln.strip():
            i += 1
            continue
        buf = []
        while i < len(lines) and lines[i].strip():
            nxt = lines[i]
            if (HEAD.match(nxt) or FENCE.match(nxt) or HR.match(nxt)
                    or LIST.match(nxt) or nxt.startswith(">")
                    or (nxt.strip().startswith("|") and i + 1 < len(lines)
                        and TABLE_SEP.match(lines[i + 1]))):
                break
            buf.append(nxt)
            i += 1
        out.append("<p>%s</p>" % inline("\n".join(buf)))
    return "\n".join(out), toc


# ---------------------------------------------------------------- 页面壳
CSS = """
:root{
  --bg:#0f1115; --bg2:#161a21; --bg3:#1c2129; --line:#2a3038;
  --fg:#e6e9ef; --fg2:#a8b0bd; --fg3:#6f7887;
  --acc:#7aa2f7; --acc2:#9ece6a; --warn:#e0af68; --bad:#f7768e;
  --ok:#7dcfff; --card:#1a1f27;
}
*{box-sizing:border-box}
html{scroll-behavior:smooth}
body{margin:0;background:var(--bg);color:var(--fg);
  font:15px/1.75 -apple-system,"Segoe UI","Microsoft YaHei","PingFang SC","Hiragino Sans GB",sans-serif;
  -webkit-font-smoothing:antialiased}
a{color:var(--acc);text-decoration:none}
a:hover{text-decoration:underline}
code{font-family:"Cascadia Code",Consolas,"JetBrains Mono",monospace;font-size:.88em;
  background:var(--bg3);padding:.12em .38em;border-radius:4px;color:var(--ok)}

/* layout */
.wrap{display:flex;min-height:100vh}
aside{width:268px;flex:0 0 268px;background:var(--bg2);border-right:1px solid var(--line);
  position:sticky;top:0;height:100vh;overflow-y:auto;padding:22px 0 40px}
aside .brand{padding:0 20px 18px;border-bottom:1px solid var(--line);margin-bottom:14px}
aside .brand b{display:block;font-size:16px;letter-spacing:.02em}
aside .brand span{color:var(--fg3);font-size:12px}
aside nav a{display:flex;gap:9px;align-items:baseline;padding:8px 20px;color:var(--fg2);
  border-left:2px solid transparent;font-size:14px}
aside nav a:hover{background:var(--bg3);color:var(--fg);text-decoration:none}
aside nav a.on{background:var(--bg3);color:var(--fg);border-left-color:var(--acc)}
aside nav a i{font-style:normal;color:var(--fg3);font-size:12px;min-width:16px}
aside nav a.on i{color:var(--acc)}
aside .grp{padding:14px 20px 5px;color:var(--fg3);font-size:11px;letter-spacing:.14em}
main{flex:1;min-width:0;padding:40px 48px 100px;max-width:1080px}
.pagehead{border-bottom:1px solid var(--line);padding-bottom:20px;margin-bottom:28px}
.kicker{color:var(--acc);font-size:12px;letter-spacing:.16em;margin-bottom:6px}
.pagehead h1{margin:0 0 8px;font-size:30px;line-height:1.3}
.pagehead p{margin:0;color:var(--fg2)}

/* toc */
.toc{position:fixed;right:26px;top:80px;width:210px;max-height:calc(100vh - 120px);
  overflow-y:auto;border-left:1px solid var(--line);padding-left:16px;font-size:12.5px}
.toc b{color:var(--fg3);font-size:11px;letter-spacing:.14em;display:block;margin-bottom:8px}
.toc a{display:block;color:var(--fg3);padding:3px 0;line-height:1.45}
.toc a:hover{color:var(--acc);text-decoration:none}
.toc a.l2{color:var(--fg2);font-weight:600;margin-top:6px}
.toc a.l3{padding-left:12px}
@media(max-width:1500px){.toc{display:none}}

/* content */
h1,h2,h3,h4,h5,h6{line-height:1.35;scroll-margin-top:20px}
h2{font-size:22px;margin:52px 0 16px;padding-bottom:9px;border-bottom:1px solid var(--line)}
h3{font-size:17px;margin:32px 0 12px;color:#f0f3f8}
h4{font-size:15px;margin:24px 0 10px;color:var(--fg2)}
p{margin:12px 0}
hr{border:0;border-top:1px solid var(--line);margin:34px 0}
blockquote{margin:16px 0;padding:12px 16px;background:var(--bg2);
  border-left:3px solid var(--acc);border-radius:0 6px 6px 0;color:var(--fg2);font-size:14px}
blockquote p{margin:6px 0}
ul,ol{padding-left:24px;margin:12px 0}
li{margin:5px 0}
li>ul,li>ol{margin:4px 0}
pre.code{background:var(--bg2);border:1px solid var(--line);border-radius:8px;
  padding:14px 16px;overflow-x:auto;margin:16px 0}
pre.code code{background:none;padding:0;color:#c8d3e0;font-size:13px;line-height:1.6}
table{border-collapse:collapse;width:100%;margin:16px 0;font-size:13.5px;display:block;overflow-x:auto}
th,td{border:1px solid var(--line);padding:8px 11px;text-align:left;vertical-align:top}
th{background:var(--bg3);color:var(--fg);font-weight:600;white-space:nowrap}
tr:nth-child(even) td{background:rgba(255,255,255,.015)}
td code{white-space:nowrap}

/* hero + cards */
.hero{background:linear-gradient(135deg,#1b2333,#1a1f27 60%);border:1px solid var(--line);
  border-radius:14px;padding:34px 34px 30px;margin-bottom:34px}
.hero h1{margin:0 0 6px;font-size:34px}
.hero .sub{color:var(--fg2);margin:0 0 18px;font-size:15px}
.hero .meta{display:flex;flex-wrap:wrap;gap:8px}
.pill{display:inline-block;padding:4px 11px;border-radius:999px;font-size:12px;
  background:var(--bg3);border:1px solid var(--line);color:var(--fg2)}
.pill.acc{border-color:#33507e;color:var(--acc)}
.cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(232px,1fr));gap:14px;margin:22px 0 8px}
.card{background:var(--card);border:1px solid var(--line);border-radius:11px;padding:16px 17px;
  display:block;color:inherit}
.card:hover{border-color:#3d5578;text-decoration:none;transform:translateY(-2px);
  transition:.15s border-color,.15s transform}
.card .lv{font-size:11.5px;letter-spacing:.1em;color:var(--acc)}
.card b{display:block;font-size:15px;margin:6px 0 5px}
.card span{display:block;color:var(--fg3);font-size:12.5px;line-height:1.6}
.card .st{margin-top:10px;font-size:12px}
.pagehead .st{margin-top:10px;font-size:12.5px}
.st-ok{color:var(--acc2)}.st-part{color:var(--warn)}.st-weak{color:var(--bad)}.st-exec{color:var(--fg3)}
.badge{display:inline-block;padding:2px 8px;border-radius:5px;font-size:11.5px;
  background:var(--bg3);border:1px solid var(--line);color:var(--fg2);margin-right:6px}
footer{margin-top:70px;padding-top:20px;border-top:1px solid var(--line);
  color:var(--fg3);font-size:12.5px}
@media(max-width:900px){aside{display:none}main{padding:26px 20px 70px}.hero{padding:24px}}
"""


def nav_html(active):
    rows = ['<div class="grp">文档</div>']
    for key, label in NAV:
        cls = " on" if key == active else ""
        rows.append('<a class="%s" href="%s.html"><i>%s</i>%s</a>' % (cls.strip(), key, "", label))
    rows.append('<div class="grp">项目</div>')
    rows.append('<a href="https://github.com/toki247/game-design-portfolio"><i>↗</i>GitHub 仓库</a>')
    return "\n".join(rows)


def page(key, title, kicker, desc, body, toc, status="", cls="st-exec"):
    nav = "".join(
        '<a class="%s" href="%s.html"><i>%s</i>%s</a>' % (
            "on" if k == key else "", k, "", lbl)
        for k, lbl in NAV)
    toc_html = ""
    if toc:
        items = "".join(
            '<a class="l%d" href="#%s">%s</a>' % (lvl, aid, raw)
            for lvl, raw, aid in toc if lvl <= 3)
        toc_html = '<div class="toc"><b>本页目录</b>%s</div>' % items
    st_html = ('<div class="st %s">%s</div>' % (cls, esc(status))) if status else ""
    return """<!DOCTYPE html>
<html lang="zh-CN"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>%s · Maid RPG 设计文档</title>
<link rel="stylesheet" href="assets/style.css">
</head><body>
<div class="wrap">
<aside>
  <div class="brand"><b>Maid RPG</b><span>设计文档 · 五层结构</span></div>
  <nav>%s</nav>
</aside>
<main>
  <div class="pagehead">
    <div class="kicker">%s</div>
    <h1>%s</h1>
    <p>%s</p>
    %s
  </div>
  %s
  <footer>Maid RPG 设计文档 · 赛博朋克 / 机械女仆 / 搞笑无厘头 · Godot · 独立开发<br>
  本页由 <code>site/build.py</code> 从仓库内的 Markdown 生成,内容以仓库为准。</footer>
</main>
</div>
%s
</body></html>""" % (esc(title), nav, esc(kicker), esc(title), desc, st_html, body, toc_html)


HERO = """
<div class="hero">
  <h1>Maid RPG 设计文档</h1>
  <p class="sub">回合制 RPG · 赛博朋克机械女仆 · 搞笑无厘头</p>
  <div class="meta">
    <span class="pill acc">27 种构筑</span>
    <span class="pill">3 章节 × 1 地图</span>
    <span class="pill">全流程 1-2 小时</span>
    <span class="pill">Godot · 独立开发</span>
  </div>
</div>
<div class="cards">
%s
</div>
"""


def card(key, kicker, name, desc):
    return ('<a class="card" href="%s.html"><div class="lv">%s</div><b>%s</b>'
            '<span>%s</span></a>'
            % (key, esc(kicker), esc(name), esc(desc)))


def build():
    if not os.path.isdir(DIST):
        os.makedirs(DIST)
    os.makedirs(os.path.join(DIST, "assets"), exist_ok=True)

    with io.open(os.path.join(DIST, "assets", "style.css"), "w", encoding="utf-8", newline="") as f:
        f.write(CSS)

    # 首页
    idx = io.open(os.path.join(SRC, "idea.md"), "r", encoding="utf-8", newline="").read()
    body, toc = md_to_html(idx)
    cards = "".join(
        card(k, lbl, name, desc)
        for k, lbl, _, name, desc, status, cls in DOCS)
    hero = HERO % cards
    # 去掉 idea.md 的 h1(首页 hero 已经承担)
    body = re.sub(r"^\s*<h1[^>]*>.*?</h1>\s*", "", body, count=1, flags=re.S)
    html = page("index", "总览", "项目总览", "文档导航 · 历史步骤映射 · 决议索引 · 下一步",
                hero + body, toc)
    io.open(os.path.join(DIST, "index.html"), "w", encoding="utf-8", newline="").write(html)
    print("index.html")

    # 各文档页
    for key, lbl, fname, name, desc, status, cls in DOCS:
        md = io.open(os.path.join(SRC, fname), "r", encoding="utf-8", newline="").read()
        body, toc = md_to_html(md)
        body = re.sub(r"^\s*<h1[^>]*>.*?</h1>\s*", "", body, count=1, flags=re.S)
        html = page(key, name, lbl, desc, body, toc, status, cls)
        io.open(os.path.join(DIST, key + ".html"), "w", encoding="utf-8", newline="").write(html)
        print("%s.html" % key)

    print("\nDONE ->", DIST)


if __name__ == "__main__":
    build()
