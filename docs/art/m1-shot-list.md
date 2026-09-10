# M1 美术资源清单

> 里程碑：M1 验证切片  
> 范围：外围入口 + 第 1 层一段 + 一场 BOSS 压力战原型  
> 状态：待制作

本清单为 M1 里程碑所需的最小美术资源列表。所有资源基于 **2.5D 俯视箱庭** 视角，不含 3D mesh。

---

## 资源类型说明

| 类型标签 | 说明 | 分辨率 |
|----------|------|--------|
| `map-sprite` | 地图精灵：探索/战斗场景中显示的角色、敌人、NPC | 32×32 px |
| `map-tile` | 地图瓦片：地面、墙壁、装饰物 | 16×16 px |
| `portrait` | 立绘：对话系统中的角色表情差分 | 高分辨率（512+ px） |
| `ui` | 用户界面元素 | 8px 倍数 |
| `fx` | 特效：技能、伤害、状态 | 视情况 |

---

## 角色资源

### 主角

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 主角探索精灵 | `map-sprite` | 32×32, 4 方向, 行走 4 帧 | P0 | hero_idle/walk_n/s/e/w |
| 主角战斗精灵 | `map-sprite` | 32×32, 待机/攻击/受伤 | P0 | hero_combat_* |
| 主角立绘·默认 | `portrait` | 512+ px | P1 | portrait_hero_default |
| 主角立绘·惊讶 | `portrait` | 512+ px | P2 | portrait_hero_surprised |
| 主角立绘·坚定 | `portrait` | 512+ px | P2 | portrait_hero_determined |

### 敌人

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 墓影（Tomb Shade）精灵 | `map-sprite` | 32×32, 待机/攻击 | P0 | enemy_tomb_shade_* |
| 墓影战斗精灵 | `map-sprite` | 32×32, 受伤/死亡 | P1 | enemy_tomb_shade_hurt/die |
| 骨卫（Bone Guard）精灵 | `map-sprite` | 32×32, 待机/攻击 | P1 | enemy_bone_guard_* |

### BOSS（M1 原型）

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 半成品守护者精灵 | `map-sprite` | 32×32 或 64×64 | P0 | boss_guardian_proto_* |
| 半成品守护者立绘 | `portrait` | 512+ px | P1 | portrait_guardian_proto_default |
| 半成品守护者立绘·威压 | `portrait` | 512+ px | P2 | portrait_guardian_proto_menacing |

---

## 场景瓦片

### 外围/入口

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 废墟地面 | `map-tile` | 16×16, 变体 ×3 | P0 | tile_floor_ruins_0x |
| 废墟墙壁 | `map-tile` | 16×16, 上下左右 | P0 | tile_wall_ruins_* |
| 入口门 | `map-tile` | 16×32 或 32×32 | P0 | tile_door_entrance |
| 装饰·碎石 | `map-tile` | 16×16 | P1 | tile_deco_rubble |

### 第 1 层（墓穴）

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 石砖地面 | `map-tile` | 16×16, 变体 ×3 | P0 | tile_floor_stone_0x |
| 石砖墙壁 | `map-tile` | 16×16, 上下左右 | P0 | tile_wall_stone_* |
| 陷阱地砖（关闭） | `map-tile` | 16×16 | P1 | tile_trap_off |
| 陷阱地砖（激活） | `map-tile` | 16×16, 2 帧 | P1 | tile_trap_on_0x |
| 魂灯（存档点） | `map-tile` | 16×32, 点亮/熄灭 | P0 | tile_save_lamp_* |
| 层门 | `map-tile` | 32×32 | P1 | tile_gate_floor |
| 装饰·骨堆 | `map-tile` | 16×16 | P2 | tile_deco_bones |
| 装饰·烛台 | `map-tile` | 16×16 | P2 | tile_deco_candle |

---

## UI 元素

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 对话框背景 | `ui` | 拉伸 9-patch | P0 | ui_dialog_bg |
| 对话框指示箭头 | `ui` | 16×16 | P1 | ui_dialog_arrow |
| 战斗菜单背景 | `ui` | 拉伸 9-patch | P0 | ui_combat_menu_bg |
| 按钮·正常态 | `ui` | 64×24 或拉伸 | P0 | ui_btn_normal |
| 按钮·按下态 | `ui` | 同上 | P0 | ui_btn_pressed |
| HP 槽框 | `ui` | 拉伸 | P0 | ui_bar_hp_frame |
| HP 槽填充 | `ui` | 拉伸 | P0 | ui_bar_hp_fill |
| 失控槽框 | `ui` | 拉伸 | P1 | ui_bar_overload_frame |
| 失控槽填充 | `ui` | 拉伸 | P1 | ui_bar_overload_fill |
| 认可图标 | `ui` | 24×24 | P0 | ui_icon_recognition |

---

## 特效

| 资源 | 类型 | 规格 | 优先级 | 备注 |
|------|------|------|--------|------|
| 异能共鸣（Deep Echo）特效 | `fx` | 32×32, 6 帧 | P0 | fx_deep_echo_* |
| 普通攻击特效 | `fx` | 32×32, 4 帧 | P1 | fx_attack_slash_* |
| 受伤闪烁 | `fx` | shader/精灵 | P0 | fx_hurt_flash |
| 失控警告 | `fx` | 屏幕边缘红晕 | P1 | fx_overload_warning |

---

## 音效占位（M1 不强制）

| 资源 | 类型 | 优先级 | 备注 |
|------|------|--------|------|
| 脚步声 | SFX | P2 | sfx_footstep |
| 攻击命中 | SFX | P1 | sfx_hit |
| 异能释放 | SFX | P1 | sfx_deep_echo |
| 魂灯存档 | SFX | P2 | sfx_save |

---

## 统计

| 类型 | P0 | P1 | P2 | 合计 |
|------|----|----|----|----|
| map-sprite | 4 | 3 | 0 | 7 |
| map-tile | 8 | 5 | 3 | 16 |
| portrait | 1 | 2 | 3 | 6 |
| ui | 7 | 3 | 0 | 10 |
| fx | 2 | 2 | 0 | 4 |
| **合计** | **22** | **15** | **6** | **43** |

---

## 注意事项

1. **无 3D mesh**：本清单所有资源均为 2D 像素/立绘，不含 3D 建模任务。
2. **map-sprite vs portrait**：地图精灵用于游戏内探索/战斗；立绘仅用于对话系统，二者分开制作。
3. **命名规范**：遵循 [naming-and-import.md](naming-and-import.md)。
4. **导入设置**：所有像素资源 Filter OFF, Mipmaps OFF。
5. **占位优先**：P0 可先用色块占位验证，美术资源逐步替换。

---

## 文档关联

- [perspective-and-pipeline.md](perspective-and-pipeline.md) — 视角与管线
- [palette-lock.md](palette-lock.md) — 美术方向锁定
- [naming-and-import.md](naming-and-import.md) — 命名与导入规范
- [../GDD-v1.1.md](../GDD-v1.1.md) § 7.3 M1 验收
