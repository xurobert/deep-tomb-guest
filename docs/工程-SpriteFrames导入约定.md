# 工程：SpriteFrames 导入约定

> 版本：v1.0  
> 日期：2026-09-10  
> 状态：工程规范文档  
> 对照文档：art/animation-frames.md、art/naming-and-import.md

---

## 一、概述

本文档定义《深墓来客》美术资源的工程导入流程，包括：
- 文件夹布局与命名规范
- Godot 导入设置
- SpriteFrames 资源创建步骤
- AnimatedSprite2D 节点绑定方法
- 概念图与最终资产的区分

---

## 二、文件夹布局

### assets/art/characters/ 结构

```
assets/
└── art/
    └── characters/
        ├── hero/                    # 主角
        │   ├── hero_idle_s_00.png
        │   ├── hero_idle_s_01.png
        │   ├── hero_idle_s_02.png
        │   ├── hero_idle_s_03.png
        │   ├── hero_idle_n_00.png
        │   │   ... (每方向 4 帧)
        │   ├── hero_walk_s_00.png
        │   │   ... (每方向 6-8 帧)
        │   ├── hero_attack_s_00.png
        │   │   ... (每方向 4-6 帧)
        │   ├── hero_hit_00.png
        │   ├── hero_hit_01.png
        │   └── hero_frames.tres      # SpriteFrames 资源
        │
        ├── enemies/                  # 敌人
        │   ├── skeleton_guard/
        │   │   ├── enemy_skeleton_guard_idle_s_00.png
        │   │   ├── enemy_skeleton_guard_idle_s_01.png
        │   │   ├── enemy_skeleton_guard_attack_s_00.png
        │   │   ├── enemy_skeleton_guard_attack_s_01.png
        │   │   ├── enemy_skeleton_guard_attack_s_02.png
        │   │   └── skeleton_guard_frames.tres
        │   │
        │   └── tomb_shade/
        │       ├── enemy_tomb_shade_idle_00.png
        │       └── tomb_shade_frames.tres
        │
        └── npc/                      # NPC
            └── (待补充)
```

### 目录职责

> **2026-09-10 更新**：画布尺寸已升级（~~旧 16/32~~ → **新 32/64**）

| 目录 | 内容 | 尺寸 |
|------|------|------|
| `characters/hero/` | 主角地图精灵 | **64×64 px**（~~旧 32×32~~） |
| `characters/enemies/` | 敌人地图精灵 | **64×64 px**（~~旧 32×32~~） |
| `characters/npc/` | NPC 地图精灵 | **64×64 px**（~~旧 32×32~~） |
| `portraits/` | 立绘（独立目录） | 512+ px |
| `tiles/` | 地图瓦片 | **32×32 px**（~~旧 16×16~~） |
| `ui/` | 界面元素 | 可变 |
| `fx/` | 特效 | **64×64 px**（~~旧 32×32~~） |

---

## 三、文件命名规范

### 命名格式

```
<主体>_<状态>_<方向>_<帧号>.png
```

### 各部分说明

| 部分 | 说明 | 示例 |
|------|------|------|
| 主体 | 角色/物体标识 | `hero`, `enemy_skeleton_guard`, `tile_floor` |
| 状态 | 动作/状态名 | `idle`, `walk`, `attack`, `hit` |
| 方向 | 朝向代码 | `n`, `s`, `e`, `w`（北上南下东右西左） |
| 帧号 | 两位数序号 | `00`, `01`, `02`... |

### 方向代码

| 代码 | 方向 | 朝向说明 |
|------|------|----------|
| `n` | 北 | 背对镜头（上） |
| `s` | 南 | 面朝镜头（下） |
| `e` | 东 | 右侧 |
| `w` | 西 | 左侧 |

### 命名示例

```
hero_idle_s_00.png       # 主角待机，朝南，第 0 帧
hero_walk_e_03.png       # 主角行走，朝东，第 3 帧
hero_attack_n_02.png     # 主角攻击，朝北，第 2 帧
hero_hit_00.png          # 主角受击第 0 帧（省略方向）
enemy_skeleton_guard_idle_s_00.png   # 骷髅守卫待机
```

---

## 四、帧动画规格对照表

### 玩家地图精灵 (Player Map Sprite)

| 状态 | 尺寸 | 帧数 | 帧率 | 播放模式 | 方向数 | 总帧数 |
|------|------|------|------|----------|--------|--------|
| 待机 (idle) | **64×64** | 4 | 6 fps | 循环 | 4 | 16 |
| 行走 (walk) | **64×64** | 6–8 | 10 fps | 循环 | 4 | 24–32 |
| 攻击 (attack) | **64×64** | 4–6 | 12 fps | 单次 | 4 | 16–24 |
| 受击 (hit) | **64×64** | 2 | 8 fps | 单次 | 1* | 2 |

*受击状态可省略方向，复用南向或当前朝向。

### 骷髅守卫 (Skeleton Guard)

| 状态 | 尺寸 | 帧数 | 帧率 | 播放模式 | 说明 |
|------|------|------|------|----------|------|
| 待机 (idle) | **64×64** | 2 | 4 fps | 循环 | 最小化，微动 |
| 攻击 (attack) | **64×64** | 3 | 10 fps | 单次 | 简化挥砍 |

### 锚点规范

| 属性 | 值 |
|------|-----|
| 画布尺寸 | **64×64 像素**（~~旧 32×32~~） |
| 锚点位置 | **底部中心（脚底）** |
| 锚点坐标 | **(32, 64)**（~~旧 16, 32~~） |
| 对齐方式 | 所有状态保持同一锚点 |

---

## 五、Godot 导入设置

### 像素资源导入配置

| 设置项 | 值 | 说明 |
|--------|-----|------|
| Filter | **OFF** (Nearest) | 关闭双线性过滤，保持像素锐利 |
| Mipmaps | **OFF** (false) | 禁用 Mipmap 生成 |
| Repeat | Disabled | 除平铺瓦片外禁用重复 |
| Compress Mode | Lossless | 无损压缩 |

### 导入步骤

1. **导入贴图文件**
   - 将 PNG 文件拖入 `assets/art/characters/` 相应目录
   - Godot 自动检测并导入

2. **配置导入设置**
   - 在 FileSystem 面板选中贴图文件
   - 切换到 Import 选项卡
   - 设置：
     - Compress > Mode: **Lossless**
     - Flags > Filter: **OFF**
     - Flags > Mipmaps: **OFF**
   - 点击 **Reimport**

3. **创建预设（推荐）**
   - 按上述配置一个文件后
   - 在 Import dock 点击「Preset」下拉菜单
   - 选择「Save Current as...」
   - 命名为「Pixel Art」
   - 后续导入选择此预设

### 批量导入

对于多个文件，可选中后统一设置：
1. Shift+点击选中多个贴图
2. Import 面板显示共同设置
3. 应用相同配置
4. 点击「Reimport」

---

## 六、SpriteFrames 资源创建

### 创建步骤

1. **新建资源**
   - 在 FileSystem 目标目录右键
   - New Resource → 搜索 "SpriteFrames"
   - 保存为 `<角色名>_frames.tres`（如 `hero_frames.tres`）

2. **打开编辑器**
   - 双击 `.tres` 文件
   - 在底部面板打开 SpriteFrames 编辑器

3. **添加动画**
   - 点击 "Add Animation" 按钮
   - 命名为 `<状态>_<方向>`（如 `idle_s`）

4. **添加帧**
   - 选中动画名
   - 从 FileSystem 拖拽帧文件到帧列表
   - 确保帧顺序正确

5. **配置动画属性**
   - **FPS**：设置播放速度（见帧动画规格表）
   - **Loop**：循环动画勾选，单次动画取消

### 动画命名规范

| 动画名 | 帧列表示例 | FPS | 循环 |
|--------|-----------|-----|------|
| `idle_s` | hero_idle_s_00 ~ 03 | 6 | ✓ |
| `idle_n` | hero_idle_n_00 ~ 03 | 6 | ✓ |
| `idle_e` | hero_idle_e_00 ~ 03 | 6 | ✓ |
| `idle_w` | hero_idle_w_00 ~ 03 | 6 | ✓ |
| `walk_s` | hero_walk_s_00 ~ 05 | 10 | ✓ |
| `walk_n` | hero_walk_n_00 ~ 05 | 10 | ✓ |
| `walk_e` | hero_walk_e_00 ~ 05 | 10 | ✓ |
| `walk_w` | hero_walk_w_00 ~ 05 | 10 | ✓ |
| `attack_s` | hero_attack_s_00 ~ 03 | 12 | ✗ |
| `attack_n` | hero_attack_n_00 ~ 03 | 12 | ✗ |
| `attack_e` | hero_attack_e_00 ~ 03 | 12 | ✗ |
| `attack_w` | hero_attack_w_00 ~ 03 | 12 | ✗ |
| `hit` | hero_hit_00 ~ 01 | 8 | ✗ |

---

## 七、AnimatedSprite2D 节点绑定

### 场景结构

```
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
└── (其他子节点)
```

### 节点配置

1. **添加 AnimatedSprite2D**
   - 在角色场景根节点下添加 AnimatedSprite2D 节点

2. **绑定 SpriteFrames**
   - 选中 AnimatedSprite2D 节点
   - 在 Inspector 中将 `Sprite Frames` 属性设为对应的 `.tres` 资源
   - 或拖拽 `hero_frames.tres` 到该属性

3. **设置初始动画**
   - Animation: `idle_s`（默认朝向）
   - Autoplay: 可选勾选

### 脚本控制示例

```gdscript
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var current_direction: String = "s"
var is_moving: bool = false

func _physics_process(delta: float) -> void:
    var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    if input != Vector2.ZERO:
        is_moving = true
        current_direction = _get_direction_code(input)
        velocity = input * move_speed
    else:
        is_moving = false
        velocity = Vector2.ZERO
    
    move_and_slide()
    _update_animation()

func _get_direction_code(input: Vector2) -> String:
    if abs(input.y) > abs(input.x):
        return "n" if input.y < 0 else "s"
    else:
        return "w" if input.x < 0 else "e"

func _update_animation() -> void:
    var anim_name: String
    if is_moving:
        anim_name = "walk_" + current_direction
    else:
        anim_name = "idle_" + current_direction
    
    if anim.animation != anim_name:
        anim.play(anim_name)

func play_attack() -> void:
    anim.play("attack_" + current_direction)
    await anim.animation_finished
    _update_animation()

func play_hit() -> void:
    anim.play("hit")
    await anim.animation_finished
    _update_animation()
```

### 动画信号

```gdscript
func _ready() -> void:
    anim.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
    # 单次动画完成后回到待机
    if anim.animation.begins_with("attack") or anim.animation == "hit":
        _update_animation()
```

---

## 八、概念图使用规范

### 🔒 严禁行为

| 行为 | 状态 |
|------|------|
| 将 AI 生成图直接放入 `assets/` | ❌ 禁止 |
| 将概念草图作为最终资产 | ❌ 禁止 |
| 将 Grok 生成图进仓 | ❌ 禁止 |

### ✅ 允许行为

| 行为 | 位置 |
|------|------|
| 概念图作为参考 | `docs/art/ref/` |
| AI 生成图作为灵感 | `docs/art/ref/grok/` |
| 外部参考图（标注来源） | `docs/art/ref/external/` |

### 参考图命名

```
docs/art/ref/
├── concept/
│   └── hero_concept_ref.png
├── grok/
│   └── skeleton_grok_ref_01.png
└── external/
    └── style_ref_darksouls.png  # 需标注来源
```

### 文档标注

在引用参考图时须添加声明：

```markdown
> ⚠️ 以下图片仅供参考，非最终游戏资产（非进仓）
```

---

## 九、导入检查清单

新资产导入时逐项确认：

- [ ] 文件名符合 `<主体>_<状态>_<方向>_<帧号>.png` 规范
- [ ] 放入正确目录（`characters/hero/`、`characters/enemies/` 等）
- [ ] 分辨率符合规格（**角色 64×64，瓦片 32×32**）
- [ ] 锚点位于底部中心 **(32, 64)**
- [ ] Filter 设置为 **OFF**
- [ ] Mipmaps 设置为 **OFF**
- [ ] 点击 **Reimport** 使设置生效
- [ ] 创建/更新对应的 SpriteFrames 资源
- [ ] 动画命名符合 `<状态>_<方向>` 规范
- [ ] 循环/单次设置正确

---

## 十、VS 范围资产清单

垂直切片需要的最小资产：

### 必需资产

| 角色 | 状态 | 方向 | 帧数 | 优先级 |
|------|------|------|------|--------|
| hero | idle | s, n, e, w | 4×4=16 | P0 |
| hero | walk | s, n, e, w | 6×4=24 | P0 |
| hero | attack | s | 4 | P0 |
| hero | hit | — | 2 | P0 |
| skeleton_guard | idle | s | 2 | P0 |
| skeleton_guard | attack | s | 3 | P0 |

### 可用占位

当前使用彩色方块占位，替换时确保：
- 尺寸一致（**64×64**）
- 锚点一致（底部中心 32, 64）
- 命名符合规范

---

## 十一、文档关联

- [art/animation-frames.md](art/animation-frames.md) — 帧动画详细规范
- [art/naming-and-import.md](art/naming-and-import.md) — 命名与导入规范
- [PIXEL_ART_SETTINGS.md](PIXEL_ART_SETTINGS.md) — Godot 像素美术设置
- [art/prompt-sheet-vs-ch0.md](art/prompt-sheet-vs-ch0.md) — VS 提示词模板
- [工程-章节点与flag存档键.md](工程-章节点与flag存档键.md) — 存档键规范

---

## 十二、备注

1. 本文档与 art/animation-frames.md 内容有重叠，本文侧重工程导入流程
2. 所有动画使用 SpriteFrames 逐帧方式，禁止骨骼绑定
3. 最终资产须为手绘/手修像素图，AI 生成图仅供参考
4. 与美术文档如有冲突，以 art/ 目录下文档为准
