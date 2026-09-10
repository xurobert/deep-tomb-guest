# 美术文档

本目录包含《深墓来客》项目的美术方向和资源规范文档。

## 锁定决策

三项核心锁定已确定，详见 [palette-lock.md](palette-lock.md)：

| 锁定项 | 决策 |
|--------|------|
| 🔒 视角 | 2.5D 俯视箱庭 + 日系立绘对话（非 3D） |
| 🔒 分级 | 16+ 弱化（少血腥特写、暗示代替直给） |
| 🔒 IP | 纯同人自用，只借氛围，角色原创形，不描官方立绘 |

## 文档列表

| 文档 | 内容 |
|------|------|
| [palette-lock.md](palette-lock.md) | 美术方向锁定（视角 / 分级 / IP 决策区块） |
| [perspective-and-pipeline.md](perspective-and-pipeline.md) | 视角规范与美术管线（2.5D、像素、立绘工作流） |
| [m1-shot-list.md](m1-shot-list.md) | M1 里程碑资源清单（map-sprite / portrait 标注） |
| [naming-and-import.md](naming-and-import.md) | 文件命名规范、目录结构、Godot 导入设置 |

## 快速参考

### 资源尺寸

| 资源类型 | 尺寸 |
|----------|------|
| 地图瓦片 (map-tile) | 16×16 px |
| 地图精灵 (map-sprite) | 32×32 px |
| 立绘 (portrait) | 512+ px（高分辨率） |

### 目录结构

```
assets/art/
├── characters/   # 地图精灵（探索/战斗）
├── portraits/    # 对话立绘（独立高分辨率）
├── tiles/        # 地图瓦片
├── ui/           # 界面元素
└── fx/           # 特效
```

### Godot 导入设置

- Filter: OFF (Nearest)
- Mipmaps: OFF
- Compress: Lossless
=======
# 《深墓来客》美术文档索引

本目录存放项目美术方向相关文档。

## 文档列表

| 文档 | 说明 |
|------|------|
| [palette-lock.md](palette-lock.md) | 锁定调色板与色彩角色定义 |
| [naming-and-import.md](naming-and-import.md) | 资产命名规范与 Godot 导入设置 |
| [m1-shot-list.md](m1-shot-list.md) | M1 垂直切片资产清单 |
| [chapter-art-beats.md](chapter-art-beats.md) | 各章节美术节拍与重点 |
| [prompt-sheet-vs-ch0.md](prompt-sheet-vs-ch0.md) | VS 第 0 章图像生成提示词模板 |
| [m1-shot-list.md](m1-shot-list.md) | M1 垂直切片资产清单 |
