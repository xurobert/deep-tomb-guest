# 墓穴访客 (Deep Tomb Guest)

一款使用 Godot 4.x 开发的回合制 RPG 盒子游戏，包含探索和战斗机制。

## 快速开始

### 环境要求
- Godot 4.2+（从 [godotengine.org](https://godotengine.org/download) 下载）

### 打开项目
1. 启动 Godot 4
2. 在项目管理器中点击「导入」
3. 导航到本仓库文件夹并选择 `project.godot`
4. 点击「导入并编辑」

### 运行游戏
- 按 **F5** 运行游戏
- 或点击右上角的播放按钮

## 操作方式

| 动作 | 按键 |
|------|------|
| 移动 | WASD / 方向键 |
| 互动 | E / 空格键 |
| 确认 | 回车 / Z |
| 取消 | Esc / X |

## 游戏循环

1. **探索** - 使用 WASD 在房间内移动
2. **互动** - 与物体交互（黄色=文物，红色=敌人，蓝色=存档点）
3. **战斗** - 与敌人进行回合制战斗
4. **技能** - 使用「异能共鸣」等技能（会积累失控值）
5. **获得认可** - 击败敌人后获得认可值
6. **存档** - 在蓝色存档水晶处保存进度

## 项目结构

```
deep-tomb-guest/
├── assets/
│   ├── art/
│   │   ├── characters/    # 角色精灵图 (32×32)
│   │   ├── tiles/         # 地砖精灵图 (16×16)
│   │   ├── ui/            # UI 元素
│   │   └── fx/            # 视觉特效
│   └── audio/             # 音效和音乐
├── data/                  # JSON 数据文件（技能、敌人）
├── docs/                  # 设计文档
│   └── art/               # 美术指导文档、镜头列表
├── scenes/                # Godot 场景文件 (.tscn)
│   └── ui/                # UI 场景
└── scripts/               # GDScript 脚本文件
    ├── core/              # 自动加载脚本 (GameManager, TurnManager, SaveManager)
    ├── exploration/       # 玩家、可交互物、触发器
    ├── combat/            # 战斗 UI 与逻辑
    ├── systems/           # 游戏系统
    └── ui/                # HUD、提示、菜单
```

## 保留目录

- `docs/` - 保留用于游戏设计文档 (GDD)
- `docs/art/` - 保留用于美术指导文档和镜头列表

## 像素美术设置

所有贴图应使用：
- **滤镜 (Filter)**：关闭（最近邻）
- **Mipmaps**：关闭

详细导入说明请参阅 `docs/PIXEL_ART_SETTINGS.md`。

## 素材命名规范

```
subject_state_dir_frame.png
```

示例：
- `hero_idle_s_00.png` - 主角待机朝南，第 0 帧
- `tile_floor_stone_00.png` - 石质地板砖

## 当前功能（原型）

- [x] 俯视角探索与碰撞
- [x] 可交互物体与提示
- [x] 回合制战斗系统
- [x] 「异能共鸣」技能与失控机制
- [x] 战斗后获得认可
- [x] 战后提示通知
- [x] 本地存档/读档（存档点）
- [x] HUD 显示生命值和认可值

## 已知限制

- 使用占位色块代替精灵图
- 仅有单个房间（无房间切换）
- 仅有一种敌人类型（墓穴阴魂）
- 仅有一个技能（异能共鸣）
- 无背包或装备系统
- 无游戏结束画面（生命值归零需重启）
- 暂无音频
- 战斗 UI 全屏覆盖（无空间战斗视图）

## VS Code / 编辑器检查清单

对于使用 Godot Tools 扩展的 VS Code 用户：
1. 安装「Godot Tools」扩展
2. 在扩展设置中配置 Godot 可执行文件路径
3. GDScript 文件将具有语法高亮和自动补全功能

## 开发说明

### 自动加载脚本
游戏使用三个自动加载的单例：
- `GameManager` - 全局游戏状态、玩家数据、场景切换
- `TurnManager` - 战斗流程、回合顺序、技能执行
- `SaveManager` - 本地存档/读档至 `user://save_data.json`

### 添加新技能
编辑 `data/skills.json` 添加新技能：
```json
{
  "skill_id": {
    "id": "skill_id",
    "name": "技能名称",
    "description": "技能描述",
    "base_damage": 20,
    "overload_cost": 25,
    "type": "magic",
    "element": "void"
  }
}
```

### 添加新敌人
编辑 `data/enemies.json`：
```json
{
  "enemy_id": {
    "id": "enemy_id",
    "name": "敌人名称",
    "hp": 50,
    "max_hp": 50,
    "attack": 10,
    "defense": 2,
    "recognition_value": 15
  }
}
```

## 许可证

[在此添加许可证信息]
