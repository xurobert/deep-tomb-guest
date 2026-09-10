# 资产命名与导入规范

本文档定义《深墓来客》的美术资产命名规则及 Godot 4 导入设置。

## 命名规范

### 格式

```
subject_state_dir_frame
```

- **subject**：主体名称（小写英文）
- **state**：状态（idle / walk / attack 等）
- **dir**：方向（d / u / l / r 表示下/上/左/右）
- **frame**：帧序号（两位数，零填充：00, 01, 02…）

### 示例

| 文件名 | 说明 |
|--------|------|
| `adventurer_idle_d_00.png` | 冒险者 · 待机 · 朝下 · 第 0 帧 |
| `adventurer_walk_r_03.png` | 冒险者 · 行走 · 朝右 · 第 3 帧 |
| `tomb_tile_floor_00.png` | 墓穴地砖 · 第 0 帧 |
| `skeleton_attack_l_02.png` | 骷髅兵 · 攻击 · 朝左 · 第 2 帧 |

## Godot 导入设置

| 类型 | 画布尺寸 | Filter | Mipmaps |
|------|----------|--------|---------|
| 地图图块（tile） | 16×16 px | 关闭 | 关闭 |
| 角色图块（character） | 32×32 px | 关闭 | 关闭 |
| 立绘（portrait） | 独立尺寸 | 关闭 | 关闭 |

> 注意：所有像素美术必须关闭 Filter 和 Mipmaps 以保持锐利边缘。

## 术语映射表

代码中使用英文 ID，游戏内显示中文名称。

| 英文 ID | 中文显示 |
|---------|----------|
| Deep Echo | 异能共鸣 |
| Overload | 失控 |
| Recognition | 认可 |
