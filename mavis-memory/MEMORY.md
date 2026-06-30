
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
