# 美术文档

本目录包含《深墓来客》项目的美术方向和资源规范文档。

## 锁定决策

核心锁定已确定，详见 [palette-lock.md](palette-lock.md) 和 [grok-pixel-pipeline.md](grok-pixel-pipeline.md)：

| 锁定项 | 决策 |
|--------|------|
| 🔒 视角 | 2.5D 俯视箱庭 + 日系立绘对话（非 3D） |
| 🔒 分级 | 16+ 弱化（少血腥特写、暗示代替直给） |
| 🔒 IP | 纯同人自用，只借氛围，角色原创形，不描官方立绘 |
| 🔒 动画技术 | Godot SpriteFrames 逐帧动画，**禁止骨骼绑定** |
| 🔒 概念图 | 仅作参考存于 `docs/art/ref/`，**禁止进仓 `assets/`** |
| 🔒 Grok 管线 | 生成→裁切→最近邻缩放→量化至 8 色板→审核；**禁止高清直导、禁止双线性/AA** |

## 文档列表

| 文档 | 内容 |
|------|------|
| [animation-frames.md](animation-frames.md) | **VS 帧动画规范**（帧表、SpriteFrames、概念图规范） |
| [pixel-pipeline.md](pixel-pipeline.md) | **像素美术生产管线**（Grok 生成 → 缩放量化 → 审核入库） |
| [palette-lock.md](palette-lock.md) | 美术方向锁定（视角 / 分级 / IP 决策区块） |
| [grok-pixel-pipeline.md](grok-pixel-pipeline.md) | **🔒 Grok 像素管线**（生成→裁切→缩放→量化→审核流程、锁定 8 色板） |
| [perspective-and-pipeline.md](perspective-and-pipeline.md) | 视角规范与美术管线（2.5D、像素、立绘工作流） |
| [naming-and-import.md](naming-and-import.md) | 文件命名规范、目录结构、Godot 导入设置 |
| [m1-shot-list.md](m1-shot-list.md) | M1 里程碑资源清单（map-sprite / portrait 标注） |
| [chapter-art-beats.md](chapter-art-beats.md) | 各章节美术节拍与重点 |
| [prompt-sheet-vs-ch0.md](prompt-sheet-vs-ch0.md) | VS 第 0 章图像生成提示词模板 |

## 快速参考

### 资源尺寸

> **2026-09-10 更新**：画布尺寸已升级

| 资源类型 | 尺寸 |
|----------|------|
| 地图瓦片 (map-tile) | 32×32 px |
| 地图精灵 (map-sprite) | 64×64 px |
| 立绘 (portrait) | 512+ px（高分辨率） |

### 目录结构

```
assets/art/
├── characters/   # 地图精灵（探索/战斗）
├── portraits/    # 对话立绘（独立高分辨率）
├── tiles/        # 地图瓦片
├── ui/           # 界面元素
└── fx/           # 特效

docs/art/ref/     # 概念图/参考图（非进仓）
├── concept/      # 概念草图
├── grok/         # AI 生成参考
└── external/     # 外部参考
```

### Godot 导入设置

- Filter: OFF (Nearest)
- Mipmaps: OFF
- Compress: Lossless

### 动画技术约束

- ✅ 使用：Godot SpriteFrames 逐帧动画
- ❌ 禁止：Spine / DragonBones / Skeleton2D 骨骼绑定
