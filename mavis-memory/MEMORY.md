
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

### PowerShell 写文件会把 `$identifier` 吞成空字符串 (2026-07-16)
Type: gotcha

- **症状**:用 PowerShell heredoc (`@"..."@` 或 `@'...'@`) 写 .py / .md / .csv 文件时,文件里所有 `$identifier` 形式的字面量(包括 Python f-string、Markdown `[$link=...]` 语法、CSS 变量、shell 引用等) 都会变成**空字符串**——因为 PowerShell 把 `$X` 当成本地变量求值,变量未定义 → 空。
- **实战陷阱**:
  - Python f-string: `"$variable_name"` 写盘后变成 `"variable_name"` (字面量,无 `$`)
  - Markdown / 配置: `[$link=https://...|label]` 写盘后变成 `[=https://...|label]` (`$link` 没了)
  - Linux 路径: `$HOME` 写盘后变成 `HOME`
- **判断方法**:写完文件后 `grep -n '\['` 看 `[$` 是否还在;或者 PowerShell 里 `Get-Content` 后输出到控制台看。
- **解决方案** (按推荐顺序):
  1. **用 Python 写文件**(`open(path, 'w', encoding='utf-8').write(content)`) — Python 字符串原样写入,无 PowerShell 变量插值
  2. **避免在 PowerShell 字符串里出现 `$`** — 改用单引号 + 避免美元符号
  3. **写完跑 sanity check**:Python 读文件 → 验证关键标记(如 `[$link=`) 存在 → 不存在就 reject 并重新写
- **触发场景**:任何需要用 PowerShell 写"包含 `$X` 字面量"的文件(脚本、模板、配置、CSV 行)都要警惕。简单字符串里 `$` 出现一次都会触发。
### 8 周学习计划(UE 行为树 demo,2026-07-27)
Type: plan

**作品集最终态**:哈迪斯 2 拆解(已交付) + 行为树 demo(8 周目标)
**封印勇者**:挂起,GDD 暂不做;怪物猎人拆解、大型怪物战斗 demo 已清除
**引擎**:UE(已装,公司电脑改装),原计划 Unity 改 UE
**技术栈**:UE 原生 BehaviorTree + Blackboard + 蓝图(BP),不碰 C++,不引第三方 AI 库

**8 周阶段**:
- W1-2:UE 起步(Third Person 模板 + 跑步/跳跃/翻滚控制 + 看 BehaviorTree 文档)
- W3-4:UE 行为树入门(AI Controller + BT + Blackboard,完整循环:巡逻→追击→攻击→受伤/死亡)
- W5-6:demo 雏形(玩家 + 1 只怪物 + 简单场景,翻滚无敌帧 + 怪物碰撞)
- W7-8:完善 + 作品集化(调试 UI + 演示视频 + GitHub + Notion)

**节奏**:每周 15-20h,工作日 1-1.5h × 5 + 周末 5-6h × 2,周末是关键产出时段
**替代关系**:取代 2026-06-30 的 5 阶段学习路径表

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

### demo 设计启动 (2026-07-27 21:19, 最终版)
Type: project
- 哈迪斯 2 拆解已结束收尾,新主线:从 0 设计 1 个 demo 作为求职作品
- **范围**:1v1 boss 战(玩家 3-4 能力 vs Boss 3-4 阶段,30-60s 完整战斗)
- **题材**:人型 boss(理由:完成度优先 / 3C 完整 / AI 同样可展示 / 可扩展)
- **5 步流程**: idea → 范围 → 3C → 机制清单 → 路线图
- **学习三块比例**: 文档 50%+ / 实操按需字典式 / 设计思维用户自主
- **学习内容精简**:只学跟 demo 直接相关(策划案规范 / UE BT / 战斗手感 / 3D 战斗循环)
  - 砍掉:通用设计理论 / 大部头书精读 / 不相关拆解 / 行业评论
- **节奏**: 10-12h/周(工作日 30-60min + 周末 3-4h),配合 user memory 7-27 条目
- **Mavis 角色进一步收紧**: 只给"现在做这步要查的东西",不主动出学习路径
- **W1 聚焦**: 第 1 步"定核心 idea"(填空模板,3 段引导问题)
- 之前 7-27 8 周计划仍是技术参考(UE BT/AI 部分),但范围统一到一个 demo
- 用户偏好"内容太多"——不主动展开 8 周详细计划,只列模块重心
