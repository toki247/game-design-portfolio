# maze-tbs

三消回合制肉鸽 demo。GDD 见 `D:\portfolio\demo-idea\maze-tbs-GDD.md`。

## 目录

- `GodotProject/` — Godot 4 工程(餐厅经营 MVP)
  - `scenes/main_menu.tscn` — 顶级主菜单(餐厅/地下城/养成)
  - `scenes/restaurant_main.tscn` — 餐厅页(仓库/烹饪 2 子入口)
  - `scenes/warehouse.tscn` — 仓库场景
  - `scenes/cook.tscn` — 烹饪场景(ScrollContainer 容纳任意食谱)
  - `scripts/main_menu.gd` — 主菜单脚本
  - `scripts/restaurant_main.gd` — 餐厅脚本
  - `scripts/warehouse.gd` — 仓库脚本(读 Inventory autoload)
  - `scripts/cook.gd` — 烹饪脚本(+/- 数量 / 自动售卖 / 弹窗)
  - `scripts/data/inventory.gd` — **autoload**,跨场景共享库存 + 金币
  - `scripts/data/recipe_book.gd` — **autoload**,食谱库(3 个假食谱)

## 启动

```powershell
& "D:\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe" --path "D:\portfolio\maze-tbs\GodotProject"
```

或 Godot Editor → Import → 选 `project.godot` → F5 运行。

## 进度

- [x] **P0** 项目脚手架 + 餐厅主页面
- [x] **P2-1** 仓库(3 分页 / 食材堆叠 / 假数据已迁 Inventory autoload)
- [x] **P2-2** 烹饪(3 食谱 / 数量选择 / 自动售卖 / 弹窗确认 / ScrollContainer)
- [x] **P0.5** 主菜单重做(3 大入口:餐厅/地下城/养成,售卖整合进烹饪)
- [ ] P1 战斗最小(1v1 战棋 + 4 动作 + 部位破坏)← 地下城接入
- [ ] P4 养成最小(技能/装备/职业)← 养成入口接入
- [ ] P3 场景串联(餐厅 ↔ 迷宫)
