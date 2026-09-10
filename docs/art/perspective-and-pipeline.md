# 视角与管线规范

> 状态：**已锁定**  
> 锁定日期：2026-09-10

## 视角锁定：2.5D 俯视箱庭

本项目采用 **2.5D 俯视箱庭** 视角，**不做 3D 或全 3D 渲染**。

| 项目 | 规范 |
|------|------|
| 探索视角 | 2.5D 俯视（top-down / orthographic feel） |
| 战斗视角 | 同上，回合制指令菜单覆盖探索画面 |
| 对话视角 | 日系立绘（portrait）叠加显示在下层 UI 上 |
| 禁止项 | 3D 建模、透视摄像机、自由视角旋转 |

### 核心原则

1. **正交/俯视感**：摄像机模拟正交投影，无透视缩放。
2. **像素整格对齐**：所有移动、瓦片、精灵边缘对齐整数像素网格。
3. **箱庭探索 + 立绘对话**：地图为像素美术，对话系统使用独立的高分辨率日系立绘。

---

## 资源尺寸规格

> **2026-09-10 更新**：画布尺寸已升级（~~旧 16/32~~ → **新 32/64**）

| 资源类型 | 尺寸 | 说明 |
|----------|------|------|
| 地图瓦片 (map-tile) | 32×32 px | 整格拼接，无缝边缘 |
| 地图角色精灵 (map-sprite) | 64×64 px | 探索/战斗场景中显示 |
| 立绘 (portrait) | 独立高分辨率 | 对话 UI 叠加显示，与地图精灵分离 |
| UI 元素 | 8px 倍数 | 按钮、面板等 |
| 特效 (fx) | 视情况 | 匹配瓦片或角色尺度 |

### 立绘与地图精灵的区别

| 维度 | 地图精灵 (map-sprite) | 立绘 (portrait) |
|------|----------------------|-----------------|
| 用途 | 探索地图、战斗场景中的角色/敌人 | 对话系统中的角色表情立绘 |
| 分辨率 | 低（64×64 px） | 高（512+ px，或按需） |
| 风格 | 像素美术 | 日系立绘风格 |
| 数量 | 每角色 1 套动作帧 | 每角色多种表情差分 |
| 导入设置 | Filter OFF, Mipmaps OFF | 同上（除非需抗锯齿） |

---

## 美术管线

### 1. 地图精灵工作流

```
概念草图 → 像素稿 → 动画帧 → 导出 PNG → Godot 导入
```

- 格式：PNG（无损）
- 命名：`subject_state_dir_frame.png`（详见 naming-and-import.md）
- 工具建议：Aseprite / Pixelorama / Photoshop 像素模式

### 2. 立绘工作流

```
角色设定 → 线稿 → 上色 → 表情差分 → 导出 PNG → Godot 导入
```

- 格式：PNG（带 Alpha 透明）
- 命名：`portrait_<角色id>_<表情>.png`
- 工具建议：Clip Studio Paint / Photoshop / Procreate

### 3. Godot 导入设置（所有像素资源）

| 设置项 | 值 |
|--------|-----|
| Filter | OFF (Nearest) |
| Mipmaps | OFF (Generate Mipmaps = false) |
| Repeat | Disabled（除非需平铺） |
| Compress Mode | Lossless |

立绘如需抗锯齿可单独开启 Linear Filter，但默认仍建议 Nearest 以保持像素整格对齐的视觉统一。

---

## 相机设置

```gdscript
# 正交俯视相机配置示例
camera.projection = Camera2D.PROJECTION_ORTHOGONAL  # Godot 4 默认即正交
camera.position_smoothing_enabled = false  # 或微小值，避免子像素抖动
```

- 缩放倍数建议为整数（1x, 2x, 3x...）以避免像素模糊。
- 移动单位对齐 32px 瓦片网格或 64px 角色格。

---

## 禁止事项

- ❌ 3D 网格建模（mesh）
- ❌ 透视摄像机
- ❌ 自由视角旋转
- ❌ 非整数缩放导致的像素模糊
- ❌ 混用不同像素密度的资源（如精灵与瓦片比例不匹配）

---

## 参考

- GDD v1.1 § 6 美术接口
- docs/PIXEL_ART_SETTINGS.md
- docs/art/naming-and-import.md
