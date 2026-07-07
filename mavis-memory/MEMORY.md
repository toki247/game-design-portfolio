
### 任务收尾默认清理临时文件 (2026-06-24)

### Windows 沙箱的 Python 环境 (2026-06-24)\nType: config\n- Python 3.12.10 装在 C:\\\\Users\\\\Admin\\\\AppData\\\\Local\\\\Programs\\\\Python\\\\Python312\\\\python.exe\n- 沙箱里 `python` 命令指向 Microsoft Store 的 0 字节 stub,**必须用绝对路径**\n- pip 25.0.1 可用,常用库已装:python-docx / docx2txt / olefile / openpyxl / python-pptx / pymupdf / pdfplumber / lxml / Pillow / requests / beautifulsoup4 / markdown / pyperclip\n- 模板文件:工作区 `_mavis_py_template.py`(带 UTF-8 强制 + Windows 沙箱说明)\n- PowerShell 默认 GBK,Python 脚本开头要 `sys.stdout.reconfigure(encoding='utf-8')` 防中文乱码\n- 从 node 调 python: `execSync('"' + PY + '" "' + scriptPath + '"', { encoding: 'utf8' })`

### Windows PATH 永久修改的正确方法 (2026-06-24)\nType: config\n- **\\\\$env:Path += ... 在 PowerShell 里只对当前会话生效**,新开窗口就丢\n- **setx PATH ...** 会覆盖整个 PATH,而且多次 setx 容易把 PATH 写坏成空或只有最后一段\n- **setx /M** 要管理员权限,普通用户被拒\n- **reg add \\\"HKCU\\\\\\\\Environment\\\" /v Path /t REG_EXPAND_SZ /d \\\"...\\\" /f** 命令行传值时,如果值里含 `)` 或 `,` 会被 PowerShell 错误解析,导致 \"要替换吗?\" 循环询问\n- **正确做法** (Windows 沙箱里):用 **reg import + hex(2) 编码** 的 .reg 文件传值\n  1. 把 PATH 字符串 Buffer.from(s, 'utf16le').toString('hex') 转 hex\n  2. 写成 .reg: `\"Path\"=hex(2):43,00,3a,00,...`\n  3. `reg import tmp.reg` 一行搞定\n- 修复后要 **新开 PowerShell 窗口** 才能看到效果(当前进程的环境不会刷新)\n- 验证:开新 PS 跑 `where python` / `python --version`,要看到真实的 Python 而不是 Microsoft Store 的 0 字节 stub

### Windows 公司电脑读 docx 的可靠方法 (2026-06-30)
Type: config
- Python 3.14.2 装在 C:\Users\admin\AppData\Local\Python\bin\python.exe
- python-docx 1.2.0 + lxml 6.1.1 已装(2026-06-30 验证)
- PowerShell 5.1 的 System.IO.Compression / System.Xml.XmlNamespaceManager / Add-Type 都被权限规则 deny
- 替代方案: Python + python-docx(读 docx 段落/样式/格式)+ tar.exe(Windows 自带,解压 docx 看 raw XML)
- 编码注意: PowerShell 调 Python 时中文路径会破坏(如"反常识勇者" 变 "反常 识勇" 中间多空格),Python 脚本要用 os.listdir 自动找文件,不要硬编码中文路径
- 文档格式验证: python-docx 的 paragraph_format 可读 first_line_indent / space_before / space_after / line_spacing / alignment,跟"原有格式"对齐

### 封印勇者 demo 工作进展(2026-06-30 → 2026-07-01)
Type: project
- 项目位置:`D:\portfolio\封印勇者\`(已加进 .gitignore 同步,代码不上 Git)
- 项目从"反常识勇者"改名"封印勇者"(2026-06-30)
- ACT 系统已删除,改为纯即时战斗
- 核心机制定稿:5 能力(圣剑/盾牌/弓箭/护身符/生命 Max HP 5) + 线性强化链 + Max HP 消耗
- Boss 设计定稿:4 boss(魔法师/骑士/剑士/进阶剑士) + 魔王 + 国王
- 多结局:悲剧(完全封印) vs 救赎(不完全封印 → 国王战)
- 已 commit:`0be0ebd feat(封印勇者): 定版核心机制`
- Godot 项目骨架:已创建 `D:\portfolio\封印勇者\GodotProject\`(加入 .gitignore)
- 待办:Boss 1(魔法师 + 黑雾 + 护身符破解)

### Godot 4 项目手写脚手架经验(2026-07-01)
Type: config
- Godot 4 项目文件可以纯手写,不用 Godot Editor 创建
- 必需文件:
  - `project.godot`(项目配置,UTF-8 文本)
  - `icon.svg`(默认图标,SVG 格式)
  - `scripts/*.gd`(GDScript 脚本)
  - `scenes/*.tscn`(场景文件,文本格式)
- **Sprite2D 没 size 在 scene 里看不见** — 用 `_draw()` 函数 + `queue_redraw()` 代替
- **InputMap 建议运行时配置** — 用 `InputMap.add_action` + `InputEventKey`,避免 `.godot` 文件的复杂配置
- `@tool` 标注的脚本可在编辑器里实时显示可视化(gizmo)
- `@export var config: Resource` 可序列化数据,数据驱动设计
- Godot 4 .tscn 格式:`[gd_scene load_steps=N format=3]` + `[ext_resource]` + `[sub_resource]` + `[node]` + `[node parent="."]`
- 改完文件后用 `git add + commit + push`(项目文件都在 D 盘 git 仓库)

### 封印勇者 demo 视角方案(2026-07-01 锁定)
Type: project
- **45 度俯视**(类哈迪斯),先用"简单旋转"方案:
  - Camera2D 不动
  - Sprite 用 `rotation_degrees = 45` 旋转显示
  - 移动还是 WASD 4 方向
  - 攻击 hitbox 放斜前方
- 备选方案:
  - B. 真等距投影(自定义 shader/transform,工作量 1-2 天)
  - C. 真 2.5D(用 3D mesh 渲染,需要换 3D 项目,排除)

### 封印勇者 demo 架构决策(2026-07-01 锁定)
Type: project
- **关卡编辑器**:三层结构(Demo 阶段不搞自建 EditorPlugin)
  1. 数据:Godot `Resource` 子类 + `@export`
  2. 逻辑:`@tool` 自定义节点 + 可视化 gizmo
  3. 流程:Godot 内置场景编辑器 + TileMap + AnimationPlayer Timeline + Signal
- 保持代码可拓展性,后续经常修改的参数全部走 Resource + @export

### Mavis session workspace → D 盘作品集同步流程(2026-06-30)
Type: config
- Mavis workspace:`C:\Users\Admin\.mavis\sessions\<session_id>\workspace\`
- 作品集(家里 + 公司):`D:\portfolio\`(用户统一改名前是 `D:\作品集\`)
- 同步流程:
  1. Mavis workspace 写新版本(Read / Write / Edit)
  2. `shutil.copy2` 到 `D:\portfolio\对应目录`
  3. `cd D:\portfolio && git add + commit + push`
- 公司电脑接入:`git@github.com:toki247/game-design-portfolio.git`(SSH)
- D 盘 GDD / 骨架文件命名:中文文件名,可以正常工作

### "Mavis,pull 一下 memory" 工作流升级(2026-06-30)
Type: config
3 步流程(用户每次跨设备时运行):
```powershell
# 1. user.md
cd ~/.mavis/memory
git pull origin main
cp mavis-memory/user.md user.md -Force

# 2. MEMORY.md
cd ~/.mavis/agents/mavis/memory
git pull origin main
cp mavis-memory/MEMORY.md MEMORY.md -Force

# 3. 作品集仓库
cd D:\portfolio
git pull origin main
```
- 关键点:本地 memory 不是裸 git 仓库,而是用 sparse-checkout 拉 `mavis-memory/user.md`(子目录)
- 因此 pull 后还要 `cp` 把 `mavis-memory/user.md` 复制到根目录的 `user.md`(Mavis 实际读的路径)

### Python 中文路径处理(2026-06-30 持续)
Type: config
- PowerShell 5.1 默认 GBK,Python 脚本开头加 `sys.stdout.reconfigure(encoding='utf-8')` 防中文乱码
- **PowerShell Get-ChildItem 中文目录会乱码**,用 `os.listdir`(Python)替代
- Python 脚本里**不要硬编码中文路径**,用 `os.listdir` 自动查找
- `python-docx` 处理 docx 时中文段落正常,但路径含中文要小心(可能损坏)
- 已知安全做法:`shutil.copy2(src, dst)` 复制文件用绝对路径,Python 会处理 UTF-8

### 用户偏好补充(2026-07-01)
Type: preference
- **可调参数做成可封装组件**(数据 Resource + 逻辑 @tool 节点 + Godot 编辑器)
- **Demo 阶段不搞自建 EditorPlugin**(等 Demo 完成 + 反复调参后再考虑)
- **代码可拓展性优先于实现速度** — 后续经常修改的部分先抽象再写
- **45 度俯视角游戏** 优先参考 哈迪斯 形式(等距 2.5D 风格)
- 用户愿意接受手写 Godot 项目骨架(不依赖编辑器),关注核心机制先行
### Git 提交频率偏好 (2026-07-01)
Type: preference
- **不要频繁 commit** — 用户明确说"只提交每天工作的最后一版即可"
- 中间过程的修改(查资料、写文档、调参数)都不要 commit
- 一条规则:**今天最后一版提交完后,就不再 commit**,留到明天最后一版
- 在 commit 前先确认:**这是不是今天的最后一版?** 不是的话就先不 commit

### 封印勇者 demo 项目分工 (2026-07-01)
Type: project
- **用户角色**:策划(只负责设计决策、填参数、定机制)
- **Mavis 角色**:程序 + 美术 + 测试(承担实现、视觉、验收)
- 不要建议用户写代码或画图,直接 Mavis 自己来
- 用户输入:需求描述、参数决策、试玩反馈
- Mavis 输出:代码、贴图替代(占位)、测试清单
### pull memory 只读 diff,不读全文 (2026-07-08)
Type: config
- **规则**: pull memory 时不读完整文件全文
  - 适用场景:跨设备会话起步查 memory / 远程 `D:\portfolio\mavis-memory/` 与本地 memory 同步校验 / 公司电脑 ↔ 家里电脑同步
  - 错误做法: `Read` 整个 `user.md` 或 `MEMORY.md` 全文,这是浪费行为
- **正确做法**:
  1. 用 `git diff <file>` 对比 working tree vs HEAD(同步源场景)
  2. 用 `git log -p <file>` 看远端推送历史(跨设备场景)
  3. 用 `grep "<keyword>"` 关键词定向查(回溯某一类规则)
  4. 用 `tail -n` 看最近追加条目,不全读
- **同步源位置**(4 个,必须全部同步):
  - 本机: `~/.mavis/memory/user.md`
  - 本机: `~/.mavis/agents/mavis/memory/MEMORY.md`
  - 远程: `D:\portfolio/mavis-memory/user.md`
  - 远程: `D:\portfolio/mavis-memory/MEMORY.md`
- **目的**: 节省 token + 时间(用户 2026-07-08 02:35AM 提的偏好)
- **用户原话**: "之后 pull memory 的时候,不用读全文,只要看修改过的点就可以了,节省一些 token 和时间,这个规范已经在公司的电脑记录过了"
- **触发**: 用户主动提出该规则后,本会话立即补到本机 agent memory + 推到同步源
