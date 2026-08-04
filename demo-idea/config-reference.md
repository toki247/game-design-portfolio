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
| color | enum | - | `brown` / `white` / `black` / ... | 颜色绑定 |
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

### 5.1 常见 Effect 类型参数

| type | params 字段 | 备注 |
|---|---|---|
| `damage` | `{value: N}` | 直接伤害 |
| `armor` | `{value: N}` | 护甲值 |
| `heal` | `{value: N}` | 治疗 |
| `dot` | `{damage_per_turn: N, duration: M}` | 持续伤害(M 回合,每回合 N 伤害) |
| `buff` | `{buff_type: "X", value: V, duration: M}` | 施加 buff(给 target 加 buff) |
| `debuff` | `{buff_type: "X", value: -V, duration: M}` | 施加负向 buff |

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
| trigger | enum | - | `periodic` / `charge` / `counter` / `on_turn_start` / `on_hp_threshold` | 触发模式 |
| params | dict | {} | - | 触发参数 |
| target | enum | - | `player` / `self` / `all` | 目标 |

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
      "params": {"threshold": 50, "comparison": "greater"},
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
      "params": {"threshold": 50, "comparison": "less_equal", "charge_turns": 2},
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
      "params": {"threshold": 75, "comparison": "greater"}
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
      "params": {"threshold_range": [50, 75], "charge_turns": 2}
    },
    {
      "id": "weakness_curse",
      "name": "虚弱诅咒",
      "effects": [{"type": "debuff", "target": "player", "params": {"buff_type": "attack_down", "value": -50, "duration": 1}}],
      "trigger": "on_hp_threshold",
      "params": {"threshold": 50, "comparison": "less_equal"}
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

## 13. UI / 视觉

### 13.1 整体风格
- **像素复古风**(8-bit / 16-bit)
- 色调:复古暖色(根据方块颜色延伸)

### 13.2 方块视觉
- 颜色: 暖棕(挥砍) / 米白(护甲) / 纯黑(增幅)
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

| 字段 | 类型 | 默认值 | 范围 | 备注 |
|---|---|---|---|---|
| bd 流派数 | int | 3 | 3-4 | 用户暂定 3 |
| 抽取 N 个 | int | 3 | 1-5 | 每次战斗/商店/事件抽取数 |
| 加权基数 | float | 1.0 | 0-∞ | 玩家持有标签最多的额外加权 |
