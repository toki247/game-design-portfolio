# 配置参考文档

> 所有可配字段的集中参考。W5+ 实现时,JSON 文件字段必须跟这里一致。
> 当前状态:**W3 框架定稿**,W5+ 完善默认值 / 范围 / JSON 示例。

---

## 1. 战斗循环

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| 棋盘行数 (row_count) | int | 4 | 1-10 | 行(row),向下增加 |
| 棋盘列数 (col_count) | int | 10 | 1-20 | 列(col),横向 |
| 行动次数 (ap_max) | int | 6 | 1-20 | 每玩家回合回满 |
| 6+ 块每多 1 块系数 (extra_block_coef) | float | 1.2 | 1.0-2.0 | 5 块效果的倍数 |
| 防卡关:交换必形成消除 | bool | true | - | 否则回滚不消耗行动 |
| 防卡关:补充后检测 | bool | true | - | 无消除空间则整盘重置 |
| 联锁免费 | bool | true | - | 补充后自动消除不消耗行动 |

## 2. 角色 (Character)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| id | str | - | - | 唯一标识 |
| name | str | - | - | 角色名 |
| type | enum | - | `player` / `enemy` | 玩家/敌人 |
| hp | int | - | 0 ~ hp_max | 当前血量 |
| hp_max | int | - | 1 ~ ∞ | 最大血量 |
| ap | int | - | 0 ~ ap_max | 当前行动点 |
| ap_max | int | - | 1 ~ ∞ | 最大行动点 |
| resources | dict[str, Resource] | - | - | 资源槽 |
| buff_queue | list[Buff] | [] | - | FIFO buff 队列 |
| armor | int | 0 | 0 ~ 99999 | 护甲值(独立字段,跨回合) |
| damage_reduction | int | 0 | 0 ~ 100 | 减伤 % |
| skills | list[Skill] | - | - | 技能列表 |
| ai_behavior | AIBehavior? | null | - | 敌人 AI(玩家 null) |

## 3. 资源 (Resource)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| name | str | - | - | 资源名(MP/能量/...) |
| current | int | 0 | 0 ~ max | 当前值 |
| max | int | - | 1 ~ ∞ | 上限 |
| regen_per_turn | int | 0 | -∞ ~ ∞ | 每回合自动恢复(可负) |
| carry_over | bool | true | - | 跨回合是否保留 |

> MP 是魔剑士特有资源,默认 `regen_per_turn = 0`(不自动恢复)。

## 4. 技能 (Skill)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| id | str | - | - | 唯一标识 |
| name | str | - | - | 技能名 |
| slot | enum | - | `slot1` / `slot2` / `slot3` | 技能槽位(对应方块颜色:棕/白/黑) |
| effects_by_count | dict[int, list[Effect]] | - | - | 消除数 → 效果列表 |
| extra_block_rule | struct | - | - | 6+ 块规则 |

### 4.1 extra_block_rule

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| base_count | int | 5 | 5 ~ ∞ | 基础块数(5 块 = 5 块效果) |
| coef_per_extra | float | 1.2 | 1.0-2.0 | 每多 1 块的系数 |

## 5. 效果 (Effect)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| type | enum | - | `damage` / `armor` / `buff` / `heal` / `dot` / ... | 效果类型 |
| target | enum | - | `self` / `enemy` / `all` | 目标 |
| params | dict | {} | - | 数值参数(可配) |

### 5.1 常见 Effect 类型参数(Discriminated Union 模式)

> `type` 字段决定 `params` 的 schema。实现时按 type 分支解析,加 schema 校验。

| type | params 字段 | 备注 |
|---|---|---|
| `damage` | `{value: int}` | 直接伤害 |
| `armor` | `{value: int}` | 护甲值 |
| `heal` | `{value: int}` | 治疗 |
| `dot` | `{damage_per_turn: int, duration: int}` | 持续伤害(M 回合,每回合 N 伤害) |
| `buff` | `{buff_type: str, value: float, duration: int \| "permanent"}` | 施加 buff(给 target 加 buff) |
| `debuff` | `{buff_type: str, value: float, duration: int \| "permanent"}` | 施加负向 buff(value 通常为负,可等价于 buff) |

**注**:`debuff` 本质是 `buff` + 负 value,实现时可统一为 `buff`,只校验 value 符号。或者保留 `debuff` 作为语义别名。

## 6. Buff

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| id | str | - | - | 唯一标识 |
| type | enum | - | `amplify` / `reduction` / `dot` / `regen` / ... | buff 类型 |
| value | float | - | -∞ ~ ∞ | 数值 |
| duration | enum | - | `permanent` / N 回合 | 持续时间 |
| stack_rule | enum | `queue` | `queue` / `max` / `sum` / `replace` | 叠加规则 |
| max_stacks | int? | null | 1 ~ ∞ | 最大叠加数(可选) |
| carry_over | bool | true | - | 跨回合是否保留 |
| trigger | enum | - | `on_consume` / `on_hit` / `on_turn_start` / ... | 触发条件 |
| priority | int | 0 | -∞ ~ ∞ | 触发优先级(越小越先) |
| source | str | - | - | 来源标识 |

### 6.1 stack_rule 语义

- `queue` = FIFO 队列(魔剑士的增幅 buff,按时间顺序使用)
- `max` = 取最大值(白色减伤,多次消除取最大覆盖)
- `sum` = 累加
- `replace` = 覆盖

## 7. 符文 (Rune)

> 跟 Skill 1:1 关系,字段复用 + `tags` / `profession_pool`

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| ...(同 Skill) | | | | |
| **tags** | list[str] | [] | - | 加权算法标签(对应 bd 流派) |
| **profession_pool** | str | - | - | 所属职业符文池标识 |

## 8. 装备 (Equipment)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| id | str | - | - | 唯一标识 |
| name | str | - | - | 装备名 |
| slot | enum | - | `head` / `chest` / `weapon` / `accessory` / ... | 装备槽 |
| effects | list[Effect] | - | - | 装备效果(永久) |

## 9. 一次性道具 (Consumable)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| id | str | - | - | 唯一标识 |
| name | str | - | - | 道具名 |
| max_count | int | 5 | 1 ~ ∞ | 最大持有数 |
| effects | list[Effect] | - | - | 使用时触发的效果 |

## 10. 敌人 (Character 复用 + 扩展)

> 敌人 = Character + `actions_per_turn` + `attacks` + `ai_behavior`
> 敌人**没有 AP**,使用 `actions_per_turn` 字段

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| actions_per_turn | int | 1 | 1 ~ ∞ | 一回合行动次数 |

### 10.1 敌人攻击 (Attack)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| id | str | - | - | 唯一标识 |
| name | str | - | - | 攻击名 |
| effects | list[Effect] | - | - | 攻击效果 |
| trigger | enum | - | `periodic` / `charge` / `counter` / `on_turn_start` / `on_turn_end` / `on_hp_threshold` | 触发模式 |
| params | dict | {} | - | 触发参数(见 10.1.1) |
| target | enum | - | `player` / `self` / `all` | 目标 |

#### 10.1.1 trigger.params schema(Discriminated Union 模式)

> `trigger` 字段决定 `params` 的 schema。实现时按 trigger 分支解析。

| trigger | params 字段 | 备注 |
|---|---|---|
| `periodic` | `{interval: int}` | 每 N 回合触发 |
| `charge` | `{charge_turns: int}` | 蓄力 N 回合后触发 |
| `counter` | `{chance: float}` | 受击时 N 概率触发(0.0-1.0) |
| `on_turn_start` | `{}` | 回合开始触发,无参数 |
| `on_turn_end` | `{}` | 回合结束触发,无参数 |
| `on_hp_threshold` | `{hp_threshold: int, hp_comparison: enum}` 或 `{hp_threshold_range: [min, max], hp_comparison: enum}` | HP 阈值触发 |

##### hp_comparison 枚举值

| 值 | 语义 |
|---|---|
| `greater` | `HP > threshold` |
| `greater_equal` | `HP >= threshold` |
| `less` | `HP < threshold` |
| `less_equal` | `HP <= threshold` |
| `within_range` | `min <= HP <= max`(配 `hp_threshold_range` 用) |
| `outside_range` | `HP < min` 或 `HP > max`(配 `hp_threshold_range` 用) |

### 10.2 AI 行为 (AIBehavior)

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| type | enum | - | `random` / `charge` / `counter` / `periodic` | AI 类型 |
| params | dict | {} | - | AI 参数 |

## 11. 敌人实例

> 5 个敌人,JSON 模板。W5+ 资源时填具体数值。

### 11.1 史莱姆(普通 1,基础伤害)

```json
{
  "id": "enemy_slime",
  "name": "史莱姆",
  "type": "enemy",
  "hp_max": 30,
  "ap_max": 0,
  "actions_per_turn": 1,
  "armor": 0,
  "damage_reduction": 0,
  "attacks": [
    {
      "id": "slime_bump",
      "name": "撞击",
      "effects": [{"type": "damage", "target": "player", "params": {"value": 5}}],
      "trigger": "periodic",
      "params": {"interval": 1},
      "target": "player"
    }
  ],
  "ai_behavior": {"type": "periodic", "params": {}}
}
```

### 11.2 火焰元素(普通 2,DoT 跨回合)

```json
{
  "id": "enemy_fire_elemental",
  "name": "火焰元素",
  "type": "enemy",
  "hp_max": 40,
  "actions_per_turn": 1,
  "armor": 0,
  "damage_reduction": 0,
  "attacks": [
    {
      "id": "fire_breath",
      "name": "火焰吐息",
      "effects": [
        {"type": "damage", "target": "player", "params": {"value": 6}},
        {"type": "dot", "target": "player", "params": {"damage_per_turn": 3, "duration": 3}}
      ],
      "trigger": "periodic",
      "params": {"interval": 1},
      "target": "player"
    }
  ],
  "ai_behavior": {"type": "periodic", "params": {}}
}
```

### 11.3 暗影刺客(普通 3,debuff 跨回合)

```json
{
  "id": "enemy_shadow_assassin",
  "name": "暗影刺客",
  "type": "enemy",
  "hp_max": 35,
  "actions_per_turn": 1,
  "armor": 0,
  "damage_reduction": 0,
  "attacks": [
    {
      "id": "shadow_stab",
      "name": "暗影刺",
      "effects": [
        {"type": "damage", "target": "player", "params": {"value": 8}},
        {"type": "debuff", "target": "player", "params": {"buff_type": "armor_down", "value": -20, "duration": 2}}
      ],
      "trigger": "periodic",
      "params": {"interval": 1},
      "target": "player"
    }
  ],
  "ai_behavior": {"type": "periodic", "params": {}}
}
```

### 11.4 冰霜巨像(BOSS 1,HP 阈值)

```json
{
  "id": "boss_frost_colossus",
  "name": "冰霜巨像",
  "type": "enemy",
  "hp_max": 100,
  "actions_per_turn": 1,
  "attacks": [
    {
      "id": "frost_breath",
      "name": "冰霜吐息",
      "effects": [{"type": "damage", "target": "player", "params": {"value": 8}}],
      "trigger": "on_hp_threshold",
      "params": {"hp_threshold": 50, "hp_comparison": "greater"},
      "target": "player"
    },
    {
      "id": "frost_burst",
      "name": "冰霜爆发",
      "effects": [
        {"type": "damage", "target": "player", "params": {"value": 15}},
        {"type": "debuff", "target": "player", "params": {"buff_type": "slow", "value": -30, "duration": 2}}
      ],
      "trigger": "on_hp_threshold",
      "params": {"hp_threshold": 50, "hp_comparison": "less_equal", "charge_turns": 2},
      "target": "player"
    }
  ],
  "ai_behavior": {"type": "periodic", "params": {}}
}
```

### 11.5 虚空领主(BOSS 2,多 AI 组合)

```json
{
  "id": "boss_void_lord",
  "name": "虚空领主",
  "type": "enemy",
  "hp_max": 120,
  "actions_per_turn": 1,
  "attacks": [
    {
      "id": "shadow_arrow",
      "name": "暗影箭",
      "effects": [{"type": "damage", "target": "player", "params": {"value": 10}}],
      "trigger": "on_hp_threshold",
      "params": {"hp_threshold": 75, "hp_comparison": "greater"}
    },
    {
      "id": "shadow_counter",
      "name": "反击",
      "effects": [{"type": "damage", "target": "player", "params": {"value": 6}}],
      "trigger": "counter",
      "params": {"chance": 0.3}
    },
    {
      "id": "shadow_wave",
      "name": "暗影波",
      "effects": [
        {"type": "damage", "target": "player", "params": {"value": 12}},
        {"type": "dot", "target": "player", "params": {"damage_per_turn": 5, "duration": 2}}
      ],
      "trigger": "on_hp_threshold",
      "params": {"hp_threshold_range": [50, 75], "hp_comparison": "within_range", "charge_turns": 2}
    },
    {
      "id": "weakness_curse",
      "name": "虚弱诅咒",
      "effects": [{"type": "debuff", "target": "player", "params": {"buff_type": "attack_down", "value": -50, "duration": 1}}],
      "trigger": "on_hp_threshold",
      "params": {"hp_threshold": 50, "hp_comparison": "less_equal"}
    }
  ],
  "ai_behavior": {"type": "periodic", "params": {}}
}
```

## 12. 流程

### 12.1 单局流程(顶层)

```
选择职业 → 进入第一场战斗 → 2 选 1 → 下一节点 → ... → BOSS → 结束本局
死亡后:重新开始
```

### 12.2 单节点流程(中层,5 种节点)

| 节点 | 流程 |
|---|---|
| 战斗 | 进入 → 玩家回合 → 敌人回合 → 循环 → 胜利 → 奖励 → 退出节点 |
| 事件 | 进入 → 描述 → 选择 → 触发 → 奖励 → 退出节点 |
| 商店 | 进入 → 商店页面 → 购买 → 退出节点 |
| 休息 | 进入 → 恢复 → 退出节点 |
| BOSS | 同战斗(奖励更丰厚?W5+ 决定) |

### 12.3 单回合流程(底层)

```
玩家回合: AP 恢复 → 行动(6 次交换) → 结束按钮 → 玩家结算 → 敌人回合
敌人回合: actions 恢复 → AI 触发 → 攻击 → 结束 → 玩家回合
关键转换(玩家结算 / 敌人结算): dot 伤害结算 + 回合结束机制结算
```

#### 12.3.1 回合开始流程

1. **资源再生**:每个 Resource 按 `regen_per_turn` 增加(MP 默认 0,不自动恢复)
2. 进入行动阶段

#### 12.3.2 回合结束流程

1. 判定敌人 dot 伤害
2. 判定玩家 dot 伤害
3. buff 持续回合数 -1
4. 控制状态重置

## 13. UI / 视觉

### 13.1 整体风格
- **像素复古风**(8-bit / 16-bit)
- 色调:复古暖色(根据方块颜色延伸)

### 13.2 方块视觉
- 颜色: 暖棕(**槽 1**) / 米白(**槽 2**) / 纯黑(**槽 3**)
  - **颜色 = 槽位,跨职业一致**
- 形状: 圆角方块

### 13.3 其他
- 角色 / 敌人 / UI 元素:**占位**(W5+ 资源时定)

## 14. 3C

### 14.1 Character
- **具体化**(sprite / 模型),参考杀戮尖塔
- 角色在**棋盘外**(不与方块重叠)
- 动画:可用,暂不做(W5+ 实现)

### 14.2 Camera
- **平面正交视角**(top-down,正交投影)
- **全棋盘固定**(不滚动,10×4 一次显示)
- **UI 布局**:参考杀戮尖塔,棋盘替代原本的"手牌展示区"

### 14.3 Control
- **交换方式**:鼠标点击 + 拖动(标准三消)
- **"结束回合"按钮**:棋盘**右侧**
- **buff 队列**:角色**血条下方**

## 15. 加权算法(肉鸽符文池)

> **当前状态:暂定 0%(纯随机抽取)**,加权机制后续再加。

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| bd 流派数 | int | 3 | 3-4 | 用户暂定 3 |
| 抽取 N 个 | int | 3 | 1-5 | 每次战斗/商店/事件抽取数 |
| 加权基数 | float | 1.0 | 0-∞ | **当前不生效,留 TODO** |

## 16. 状态机事件清单

> 状态机用事件驱动。§ 4.2 状态枚举已定,这里定义**事件列表 + 状态转移**。

### 16.1 状态(已定)

- `player_turn` / `player_settling` / `enemy_turn` / `enemy_settling` / `battle_end`

### 16.2 事件(按来源分 4 类)

**玩家操作**
- `swap_blocks_valid` - 有效交换(形成消除)
- `swap_blocks_invalid` - 无效交换(回滚,不消耗行动)
- `end_turn` - 玩家手动结束(唯一回合结束方式)

**消除 / 连锁**
- `chain_complete` - 连锁结束
- `anti_stuck_pass` - 防卡关检测通过
- `anti_stuck_fail` - 防卡关检测失败(整盘重置)

**回合切换**
- `player_settle_done` - 玩家结算完成
- `enemy_action_done` - 敌人行动完成
- `enemy_settle_done` - 敌人结算完成

**战斗结束**
- `player_dies` - 玩家 HP ≤ 0
- `enemy_dies` - 敌人 HP ≤ 0
- `both_die` - 同时 ≤ 0(玩家胜,HP=1)

## 17. 状态转移表

| 当前状态 | 事件 | 下一状态 | 备注 |
|---|---|---|---|
| `player_turn` | `swap_blocks_valid` | `player_settling` | 进入消除结算 |
| `player_turn` | `swap_blocks_invalid` | `player_turn` | 回滚,不消耗行动 |
| `player_turn` | `end_turn` | `player_settling` | 玩家手动结束(唯一方式) |
| `player_settling` | `chain_complete` | `player_turn` | 连锁结束,继续行动 |
| `player_settling` | `settle_done` | `enemy_turn` | 玩家结算完成,进入敌人回合 |
| `enemy_turn` | `action_done` | `enemy_settling` | 敌人行动完成 |
| `enemy_settling` | `settle_done` | `player_turn` | 敌人结算完成,进入玩家回合 |
| `*` | `player_dies` | `battle_end` (失败) | 任意状态 |
| `*` | `enemy_dies` | `battle_end` (胜利) | 任意状态 |
| `*` | `both_die` | `battle_end` (胜利,HP=1) | 同时死亡,玩家胜 |
