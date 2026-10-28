# AI Game Design:从想法到可玩生产计划

> 来源:`https://easyclaw.com/zh-tw/blog/ai-agent-101/ai-game-design`(EasyClaw 博客,繁体原文)。
> 性质:**替代品** —— 原作者陌情的「从 GDD 到可玩原型的流程」已随其作品集站点停服而不可达,本文档是补同一空位的公开资料。
> 处理方式:原文为繁体,此处转写为简体,内容未增删;原文中的产品名 EasyClaw 与具体提示词一并保留,仅为忠实存档。

---

## 核心判断

AI 生成的创意大多永远不会变得可玩,因为它们只是想法,不会成为核心循环、原型范围、生产计划或游戏测试就绪的建置。

**AI 游戏设计工作流应当是一条清晰的链条:**

```
原始想法 → 玩家幻想 → 核心循环 → 机制 → 规则和约束 → 功能范围 → 精简 GDD → 原型计划 → 生产里程碑 → 游戏测试反馈 → 迭代计划
```

每个步骤都应该回答一个问题:玩家应该有什么感觉,他们会重复什么,什么会产生紧张感,可以先建造什么,以及游戏测试应该证明什么?

## 第 1 步:从玩家的幻想开始

在机制、美术或故事之前,定义玩家应该感觉自己正在做什么。玩家的幻想是游戏的情感承诺。

> 提示词:`Turn this rough game idea into three possible player fantasies. For each one, explain the main emotion, the main action verb, the player promise, and why it could be fun.`
> 建议输出:玩家幻想、情感、动作动词、玩家承诺,以及为什么它会很有趣。

## 第 2 步:定义核心循环

核心循环是玩家执行动作的可重复循环。生存游戏可能是「探索→收集→制作→生存→升级→再次探索」;侦探游戏可能是「观察→收集线索→形成理论→测试理论→解锁新区域」。

**循环必须能说清三个时间尺度:**

| 尺度 | 播放的内容 |
|---|---|
| 30 秒 | 即时播放的内容 |
| 5 分钟 | 短期目标 |
| 30 分钟 | 进展 |

如果循环只是在纸面上听起来很有趣,但在实际操作中却不有趣,那这个想法还需要更多的工作。

> 提示词:`Based on this player fantasy, generate three possible core loops. Keep each loop under six steps. Explain what the player does every 30 seconds, every 5 minutes, and every 30 minutes.`

## 第 3 步:将想法转化为机制

机制不仅仅是功能。**机制是创建玩家决策的规则。**

> 「炼金术」是一个特色;「在时间压力下将两种不稳定的成分结合;错误的组合会产生副作用」更接近机械师。

> 提示词:`Convert this core loop into 8 possible mechanics. For each mechanic, include the player action, rule, resource, risk, reward, and production complexity.`

按玩家行为、规则、资源、风险、奖励和生产复杂度给每个机制评分。不要接受所有选项——好的工作流能识别**可以原型化的机制**,而不只是听起来很酷的机制。

## 第 4 步:在范围扩大前缩小范围

AI 经常扩展想法,游戏制作通常需要相反的东西。

| 优先级 | 意义 |
|---|---|
| Must-have | 核心循环或第一个可玩原型所需 |
| Should-have | 改善循环,但可以等 |
| Could-have | 有趣但非必需 |
| Cut | 分散注意力、成本太高或与核心循环无关 |

对于第一个可玩的原型,你只需要**足够回答一个问题:核心体验值得建造吗?**

> 提示词:`Review this feature list and classify each feature as Must-have, Should-have, Could-have, or Cut. Be strict. Prioritize the smallest playable version of the game.`

## 第 5 步:创建精简 GDD

游戏设计文档应该是一个活生生的生产文档,而不是一个没人读的巨大文件。

**精简 GDD 应包含:**一句话推广、目标玩家、玩家幻想、核心循环、关键机制、控制、规则、获胜/失败条件、内容结构、艺术和音频指导、UI 需求、技术假设、资产清单、原型范围、风险和里程碑。

> 提示词:`Turn the approved concept, core loop, and feature scope into a lean game design document. Keep it practical, production-focused, and easy for a small team to use. Include open questions, risks, and prototype assumptions.`

## 第 6 步:制定生产计划

**GDD 解释了游戏是什么。生产计划解释了如何建造它。**

| 里程碑 | Goal | Example | 完成的定义 |
|---|---|---|---|
| Concept Validation | 确认这个想法值得原型设计 | 一页文档、核心循环、参考文献、风险列表 | 值得做 |
| First Playable Prototype | 测试核心循环 | 主要交互、占位 UI、基本胜/负状态 | 有人能玩到一个粗糙版本 |
| Vertical Slice | 展示一个打磨过的场景 | 一个关卡、一份美术样例、一份音频样例、UI 打磨 | 一个完整片段 |
| Content Expansion | 把有效的东西做多 | 关卡、敌人、道具、任务、平衡 | 可重复的内容管线 |
| Release Preparation | 准备上线 | Bug 修复、新手引导、性能、商店页 | 上线检查清单完成 |

> 提示词:`Turn this GDD into a production plan with milestones, tasks, dependencies, risks, and priority. Focus on what must be built first to test whether the game is fun.`

**设计只有具备任务、依赖关系和完成标准后才能投入生产。**

## 第 7 步:把 AI 游戏设计变成工作流

一个长长的 AI 答案并不是一个计划。计划需要阶段、任务、依赖关系、优先级和输出。

以「动态怪物行为」这类模糊功能为例,变成真正的工作应该是:

1. 定义行为状态
2. 原型一个敌人
3. 建立占位符动画需求
4. 编写测试场景
5. 游戏测试难度
6. 记录反馈
7. 决定是否扩大、简化或削减

这就是 AI 头脑风暴和 AI 工作流之间的区别。

## 第 8 步:完整工作流示例

**输入:** 粗略想法「一款 Roguelite 烹饪游戏,玩家在受诅咒的森林中经营一家餐厅」/ 平台 PC / 团队 独立开发者 / 引擎 Unity 或 Godot / 目标 4 周内第一个可玩原型。

**工作流:** 产生三个玩家幻想 → 选最强的幻想 → 定义 30 秒/5 分钟/30 分钟的核心循环 → 生成可能的机制 → 把功能清单 Cut 到最小可玩版本 → 创建精简 GDD → 制定里程碑计划 → 建立资产和 UI 清单 → 准备游戏测试问题 → 打包成生产计划。

| 可交付成果 | 示例 |
|---|---|
| One-page pitch | 一个被诅咒的森林烹饪 Roguelite,其中每个食谱都是一个生存决定 |
| Core loop | 收集食材 → 高压烹饪 → 侍酒 → 获得升级 → 进入更深的森林 |
| Must-have features | 食材拾取、烹饪计时器、一种客户类型、一种食谱链、基本升级 |
| Lean GDD | 玩家幻想、规则、循环、控制、胜负状态、风险 |
| Prototype task list | 移动、食材交互、烹饪站、计时器、客户回应 |
| Asset list | 占位厨师、三种食材、一个摊位、一位顾客、简单 UI |
| 4 周里程碑计划 | 第 1 周核心交互、第 2 周烹饪循环、第 3 周进展、第 4 周游戏测试 |
| Playtest 表格 | 清晰度、张力、节奏、食谱可读性、混淆点 |

## 第 9 步:在建造太多之前制定游戏测试计划

游戏创意只有在有人玩的时候才会变成现实。

第一个测试不应该问「人们喜欢我的完整游戏吗?」——它应该问一个更小的问题:**「核心动作有意义吗?有理由重复它吗?」**

Playtest 问题:

- 玩家明白该做什么吗?
- 核心动作是否令人满意?
- 挑战是否明确?
- 奖励有意义吗?
- 玩家哪里无聊了?
- 玩家尝试了哪些游戏不支持的操作?
- 该剪什么?

> 提示词:`Create a playtest plan for this first playable prototype. Include test goals, player tasks, observation notes, feedback questions, and a post-test iteration checklist.`

## 第 10 步:避免常见的 AI 游戏设计错误

- 向 AI 询问太多想法而不是选择一个
- 将传说与游戏玩法混淆
- 在测试核心循环之前建立一个巨大的 GDD
- 让 AI 扩大而不是缩小范围
- 没有规则的生成机制
- 忽略生产复杂性
- 跳过游戏测试
- 将 AI 输出视为最终设计判断
- 忘记平台和团队的限制
- 没有将设计转化为任务

## 最佳实践

从玩家的幻想开始 → 在编写传说之前定义核心循环 → 让 AI 产生选择而不是最终的真相 → 强制权衡 → 积极 Cut 范围 → 建立最小的可玩原型 → 保持 GDD 精简 → 按里程碑进行规划 → 尽早 Playtest。

## 反馈如何变成下一步

Playtest 笔记通常很混乱。可以把反馈分组为:控制、清晰度、难度、节奏、错误、情绪反应、功能请求、范围风险。然后让每条反馈都对应一个具体的下一步动作。

**只有当反馈改变了「你接下来要建的东西」时,反馈才有用。**
