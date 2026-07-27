
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
