# 大型怪物战斗 demo 学习计划 v1.1

> **目标岗位**:战斗策划-怪物方向
> **核心能力目标**:
> 1. 怪物猎人战斗系统 + 怪物招式拆解能力
> 2. 主角战斗系统设计能力(3D,含循环/动作/连招派生/战斗手感)
> 3. 怪物设计能力(1 只完整怪物:招式/状态机/AI/动作)
> **本次调整** (v1.0 → v1.1):
>   - 怪物数:2-3 只 → **1 只**(中等复杂度,推荐大凶豺龙)
>   - 类型:2D → **3D**
>   - 引擎:Godot → **UE**(推荐 UE 5.4 LTS)
>   - 美术:**UE 自带资源 + Mixamo**(简单占位)
> **数据原则**:所有具体招式/帧数/数值由用户填答,Mavis 不主动编造

---

## 一、整体目标拆解

### 1.1 用户已经有的(不需要重做)

| 资产 | 路径 | 状态 |
|---|---|---|
| MH 怪物 AI 拆解参考资料 | `参考资料/怪物猎人/00-MH怪物AI拆解-参考资料合集.md` | 7 篇核心 + 进阶篇 |
| 艾尔登法环拆解方法论 | `参考资料/艾尔登法环战斗系统拆解.md` | 已读,可复用 |
| 哈迪斯 2 拆解(进行中) | `哈迪斯2拆解.docx` | 7 sheet 模板,00/01 已填 |
| 封印勇者 demo | `封印勇者/` | GDD + 设计骨架 + Godot 项目骨架 |
| MH 荒野通关经验 | (已完成) | 通关 |

### 1.2 本次学习要新增的(3 份产出)

| 序号 | 产出物 | 类型 | 引擎 | 优先级 |
|---|---|---|---|---|
| 1 | MH 战斗系统 + 怪物招式拆解文档 | 拆解 | xlsx / md | P0 |
| 2 | 主角战斗系统 demo(3D) | 可演示 demo | UE 5.4 | P0 |
| 3 | 1 只怪物完整设计 + 实现(3D) | 设计文档 + UE 场景 | UE 5.4 | P0 |

**深度决策**:这只怪物**必须完整实现**(招式 + 状态机 + AI + 动作),不能只输出文档——否则 demo 没法演示,简历加分不够。

---

## 二、5 阶段路线(修订版)

### 阶段 1:奠基期 - MH 拆解(M1-M2,8 周)

**目标**:把 MH 的战斗系统和怪物 AI 真正拆透

**主线任务**:

1. **MH 战斗系统拆解**(沿用艾尔登法环方法论,4 步框架)
   - 玩透 + 战斗循环框图
   - 主被动反应频率
   - 操作精度分析
   - 精通维度 / 精通循环
   - 输出载体:xlsx,7-11 sheet(沿用哈迪斯 2 结构)

2. **MH 怪物 AI 拆解**(沿用 `参考资料合集` 的 7 sheet 模板)
   - 拆 1 只代表怪:**大凶豺龙**(推荐,中等复杂度,招式多但状态数适中)
   - 备选:雌火龙(简单,FSM 5 状态)/ 锁刃龙(复杂,12+ 状态)
   - 重点:招式选择算法 + 反应性 + 派生链

**检查点(用户填)**:
- [ ] 选哪只怪拆?默认大凶豺龙
- [ ] MH 战斗系统拆解的载体?xlsx(推荐)/ md
- [ ] 7 sheet 模板是否需要调整?

**产出**:
- `MH战斗系统拆解.xlsx` / `MH战斗系统拆解.md`
- `MH怪物AI拆解-大凶豺龙.md`

---

### 阶段 2:理论储备期 + UE 入门(M3-M4,6 周)

**目标**:攻下 2 大理论难点 + UE 引擎入门

**主线任务**:

1. **战斗手感调优原理**(3 周)
   - 关键概念:输入缓冲/取消窗口/帧冻结/hit stop/镜头震屏/受击位移
   - 阅读清单(优先级排序):
     1. **腾讯 GWB《动作游戏设计入门:火影忍者手游如何实现打击感》(张弛)** ★★★ 起手/攻击/收招 3 段式
     2. **CSDN《游戏打击感设计解析》(机核网 105816 笔记)** ★★★ hit stop / 帧冻结
     3. **网易《全景解构射击游戏枪械设计 - 表现/手感篇》(Minke)** ★★ 21000+字 3C 框架
     4. **腾讯云《3D 动作游戏连招开发》** ★★ 输入缓冲/动态判定/多感官时序
     5. **知乎《我开发的角色动作系统概述 - 战斗,3C 相关》** ★★ 11 种反馈

2. **怪物 AI 设计原理**(1 周)
   - 关键概念:FSM / 分层 FSM(HFSM)/ 行为树(BT)/ 黑板(Blackboard)/ Utility AI
   - 阅读清单:
     1. **jskyzero《怪物猎人中的 AI 出招设计》**(已有)★★★ 拆包视角 FSM
     2. **腾讯云《游戏 AI 行为决策 - 行为树教程(附代码)》** ★★ BT 完整代码
     3. **知乎《游戏开发怪物 AI 实现方案 - 行为树》** ★★ BT 节点图解
     4. **博客园《游戏 AI - 行为树 Part2:框架》** ★★ BT 框架
     5. **UE 官方文档:Behavior Tree 入门** ★★★ UE 专用

3. **UE 5.4 入门**(2 周,见下方 UE 学习子计划)

**决策点(本阶段必须确定)**:
- 主角 AI:**FSM**(用 Animation Blueprint State Machine)
- 怪物 AI:**Behavior Tree**(UE 自带,可视化,工业级)
- 输入处理:**Enhanced Input**(UE 5 推荐)

**检查点(用户填)**:
- [ ] 输入缓冲/hit stop 是否需要 Mavis 写最小 demo 给你玩?
- [ ] 读完后用自己的话写一份"打击感要素清单"(用户填,Mavis 校核)

**产出**:
- 概念笔记 md(用户写)
- UE Demo 项目骨架

---

### 阶段 3:主角战斗系统(M5-M7,10 周)

**目标**:做出一个**可玩的主角战斗原型**

**主线任务**:

1. **主角基础动作系统**(3 周)
   - 主角角色:**UE Mannequin**(自带)+ Mixamo 动画
   - 移动:CharacterMovementComponent + Enhanced Input
   - 基础动作:Idle/Walk/Run/Jump
   - 战斗动作:轻击/重击/闪避(无敌帧)/防御
   - **FSM 实现**:Animation Blueprint State Machine
     - 状态:Idle / Locomotion / LightAttack1-3 / HeavyAttack / Dodge / Hit / Death
   - **输入缓冲**:Enhanced Input + 队列(0.2-0.3s 容错)

2. **连招派生系统**(3 周)
   - **派生规则**(用户填):
     - 轻击 1 → 轻击 2(取消窗口:后摇前 1/3 不可,后 2/3 可)
     - 轻击 N → 重击(取消窗口:轻击 3 后摇期间)
     - 任何攻击 → 闪避(任何时候可,保证操作灵活)
   - **输入优先级**:闪避 > 防御 > 攻击
   - 派生表 + FSM 状态转移图

3. **战斗反馈系统**(2 周)
   - **视觉**:Camera Shake / Hit Stop(暂停动画 N 帧)/ 受击位移 / 粒子(Niagara)
   - **听觉**:打击音效(按材质区分:金属/肉体/木质)
   - **触觉**:手柄震动(轻击/重击/必杀 3 档,Enhanced Input + Force Feedback)
   - **逻辑**:敌人受击进入 Hit FSM

4. **战斗循环**(2 周)
   - 探索区域 → 遇敌触发 → 战斗 → 敌人死亡 → 资源掉落
   - HP/耐力 UI + 战斗开始/胜利/失败 流程

**UE 特定实现要点**:
- **GAS(Gameplay Ability System)** 是 UE 战斗系统的官方推荐方案
  - 优点:技能系统标准化,网络同步友好,属性管理强
  - 缺点:学习曲线陡(2-3 周入门)
  - **决策**:Demo 阶段用**自建 C++ 组件**,GAS 留到下个项目
- **动画驱动**:Anim Notify(动画事件)触发 hitbox/音效/特效,而不是在 Tick 里检测

**检查点(用户填)**:
- [ ] 主角连招几段?推荐 3-5 段
- [ ] 主角武器类型?推荐剑 + 弓(对应近战 + 远程,展示多样性)
- [ ] 战斗反馈必选清单?哪些可省?
- [ ] 是否用 GAS?默认不用

**产出**:
- `主角-招式表.md`
- `主角-状态机图.png`
- `主角-战斗反馈时序表.md`
- UE 项目:`主角战斗原型.uproject`

---

### 阶段 4:1 只怪物完整设计 + 实现(M8-M10,8 周)

**目标**:**1 只怪物的完整实现**(招式 + 状态机 + AI + 动作 + UE 场景)

**怪物选型**(用户确认,默认大凶豺龙):

| 选项 | 招式数 | 状态数 | AI 复杂度 | 工作量 | 简历加分 |
|---|---|---|---|---|---|
| 雌火龙 | 3-4 | 5 | 纯随机 | 4 周 | ★★ |
| **大凶豺龙**(推荐) | 6-8 | 8 | 距离+HP 条件 | 8 周 | ★★★ |
| 锁刃龙 | 10+ | 12+ | 多阶段+派生 | 14 周+ | ★★★(但做不完) |

**主线任务**:

1. **怪物招式设计**(2 周)
   - 输出:招式设计表(招式名/前摇/判定/后摇/应对)
   - 模板(用户填具体值):
     ```
     招式名:右键横扫
     前摇信号:右爪上抬,蓄力 X 秒
     判定时机:爪子挥到身前 X 米
     判定范围:扇形,半径 X 米
     后摇时长:X 帧
     受击反馈:击退 X 米 / 倒地 X 秒
     玩家应对:翻滚(无敌帧)/ 举盾 / 跑位
     ```
   - 招式数:6-8 招(覆盖近/中/远距离 + 单体/群体)

2. **怪物状态机设计**(1 周)
   - 8 状态:待机 / 战斗 / 攻击中 / 受击 / 硬直 / 疲劳 / 狂暴 / 死亡
   - FSM 图(md/图片)
   - 转移条件表

3. **怪物 AI 设计**(2 周)
   - **UE Behavior Tree + Blackboard 实现**
   - 决策表(每只怪一份):
     ```
     当前状态:战斗
     距离玩家:近(<3m) / 中(3-8m) / 远(>8m)
     选招池:
       近距离:啃咬(0.5) / 右爪横扫(0.3) / 头槌(0.2)
       中距离:右爪横扫(0.4) / 尾巴扫(0.4) / 冲撞(0.2)
       远距离:冲撞(0.6) / 跳跃扑击(0.4)
     避免重复:最近 2 招不重复
     ```
   - 高级特性:
     - **疲劳机制**:持续战斗 X 秒后,出招变慢 + 露出破绽(玩家攻击窗口)
     - **狂暴机制**:HP < 30% 时进入狂暴(出招频率↑,招式变化)
     - **威胁等级**:玩家攻击时,怪物可能反击/防御/闪避

4. **怪物 UE 实现**(3 周)
   - 怪物模型:UE Mannequin 改色 + Cube 拼造型(占位) / Mixamo 怪兽
   - 怪物动画:Animation Blueprint State Machine
   - 怪物 AI:Behavior Tree + Blackboard + AI Controller + Pawn Sensing
   - 怪物碰撞:Capsule + Hitbox(基于骨骼)
   - 怪物血量/死亡:Attribute Component + Death Animation

**检查点(用户填)**:
- [ ] 怪物选型?默认大凶豺龙
- [ ] 怪物名字?沿用 MH 还是自创?(推荐沿用,降低沟通成本)
- [ ] 招式设计表的默认值,要 Mavis 提供经验值吗?
- [ ] 行为树选招权重,要 Mavis 提供经验值吗?
- [ ] 怪物占位美术:Mannequin 改色 / Mixamo 怪兽?

**产出**:
- `怪物-招式表.md`
- `怪物-状态机图.png` / `怪物-状态机.md`
- `怪物-AI决策表.md` + Behavior Tree 截图
- UE 项目:含怪物 AI

---

### 阶段 5:整合打磨 + 作品集发布(M11-M12,6 周)

**目标**:**可演示 demo + 作品集包装**

**主线任务**:

1. **战斗场景整合**(2 周)
   - 主角 + 怪物同场战斗
   - 第三人称摄像机(UE SpringArm)
   - 战斗 UI(HP/招式 CD/怪物血条)
   - 战斗开始/胜利/失败 流程
   - 简单的对战场景(UE Starter Content:地面 + 几棵树 + 几块石头)

2. **战斗手感调优**(2 周)
   - **帧数据驱动表**:`动作_帧数据.md`(招式/前摇/判定/后摇/取消窗口)
   - **多感官反馈时序校准**:命中后 0ms 震屏 / 5ms 音效 / 10ms 冻结 / 15ms 受击位移
   - **玩家测试**:3 个玩家各玩 5 局,记录"哪里别扭"
   - **难度调优**:战斗时长目标 2-3 分钟

3. **作品集包装**(2 周)
   - Notion 页面 + README
   - 录屏视频(3-5 分钟,OBS / Windows 自带录屏)
   - GDD 设计文档(参考封印勇者 GDD 风格)
   - GitHub 仓库更新(`.uproject` 加 `.gitignore`,只同步文档 + 截图)

**检查点(用户填)**:
- [ ] demo 演示时长目标?推荐 3 分钟内
- [ ] 是否需要 BGM?推荐先静音
- [ ] 录屏工具?OBS(推荐)/ Windows Game Bar
- [ ] Notion 页面模板是否要新建?

**产出**:
- 可演示的 UE 项目(`.uproject` 打包 + `.exe` 导出)
- `README.md` + `战斗体验设计.md`
- 录屏视频(mp4)
- Notion 页面

---

## 三、UE 5.4 学习子计划(阶段 2 的一部分)

**总时长**:2 周(每日 2-3 小时)

### 3.1 学习路线

| 周次 | 内容 | 推荐资源 | 实践 |
|---|---|---|---|
| **W1 D1-2** | UE 编辑器基础 | B 站搜"UE5 编辑器入门" / 官方 Quick Start | 新建关卡,放 Cube,移动,旋转,缩放 |
| **W1 D3-4** | Actor 与 Component | 官方文档 Actors / Components | 给 Cube 加灯光 Component |
| **W1 D5-7** | Character + Movement | UE Lyra 模板(免费)/ 官方 Third Person 模板 | 让 Mannequin 走路 + 跳跃 |
| **W2 D1-3** | Enhanced Input | 官方 Enhanced Input 文档 / B 站"UE5 Enhanced Input" | WASD + 空格 + 鼠标视角 |
| **W2 D4-6** | Animation Blueprint | 官方 Animation Blueprint 文档 / B 站"UE5 Anim BP" | 做一个 Idle/Walk/Run 状态切换 |
| **W2 D7** | Behavior Tree 入门 | 官方 Behavior Tree Quick Start | 让 NPC 追击玩家 |

### 3.2 必装资源

| 资源 | 用途 | 来源 |
|---|---|---|
| **UE 5.4 LTS** | 引擎本体 | https://www.unrealengine.com/(Epic 账号) |
| **Visual Studio 2022 Community** | C++ 编译环境 | https://visualstudio.microsoft.com/ |
| **Visual Studio Code**(可选) | 轻量编辑器 | 已有 |
| **Rider for Unreal**(可选) | 更好的 C++ IDE | https://www.jetbrains.com/rider/ |
| **Mixamo** | 免费角色动画 | https://www.mixamo.com/(Adobe 账号) |
| **Quixel Bridge** | 免费 3D 资产(在 UE 内置) | UE 自带 |
| **Git LFS** | 大文件版本控制 | https://git-lfs.github.com/ |

### 3.3 不要装的(避坑)

- ❌ **不要用 UE 5.0/5.1/5.2**(老版本,Bug 多)
- ❌ **不要用 UE 5.5+ 预览版**(不稳定)
- ⚠️ **UE 5.3** 也可以,但 5.4 LTS 更稳
- ❌ **不要装 Unreal Engine 4**(完全不同的 API)

---

## 四、环境准备清单(家里电脑)

### 4.1 硬件检查

| 项 | 最低配置 | 推荐配置 |
|---|---|---|
| 操作系统 | Windows 10 64-bit | Windows 11 64-bit |
| CPU | Intel i5-9400 / AMD Ryzen 5 3600 | Intel i7-12700 / AMD Ryzen 7 5800X |
| 内存 | 16 GB | 32 GB |
| 显卡 | NVIDIA GTX 1060 6GB | NVIDIA RTX 3060 12GB |
| 硬盘 | SSD 100 GB | SSD 250 GB |

**UE 编译 + 编辑 + 3D 渲染比 Godot 吃资源得多**,内存 16 GB 勉强,32 GB 舒服。

### 4.2 安装步骤

```
1. 注册 Epic Games 账号 (https://www.unrealengine.com/)
2. 下载 Epic Games Launcher
3. 安装 UE 5.4 LTS(选 Windows,约 30 GB,推荐装 D:\UE_5.4\)
4. 安装 Visual Studio 2022 Community
   - 工作负载选 "使用 C++ 的游戏开发"
   - 组件勾选:MSVC v143 / Windows 11 SDK / .NET 桌面开发
5. 安装 Git LFS (git lfs install)
6. (可选)安装 Mixamo 账号 + 下载 UE 角色
```

### 4.3 D 盘目录规划

```
D:\
├── UE_5.4\                       # UE 安装路径(避免 C 盘)
├── portfolio\
│   ├── 大型怪物战斗\
│   │   ├── 大型怪物战斗-demo-学习计划.md   # 本文档
│   │   ├── 设计文档\
│   │   │   ├── 主角-招式表.md
│   │   │   ├── 怪物-招式表.md
│   │   │   ├── 怪物-状态机.md
│   │   │   └── 怪物-AI决策表.md
│   │   ├── 拆解文档\
│   │   │   ├── MH战斗系统拆解.xlsx
│   │   │   └── MH怪物AI拆解-大凶豺龙.md
│   │   └── 参考资料\
│   │       └── (放 UE / BT / 战斗手感 参考资料)
│   └── GodotProject_UE5\        # UE 项目代码(.gitignore)
│       ├── Source\
│       ├── Content\
│       ├── Config\
│       └── *.uproject
```

---

## 五、6 个核心难点 + 攻克方案(UE 特定)

### 难点 1:状态机的"状态爆炸"

**症状**:主角攻击 3 段 + 闪避 + 受击 + 死亡 = 5 状态,组合爆炸
**根因**:所有状态堆在一个 FSM 里

**攻克**:
1. **主角用分层 FSM**(UE Animation Blueprint 内置):
   - 顶层 State Machine:战斗 / 非战斗
   - 战斗状态 Machine:攻击 / 受击 / 防御 / 闪避
   - 攻击状态 Machine:LightAttack1-3 / HeavyAttack / Special
2. **怪物用 BT + 状态变量**:
   - 状态作为 Blackboard Key,BT 节点根据状态选分支
   - 招式作为 BT Action(每个 Action 一个招式)
3. **铁律**:每只怪 ≤ 10 个状态,主角 ≤ 12 个状态;超出先简化

**UE 实现**:
- 主角:Animation Blueprint + State Machine(嵌套)
- 怪物:Behavior Tree(决策)+ Anim BP State Machine(动画状态)

---

### 难点 2:怪物 AI 的"聪明感"

**症状**:怪物出招完全随机 = "傻";出招太固定 = "蠢"
**根因**:AI 没对玩家行为做反应 + 没短期记忆

**攻克**:
1. **反应性**(BT Decorator 实现):
   - 玩家距离 → 选近/中/远距离招式池
   - 玩家位置 → 选背后/正面招式
   - 玩家正在攻击 → 高概率反击
2. **短期记忆**(Blackboard Key "LastUsedAttack" + Service 节点):
   - 记录最近 2 招
   - BT Decorator 排除最近用过的招
3. **招式派生**(BT Sequence):
   - 出招 A 后 X 秒内高概率接 B
   - BT 节点根据"上次攻击"选派生
4. **威胁等级**(Service 节点定期检测):
   - 玩家攻击时,怪物 50% 反击 / 30% 防御 / 20% 闪避
5. **疲劳 + 狂暴**:
   - BT Service 跟踪战斗时长,X 秒后进入疲劳
   - HP < 30% 时切换到狂暴分支

**参考**:
- jskyzero《MH AI 出招设计》:反应性 + 随机性 + 派生
- UE 官方 Behavior Tree 文档:Decorator / Service 用法

---

### 难点 3:战斗手感调优

**症状**:攻击命中没反馈 = "砍空气";受击太软/太硬
**根因**:反馈要素没同步 + 帧数据没对齐

**攻克**:
1. **6 要素同步**(UE 实现):
   - **声音**:Play Sound at Location + Sound Cue
   - **特效**:Niagara System + Spawn Emitter at Location
   - **手柄震动**:Player Controller Client Play Force Feedback
   - **屏幕效果**:Camera Shake + Post Process
   - **动作反馈**:敌人 Anim BP 切到 Hit 状态
   - **环境反馈**:周围粒子 / 镜头推近
2. **帧数据驱动表**(用户填,Mavis 写入 UE DataTable):
   ```
   招式 | 前摇帧 | 判定帧 | 后摇帧 | 取消窗口
   轻击1 |  X    |  X帧   |  X     | 后摇第 X 帧起
   轻击2 |  X    |  X帧   |  X     | 后摇第 X 帧起
   ```
3. **hit stop 时序**(Anim Notify 实现):
   - 命中后 0ms:Trigger Camera Shake
   - 命中后 5ms:Play Sound
   - 命中后 10ms:Set Global Time Dilation = 0.05(冻结 1 帧)
   - 命中后 15ms:Apply Impulse(受击位移)
4. **玩家测试驱动**:每个调优点都让真人玩 5 分钟

**参考**:见阶段 2 阅读清单

---

### 难点 4:连招派生的输入窗口

**症状**:按键太快断招 / 太慢断招 / 误触闪避打断攻击

**攻克**:
1. **输入缓冲队列**(UE Enhanced Input + 自建 Buffer Component):
   - 环形队列,保存最近 0.2-0.3s 输入
   - 招式 Tick 时检查队列
2. **招式尾部分取消窗口**(Anim Notify "CancelWindowStart/End"):
   - 通知 C++ 进入/退出取消窗口
   - 输入在窗口内 → 触发派生
3. **输入优先级**(Enhanced Input Mapping Context Priority):
   - 闪避 Context Priority > 攻击 Context
   - 高优先级可中断低优先级
4. **取消规则明确化**(用户填):
   - 轻击 → 轻击:任何时候可取消
   - 轻击 → 重击:轻击 3 后摇前 1/3 不可,后 2/3 可
   - 任何攻击 → 闪避:任何时候可取消

**参考**:腾讯云《3D 动作连招开发》

---

### 难点 5:UE 学习曲线陡

**症状**:UE 概念太多(BP/C++/Anim BP/BT/GAS/...),新手容易迷失

**攻克**:
1. **第一周只看核心**:编辑器 + Character + Enhanced Input + Animation BP
2. **第二周加 AI**:Behavior Tree + Blackboard + AI Controller
3. **不要碰 GAS**:Demo 阶段用自建组件
4. **不要碰多人/网络同步**:单机即可
5. **不要碰 Niagara 高级用法**:基础粒子够用
6. **抄 UE 模板**:Third Person 模板 + Lyra 示例项目
7. **中文教程优先**:B 站搜"UE5 XXX"比英文文档快

**避坑清单**:
- ❌ 不要从 C++ 开始(先用 Blueprint 入门)
- ❌ 不要试图理解所有 UE 模块(用到再学)
- ❌ 不要做大型项目(单人 Demo 阶段项目 < 100 个文件)

---

### 难点 6:美术资源缺失(UE 自带资源够用)

**症状**:没怪物模型 / 没主角精灵图 / 没攻击特效

**UE 自带资源**:
- **主角**:UE Mannequin(自带骨骼 + 动画)
- **怪物**:Mannequin 改色 + Cube 拼造型,**或** Mixamo 免费怪兽模型
- **动画**:Mixamo 免费动画库(Attack/Run/Jump/Hit/Death 等)
- **场景**:UE Starter Content(免费地面/树/石头/天空)
- **特效**:Niagara 基础粒子(自带)
- **音效**:UE Starter Content Sound(免费)

**攻克**:
1. **主角**:UE Mannequin(男/女) + Mixamo 动画
2. **怪物**:
   - **方案 A**(简单):Mannequin 改红色 + 加 2 个 cube 当爪子
   - **方案 B**(进阶):Mixamo 搜 "monster" / "wolf" / "creature"
   - **方案 C**(进阶):Unreal Marketplace 免费资产(Paragon 残档)
3. **招式判定**:Draw Debug Line/Sphere(开发期可见)
4. **特效**:Niagara System(从 Starter Content 复制)
5. **不要做的**:
   - ❌ 自己建模(工作量太大)
   - ❌ 自己 K 动画(用 Mixamo)
   - ❌ 写复杂 Shader(用 Starter Content 材质)

**演示要求**:**不需要好看,只需要能看清招式 + 受击反馈 + 状态切换**

---

## 六、参考资料(分类整理)

### 6.1 MH 拆解参考(已有)

| 资源 | 路径/链接 | 必读度 |
|---|---|---|
| MH 怪物 AI 参考资料合集 | `参考资料/怪物猎人/00-MH怪物AI拆解-参考资料合集.md` | ★★★ |
| jskyzero《怪物猎人中的 AI 出招设计》 | https://zhuanlan.zhihu.com/p/645269557 | ★★★ |
| 游民星空《MH 荒野全大型怪物图鉴》 | https://www.gamersky.com/z/monster-hunter-wild/1681755_37580/ | ★★★ |
| 机核网《怪猎:世界战斗系统拆解》 | https://www.gcores.com/articles/164462 | ★★ |
| CSDN《怪物猎人战斗核心设计分析》 | https://blog.csdn.net/wubaohu1314/article/details/120586075 | ★★ |

### 6.2 战斗手感参考

| 资源 | 链接 | 价值点 |
|---|---|---|
| 腾讯 GWB《火影忍者手游打击感》 | https://gwb.tencent.com/community/detail/124613 | 起手/攻击/收招 3 段式 + DPH |
| CSDN《游戏打击感设计解析》 | https://blog.csdn.net/qq_25333681/article/details/95212879 | hit stop / 帧冻结 |
| 网易《枪械设计 - 表现/手感篇》(Minke) | https://c.m.163.com/news/a/KHK503HK0526DPBA.html | 21000+字 3C 框架 |
| 知乎《我开发的角色动作系统》 | http://zhuanlan.zhihu.com/p/67143501 | 战斗策略 + 11 种反馈 |
| 腾讯云《3D 动作游戏连招开发》 | (腾讯云开发者社区) | 输入缓冲 / 动态判定 |
| GDC《Juice it or lose it》 | https://www.youtube.com/watch?v=Fy0aCDmgnxg | (英文)经典 |

### 6.3 状态机/AI 参考

| 资源 | 链接 | 价值点 |
|---|---|---|
| jskyzero《MH AI 出招设计》 | (见上) | FSM 拆包视角 |
| 腾讯云《行为树教程(附代码)》 | (已搜到) | BT 完整代码实现 |
| 博客园《游戏 AI - 行为树 Part2》 | (已搜到) | BT 框架设计 |
| 知乎《游戏开发怪物 AI - 行为树》 | (已搜到) | BT 节点图解 |
| 知乎《行为树实战训练营 - 状态机》 | (已搜到) | 空洞骑士 BOSS 案例 |
| **UE 官方 Behavior Tree 文档** | https://docs.unrealengine.com/ | ★★★ UE 专用 |
| 《Game AI Pro》(免费) | https://www.gameaipro.com/ | AI 经典论文合集 |
| 《Game Programming Patterns》 | https://gameprogrammingpatterns.com/ | 状态机 / 组件模式圣经 |

### 6.4 UE 5.4 引擎参考(新增)

| 资源 | 链接 | 必读度 |
|---|---|---|
| **UE 官方文档** | https://docs.unrealengine.com/ | ★★★ |
| **UE 5.4 Animation Blueprint 教程** | B 站搜"UE5 Anim BP" | ★★★ |
| **UE 5.4 Enhanced Input 教程** | B 站搜"UE5 Enhanced Input" | ★★ |
| **UE 5.4 Behavior Tree 教程** | B 站搜"UE5 BT" | ★★★ |
| **Lyra 示例项目** | UE Marketplace 免费 | ★★ |
| **UE 官方 Third Person 模板** | UE 内置 | ★★ |
| **Tom Looman UE5 C++ 教程** | https://www.tomlooman.com/ | ★★ |
| **Mathew Wadstein UE5 系列** | YouTube | ★★ |
| **Epic Online Learning** | https://dev.epicgames.com/community/learning | ★ |

---

## 七、风险与备选方案

### 7.1 时间风险

**风险**:UE 学习曲线陡 + 1 只怪完整实现 = 总工作量 ~6 个月

**备选**:
- **全量版**(v1.1 默认,6 个月):MH 拆解 + 主角战斗 + 1 只怪完整实现
- **极简版**(3-4 个月):MH 拆解 + 主角战斗原型(无怪物,只跟木桩打)
- **MH 优先版**(2-3 个月):只做 MH 拆解 + UE 入门

### 7.2 UE 安装风险

**风险**:
- UE 5.4 体积大(~30 GB),需要 C 盘或 D 盘空间
- 家里电脑配置可能不够(显卡 / 内存)
- Visual Studio 2022 安装耗时

**备选**:
- 如果电脑配置不够:**保持 Godot 2D 方案**(v1.0 原计划)
- 如果 UE 安装失败:先用 Epic Games Launcher 修复
- 如果 Visual Studio 装不上:用 Rider 或 VS Code + MSVC 编译环境

### 7.3 学习曲线风险

**风险**:UE 概念多,新手容易卡在某个环节

**备选**:
- 卡在 C++:用 Blueprint 替代(主角逻辑用 BP,牺牲性能换时间)
- 卡在 Animation BP:用 Mixamo 直接导 FBX 动画,简化 BP 逻辑
- 卡在 Behavior Tree:先用最简单的硬编码 if-else AI,后续再重构 BT

### 7.4 美术资源风险

**风险**:用 UE 自带资源可能演示效果单调

**解决**:
- 已用 Mannequin + Mixamo(免费)覆盖主角 + 怪物 + 动画
- 演示 Demo 不需要好看,需要能看清招式 + 反馈
- 录屏时调高画质 + 加些镜头角度

---

## 八、本计划"用户填答"清单

### MH 拆解(M1-M2)
- [ ] 选哪只怪拆?默认大凶豺龙
- [ ] MH 战斗系统拆解载体?xlsx(推荐) / md
- [ ] 7 sheet 模板是否需要调整?

### 战斗手感(M3)
- [ ] 输入缓冲/hit stop 是否需要 Mavis 写最小 demo 给你玩?
- [ ] 读完后用自己的话写一份"打击感要素清单"

### 主角战斗(M5-M7)
- [ ] 主角连招几段?推荐 3-5 段
- [ ] 主角武器类型?推荐剑 + 弓
- [ ] 战斗反馈必选清单?哪些可省?
- [ ] 是否用 GAS?默认不用

### 怪物设计(M8-M10)
- [ ] 怪物选型?默认大凶豺龙
- [ ] 怪物名字?沿用 MH 还是自创?
- [ ] 招式设计表的默认值,要 Mavis 提供经验值吗?
- [ ] 行为树选招权重,要 Mavis 提供经验值吗?
- [ ] 怪物占位美术:Mannequin 改色 / Mixamo 怪兽?

### 整合打磨(M11-M12)
- [ ] demo 演示时长目标?推荐 3 分钟内
- [ ] 是否需要 BGM?推荐先静音
- [ ] 录屏工具?OBS / Windows Game Bar

### 环境准备(立即)
- [ ] 家里电脑配置是否满足 UE 5.4 要求?(内存 16GB+,显卡 NVIDIA)
- [ ] 是否需要先在 Godot 跑通 3D 再转 UE?(推荐直接 UE)
- [ ] UE 安装路径?推荐 `D:\UE_5.4\`

---

## 九、下一步立即可做的 5 件事

1. **检查家里电脑配置**(内存 / 显卡 / 硬盘),确认能装 UE 5.4
2. **下载 Epic Games Launcher + UE 5.4 LTS**(约 30 GB,推荐装 D 盘)
3. **下载 Visual Studio 2022 Community**(选"使用 C++ 的游戏开发"工作负载)
4. **建项目目录**:
   - `D:\portfolio\大型怪物战斗\`(已建,文档同步用)
   - `D:\UE_Projects\大型怪物战斗\`(UE 项目,加 `.gitignore`)
5. **运行 UE Third Person 模板**,让 Mannequin 走路 + 跳跃(UE 入门测试)

---

## 十、版本记录

- v1.0 (2026-07-02):初版,基于现有作品集 + MH 拆解参考资料 + 已掌握的 Godot 经验
- v1.1 (2026-07-02):**修订**:
  - 怪物数 2-3 → **1**
  - 2D → **3D**
  - Godot → **UE 5.4 LTS**
  - 美术:用户做 → **UE 自带 + Mixamo(简单占位)**
  - 新增 **UE 学习子计划**(2 周入门路线)
  - 新增 **UE 环境准备清单**(硬件/安装/目录规划)
  - 6 难点改为 **UE 特定方案**

---

**备注**:
- 本计划**不重写**封印勇者 demo,两条产品线独立运行(封印勇者继续 Godot)
- 本计划**复用**艾尔登法环拆解方法论 + 哈迪斯 2 拆解模板
- 本计划**强制要求**1 只怪完整实现(招式+状态机+AI+UE 场景)
- 本计划**默认引擎** UE 5.4 LTS(稳定性优于 5.5+)
- 本计划**美术**全部用 UE 自带资源 + Mixamo,零成本