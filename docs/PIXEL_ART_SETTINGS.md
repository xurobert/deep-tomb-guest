# 像素美术导入设置

本文档描述了《墓穴访客》中像素美术素材所需的导入设置。

## 全局设置（已配置）

`project.godot` 文件包含以下配置：
```
[rendering]
textures/canvas_textures/default_texture_filter=0
```

这将默认贴图滤镜设置为 **最近邻（Nearest）**（无滤波），这对于清晰的像素美术效果至关重要。

## 单素材导入设置

导入新的像素美术贴图时，请确保在导入面板中使用以下设置：

### 贴图 (.png, .jpg)
- **滤镜 (Filter)**：关闭（Nearest 最近邻）
- **Mipmaps**：关闭（Generate Mipmaps = false）
- **重复 (Repeat)**：禁用（除非是平铺贴图）

### 配置方法

1. 在文件系统中选择贴图
2. 进入「导入」选项卡
3. 设置：
   - Compress > Mode：Lossless（无损）
   - Flags > Filter：关闭
   - Flags > Mipmaps：关闭
4. 点击「重新导入」

### 创建预设（推荐）

创建可复用的预设：
1. 按上述方式配置一个贴图
2. 在导入面板中点击「预设」下拉菜单
3. 选择「另存为当前设置...」
4. 命名为「Pixel Art」

## 素材规格

| 素材类型 | 画布尺寸 | 备注 |
|----------|----------|------|
| 地砖 | 32×32 px | 边缘无缝以便平铺 |
| 角色 | 64×64 px | 居中，为动画预留空间 |
| UI 元素 | 可变 | 使用 8px 的倍数 |
| 特效/FX | 64×64 px | 匹配角色比例 |

> **2026-09-10 更新**：画布尺寸已从 16/32 升级到 32/64，硬像素边缘，有限调色板。  
> 管线：Grok → nearest-neighbor 缩放至目标画布 + posterize → 一致性检查 → 入仓

## 命名规范

```
subject_state_dir_frame.png
```

示例：
- `hero_idle_s_00.png` - 主角，待机动画，朝南，第 0 帧
- `hero_walk_e_02.png` - 主角，行走，朝东，第 2 帧
- `tile_floor_stone_00.png` - 地板砖，石质变体
- `ui_btn_attack_normal.png` - UI 按钮，攻击，正常状态

### 方向代码
- `n` = 北（上）
- `s` = 南（下）
- `e` = 东（右）
- `w` = 西（左）
