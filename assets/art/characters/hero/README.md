# 主角地图精灵 (Hero Map Sprites)

> 状态：**用户已过审**  
> 日期：2026-09-11

## 来源

- 生成：Grok
- 后处理：最近邻缩放至 64×64 + 色板量化
- 审核：用户在聊天中确认通过

## 动画帧清单

### 待机 (idle)

| 方向 | 帧数 | 文件 |
|------|------|------|
| 南 (s) | 1 | `hero_idle_s_00.png` |
| 北 (n) | 1 | `hero_idle_n_00.png` |
| 东 (e) | 1 | `hero_idle_e_00.png` |
| 西 (w) | 1 | `hero_idle_w_00.png` |

### 行走 (walk)

| 方向 | 帧数 | 文件 |
|------|------|------|
| 南 (s) | 4 | `hero_walk_s_00.png` ~ `hero_walk_s_03.png` |
| 北 (n) | 2 | `hero_walk_n_00.png` ~ `hero_walk_n_01.png` |
| 东 (e) | 2 | `hero_walk_e_00.png` ~ `hero_walk_e_01.png` |
| 西 (w) | 2 | `hero_walk_w_00.png` ~ `hero_walk_w_01.png` |

> ⚠️ N/E/W 行走暂为 2 帧，后续可能补充更多帧。

## 技术规格

| 属性 | 值 |
|------|-----|
| 画布尺寸 | 64×64 像素 |
| 格式 | PNG (RGBA) |
| 透明处理 | 品红色键控透明 |
| 面部黑色 | 保留不变 |

## 工程接入

请工程按以下文档创建 SpriteFrames 资源：

- [工程-SpriteFrames导入约定.md](../../../../docs/工程-SpriteFrames导入约定.md)
- [animation-frames.md](../../../../docs/art/animation-frames.md)

### 导入设置

| 设置项 | 值 |
|--------|-----|
| Filter | **OFF** (Nearest) |
| Mipmaps | **OFF** |
| Compress Mode | Lossless |
