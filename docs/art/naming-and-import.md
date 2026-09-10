# 命名与导入规范

> 状态：**已锁定**  
> 锁定日期：2026-09-10

本文档定义美术资源的文件命名规则、目录结构与 Godot 导入设置。

---

## 目录结构

```
assets/
├── art/
│   ├── characters/          # 地图角色精灵 (map-sprite)
│   │   ├── hero/            # 主角
│   │   ├── enemies/         # 敌人
│   │   └── npc/             # NPC
│   ├── portraits/           # 立绘 (portrait) ← 独立于 characters
│   │   ├── hero/            # 主角立绘
│   │   ├── enemies/         # 敌人/BOSS 立绘（如有）
│   │   └── npc/             # NPC 立绘
│   ├── tiles/               # 地图瓦片 (map-tile)
│   │   ├── floor/           # 地面
│   │   ├── wall/            # 墙壁
│   │   ├── deco/            # 装饰物
│   │   └── interactive/     # 可交互物（门、陷阱、魂灯）
│   ├── ui/                  # 用户界面元素
│   │   ├── dialog/          # 对话框相关
│   │   ├── combat/          # 战斗 UI
│   │   ├── hud/             # HUD 元素
│   │   └── icons/           # 图标
│   └── fx/                  # 特效
│       ├── skills/          # 技能特效
│       └── status/          # 状态特效
└── audio/                   # 音频（另行规范）
```

### 关键区分：characters vs portraits

| 目录 | 用途 | 分辨率 | 风格 |
|------|------|--------|------|
| `art/characters/` | 地图精灵，探索/战斗场景 | 32×32 px | 像素美术 |
| `art/portraits/` | 对话立绘，UI 叠加显示 | 512+ px | 日系立绘 |

两者**必须分开存放**，便于管理和批量导入设置。

---

## 命名规范

### 通用格式

```
<类型前缀>_<主体>_<状态>_<方向>_<帧号>.png
```

各部分说明：

| 部分 | 说明 | 示例 |
|------|------|------|
| 类型前缀 | 资源类型 | `hero`, `enemy`, `tile`, `ui`, `fx`, `portrait` |
| 主体 | 具体对象 | `tomb_shade`, `floor_stone`, `btn_attack` |
| 状态 | 动作/状态 | `idle`, `walk`, `attack`, `hurt`, `default`, `angry` |
| 方向 | 朝向（地图精灵用） | `n`, `s`, `e`, `w` |
| 帧号 | 动画帧序号 | `00`, `01`, `02`... |

### 地图精灵 (map-sprite)

```
hero_idle_s_00.png          # 主角待机，朝南，第 0 帧
hero_walk_e_02.png          # 主角行走，朝东，第 2 帧
enemy_tomb_shade_attack_00.png  # 墓影攻击动作第 0 帧
enemy_bone_guard_idle_s_00.png  # 骨卫待机朝南
```

方向代码：
- `n` = 北（上）
- `s` = 南（下）
- `e` = 东（右）
- `w` = 西（左）

### 立绘 (portrait)

```
portrait_hero_default.png       # 主角默认表情
portrait_hero_surprised.png     # 主角惊讶
portrait_hero_determined.png    # 主角坚定
portrait_guardian_proto_default.png     # 半成品守护者默认
portrait_guardian_proto_menacing.png    # 半成品守护者威压
```

立绘不需要方向和帧号（除非有眨眼等微动画）。

### 地图瓦片 (map-tile)

```
tile_floor_stone_00.png     # 石砖地面变体 0
tile_floor_stone_01.png     # 石砖地面变体 1
tile_wall_stone_n.png       # 石墙北侧
tile_wall_stone_corner_ne.png  # 石墙东北角
tile_deco_bones.png         # 装饰：骨堆
tile_save_lamp_on.png       # 魂灯（点亮）
tile_save_lamp_off.png      # 魂灯（熄灭）
tile_trap_off.png           # 陷阱（关闭）
tile_trap_on_00.png         # 陷阱（激活）帧 0
```

### UI 元素

```
ui_dialog_bg.png            # 对话框背景
ui_dialog_arrow.png         # 对话框指示箭头
ui_btn_attack_normal.png    # 攻击按钮正常态
ui_btn_attack_pressed.png   # 攻击按钮按下态
ui_bar_hp_frame.png         # HP 槽框
ui_bar_hp_fill.png          # HP 槽填充
ui_icon_recognition.png     # 认可图标
```

### 特效

```
fx_deep_echo_00.png         # 异能共鸣特效帧 0
fx_deep_echo_05.png         # 异能共鸣特效帧 5
fx_attack_slash_00.png      # 普通攻击斩击帧 0
```

---

## Godot 导入设置

### 像素资源（map-sprite, map-tile, ui, fx）

| 设置项 | 值 |
|--------|-----|
| Filter | **OFF** (Nearest) |
| Mipmaps | **OFF** (Generate Mipmaps = false) |
| Repeat | Disabled（除非需平铺） |
| Compress Mode | Lossless |

### 立绘 (portrait)

默认设置同上（Nearest, no mipmaps），保持像素锐利。

如果立绘分辨率非常高且需要平滑缩放，可单独设置：
- Filter: Linear
- Mipmaps: ON

但建议优先保持统一设置，避免视觉风格不一致。

### 批量设置预设

1. 按上述设置配置一个纹理
2. 在 Import dock 点击「Preset」下拉菜单
3. 选择「Save Current as...」
4. 命名为「Pixel Art」
5. 后续导入时选择此预设

---

## 导入检查清单

- [ ] 文件名符合命名规范
- [ ] 放入正确的目录（characters / portraits / tiles / ui / fx）
- [ ] 分辨率符合规格（瓦片 16×16，精灵 32×32，立绘 512+）
- [ ] Filter 设置为 OFF
- [ ] Mipmaps 设置为 OFF
- [ ] 点击「Reimport」生效

---

## 🔒 概念图 / AI 生成图使用规范

| 类型 | 允许位置 | 说明 |
|------|----------|------|
| 概念图 / Grok 生成图 | `docs/art/ref/` | 仅作参考，标注「非进仓」|
| 最终像素资产 | `assets/` | 仅限手绘/手修像素图 |

**严禁**：将 AI 生成图、概念草图直接提交至 `assets/` 目录作为最终游戏资产。

参考图须存放于 `docs/art/ref/` 目录下，并在文件名或引用处标注「非进仓」。

---

## 文档关联

- [animation-frames.md](animation-frames.md) — VS 帧动画规范（帧表、SpriteFrames 配置）
- [perspective-and-pipeline.md](perspective-and-pipeline.md) — 视角与管线
- [palette-lock.md](palette-lock.md) — 美术方向锁定
- [m1-shot-list.md](m1-shot-list.md) — M1 资源清单
- [../PIXEL_ART_SETTINGS.md](../PIXEL_ART_SETTINGS.md) — Godot 像素美术设置详解
