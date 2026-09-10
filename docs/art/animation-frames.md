# VS 帧动画规范

> 状态：**已锁定**  
> 锁定日期：2026-09-10  
> 适用范围：垂直切片（Vertical Slice）

本文档定义垂直切片阶段所有地图精灵的帧动画规格。

---

## 核心约束

### 🔒 动画技术锁定

| 决策项 | 锁定值 |
|--------|--------|
| 动画方式 | **Godot SpriteFrames 逐帧动画** |
| 禁止方案 | 骨骼绑定（Spine / DragonBones / Godot Skeleton2D）|
| 适用范围 | VS 阶段所有地图精灵 |

**原因**：逐帧动画与 64×64 像素风格一致，简化资产管线，保持复古像素手感。

### 🔒 概念图 / AI 生成图使用规范

| 类型 | 允许位置 | 说明 |
|------|----------|------|
| 概念图 / Grok 生成图 | `docs/art/ref/` | 仅作参考，标注「非进仓」|
| 最终像素资产 | `assets/` | 仅限手绘/手修像素图 |

**严禁**：将 AI 生成图、概念草图直接提交至 `assets/` 目录作为最终游戏资产。

---

## 通用规格

### 锚点与对齐

> **2026-09-10 更新**：画布尺寸已升级为 64×64

| 属性 | 值 |
|------|-----|
| 画布尺寸 | 64×64 像素 |
| 锚点位置 | **底部中心（脚底）** |
| 锚点坐标 | (32, 64) |
| 对齐方式 | 所有状态保持同一锚点 |

**说明**：统一锚点确保状态切换（待机→行走→攻击）时角色位置不跳动。

### 方向代码

| 代码 | 方向 | 朝向 |
|------|------|------|
| `n` | 北 | 背对镜头（上） |
| `s` | 南 | 面朝镜头（下） |
| `e` | 东 | 右侧 |
| `w` | 西 | 左侧 |

---

## 帧表：玩家地图精灵 (Player Map Sprite)

### 规格总览

| 状态 | 尺寸 | 帧数 | 帧率 | 播放模式 | 方向数 | 总帧数 |
|------|------|------|------|----------|--------|--------|
| 待机 (idle) | 64×64 | 4 | 6 fps | 循环 | 4 | 16 |
| 行走 (walk) | 64×64 | 6–8 | 10 fps | 循环 | 4 | 24–32 |
| 攻击 (attack) | 64×64 | 4–6 | 12 fps | 单次 | 4 | 16–24 |
| 受击 (hit) | 64×64 | 2 | 8 fps | 单次 | 1* | 2 |

*受击状态可省略方向，复用南向或当前朝向。

### 待机 (idle) 详细帧表

| 帧序号 | 文件名示例 | 描述 |
|--------|------------|------|
| 0 | `hero_idle_s_00.png` | 基础站姿 |
| 1 | `hero_idle_s_01.png` | 轻微呼吸上抬 |
| 2 | `hero_idle_s_02.png` | 基础站姿复位 |
| 3 | `hero_idle_s_03.png` | 轻微下沉 |

重复以上4方向：`_s_`, `_n_`, `_e_`, `_w_`

### 行走 (walk) 详细帧表

| 帧序号 | 文件名示例 | 描述 |
|--------|------------|------|
| 0 | `hero_walk_s_00.png` | 接触位（右脚前） |
| 1 | `hero_walk_s_01.png` | 重心转移 |
| 2 | `hero_walk_s_02.png` | 过渡 |
| 3 | `hero_walk_s_03.png` | 接触位（左脚前） |
| 4 | `hero_walk_s_04.png` | 重心转移 |
| 5 | `hero_walk_s_05.png` | 过渡（可选至第 7 帧） |

重复以上4方向：`_s_`, `_n_`, `_e_`, `_w_`

### 攻击 (attack) 详细帧表

| 帧序号 | 文件名示例 | 描述 |
|--------|------------|------|
| 0 | `hero_attack_s_00.png` | 预备/蓄力 |
| 1 | `hero_attack_s_01.png` | 挥击中 |
| 2 | `hero_attack_s_02.png` | 击中点（命中帧） |
| 3 | `hero_attack_s_03.png` | 收招 |
| 4–5 | `hero_attack_s_04.png` | 可选：延长收招 |

重复以上4方向：`_s_`, `_n_`, `_e_`, `_w_`

### 受击 (hit) 详细帧表

| 帧序号 | 文件名示例 | 描述 |
|--------|------------|------|
| 0 | `hero_hit_00.png` | 受击闪烁/后仰 |
| 1 | `hero_hit_01.png` | 恢复站姿 |

---

## 帧表：骷髅守卫 (Skeleton Guard)

### 规格总览

| 状态 | 尺寸 | 帧数 | 帧率 | 播放模式 | 说明 |
|------|------|------|------|----------|------|
| 待机 (idle) | 64×64 | 2 | 4 fps | 循环 | 最小化，微动 |
| 攻击 (attack) | 64×64 | 3 | 10 fps | 单次 | 简化挥砍 |

### 待机 (idle) 详细帧表

| 帧序号 | 文件名示例 | 描述 |
|--------|------------|------|
| 0 | `enemy_skeleton_guard_idle_s_00.png` | 基础站姿 |
| 1 | `enemy_skeleton_guard_idle_s_01.png` | 轻微摇晃 |

### 攻击 (attack) 详细帧表

| 帧序号 | 文件名示例 | 描述 |
|--------|------------|------|
| 0 | `enemy_skeleton_guard_attack_s_00.png` | 举剑 |
| 1 | `enemy_skeleton_guard_attack_s_01.png` | 劈砍（命中帧） |
| 2 | `enemy_skeleton_guard_attack_s_02.png` | 收招 |

---

## 文件命名规范

### 格式

```
<主体>_<状态>_<方向>_<帧号>.png
```

### 示例

| 文件名 | 说明 |
|--------|------|
| `hero_idle_s_00.png` | 主角待机，朝南，第 0 帧 |
| `hero_walk_e_03.png` | 主角行走，朝东，第 3 帧 |
| `hero_attack_n_02.png` | 主角攻击，朝北，第 2 帧 |
| `hero_hit_00.png` | 主角受击第 0 帧（省略方向） |
| `enemy_skeleton_guard_idle_s_00.png` | 骷髅守卫待机 |

---

## Godot SpriteFrames 配置

### 创建 SpriteFrames 资源

1. 在 FileSystem 面板右键 → New Resource → SpriteFrames
2. 保存为 `hero_frames.tres`（或对应角色名）

### 添加动画

| 动画名 | 帧列表 | FPS | 循环 |
|--------|--------|-----|------|
| `idle_s` | hero_idle_s_00 ~ 03 | 6 | ✓ |
| `idle_n` | hero_idle_n_00 ~ 03 | 6 | ✓ |
| `walk_s` | hero_walk_s_00 ~ 05 | 10 | ✓ |
| `walk_e` | hero_walk_e_00 ~ 05 | 10 | ✓ |
| `attack_s` | hero_attack_s_00 ~ 03 | 12 | ✗ |
| `hit` | hero_hit_00 ~ 01 | 8 | ✗ |

### AnimatedSprite2D 节点设置

```gdscript
# 切换动画示例
$AnimatedSprite2D.play("walk_s")

# 攻击完成后回到待机
func _on_animated_sprite_2d_animation_finished():
    if animation.begins_with("attack"):
        play("idle_" + current_direction)
```

---

## 参考图存放规范

### 允许存放位置

```
docs/art/ref/
├── concept/           # 概念草图
├── grok/              # Grok/AI 生成参考图
└── external/          # 外部参考（需注明来源）
```

### 命名要求

所有参考图文件名须包含 `_ref` 后缀或存放于 `ref/` 目录下：

```
hero_concept_ref.png          # 主角概念图（非进仓）
skeleton_grok_ref_01.png      # AI 生成参考（非进仓）
```

### 标注要求

在引用参考图的文档中须注明：

```markdown
> ⚠️ 以下图片仅供参考，非最终游戏资产（非进仓）
```

---

## 文档关联

- [naming-and-import.md](naming-and-import.md) — 命名规范与 Godot 导入设置
- [prompt-sheet-vs-ch0.md](prompt-sheet-vs-ch0.md) — VS 提示词模板
- [palette-lock.md](palette-lock.md) — 调色板锁定
- [m1-shot-list.md](m1-shot-list.md) — M1 资源清单
