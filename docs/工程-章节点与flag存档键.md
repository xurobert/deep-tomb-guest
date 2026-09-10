# 工程：章节点与 Flag 存档键

> 版本：v1.0  
> 日期：2026-09-10  
> 状态：工程规范文档  
> 对照文档：全章大纲.md、第0-1章节拍.md、主角一页纸.md

---

## 一、概述

本文档定义《深墓来客》的：
- 章节检查点（Chapter Checkpoints）
- 剧情 Flag 表（Story Flags）
- SaveManager 存档数据结构（Save Keys Schema）
- 垂直切片（VS）与后续里程碑的 Flag 范围

---

## 二、章节检查点

### 检查点设计原则

1. **魂灯（save_point）= 硬存档点**：玩家必须与魂灯交互才能存档
2. **章节完成 = 自动标记**：章节完成时自动设置 `chapter_X_complete` flag
3. **不可逆点（point_of_no_return）**：特定事件后无法返回之前区域

### 检查点表

| 章节 | 检查点 ID | 位置描述 | 触发条件 | 解锁内容 |
|------|-----------|----------|----------|----------|
| **第 0 章** | `save_point_ch0_entrance` | 入口大厅·魂灯祭坛 | Beat 04 触发 | 首个存档点 |
| **第 0 章** | `checkpoint_ch0_complete` | 通往第 1 层门前 | Beat 10 完成 | 解锁第 1 章 |
| **第 1 章** | `save_point_ch1_entrance` | 第 1 层·入口区 | 进入第 1 层 | — |
| **第 1 章** | `save_point_ch1_mid` | 第 1 层·中继祭坛 | Beat 05 触发 | — |
| **第 1 章** | `save_point_ch1_guardian` | 第 3 层·守护者殿前 | Beat 11 触发 | BOSS 前存档 |
| **第 1 章** | `checkpoint_ch1_complete` | 守护者殿堂 | Beat 12 完成 | 解锁第 2 章 |
| **第 2 章** | `save_point_ch2_entrance` | 第 4 层·地下湖泊入口 | 进入第 2 章 | — |
| **第 2 章** | `checkpoint_ch2_complete` | 深渊领主击败后 | 守护者战完成 | 解锁第 3 章 |
| **第 3 章** | `save_point_ch3_entrance` | 第 5 层·冰封区入口 | 进入第 3 章 | — |
| **第 3 章** | `checkpoint_ch3_complete` | 冰霜贵女击败后 | 守护者战完成 | 解锁第 4 章 |
| **第 4 章** | `save_point_ch4_entrance` | 第 6 层·黑暗森林入口 | 进入第 4 章 | — |
| **第 4 章** | `checkpoint_ch4_complete` | 双子刺客击败后 | 守护者战完成 | 解锁第 5 章 |
| **第 5 章** | `save_point_ch5_entrance` | 第 7 层·熔岩区入口 | 进入第 5 章 | — |
| **第 5 章** | `checkpoint_ch5_complete` | 炎魔将军击败后 | 守护者战完成 | 解锁第 6 章 |
| **第 6 章** | `save_point_ch6_entrance` | 第 8 层·荒野入口 | 进入第 6 章 | — |
| **第 6 章** | `checkpoint_ch6_complete` | 荒野王击败后 | 守护者战完成 | 解锁第 7 章 |
| **第 7 章** | `save_point_ch7_entrance` | 第 9 层·套房入口 | 进入第 7 章 | — |
| **第 7 章** | `checkpoint_ch7_complete` | 总管战完成后 | 守护者战完成 | 解锁终章 |
| **终章** | `save_point_final_entrance` | 第 10 层·王座前厅 | 进入终章 | — |
| **终章** | `checkpoint_final_complete` | 结局达成 | 赌约完成 | 结局 CG |
| **隐藏** | `save_point_treasure` | 宝物殿入口 | 高认可解锁 | 隐藏结局路线 |

---

## 三、Flag 表

### 命名规范

| 前缀 | 用途 | 示例 |
|------|------|------|
| `chapter_X_` | 章节状态 | `chapter_0_started`, `chapter_1_complete` |
| `has_` | 布尔获取状态 | `has_first_recognition`, `has_ally_a` |
| `met_` | 遭遇/见面 | `met_guardian_1`, `met_ally_a` |
| `is_` | 当前状态 | `is_overloading`, `is_in_combat` |
| `_count` | 计数器 | `overload_count`, `traps_triggered_count` |
| `_level` | 等级数值 | `echo_level`, `guardian_1_recognition` |

### 第 0 章 Flag 表

| Flag ID | 中文含义 | 类型 | 设置条件 | 清除条件 | VS 必需 |
|---------|----------|------|----------|----------|---------|
| `chapter_0_started` | 第 0 章开始 | bool | Beat 01 开场 | — | ✅ |
| `found_first_clue` | 首次发现线索 | bool | 检查任意物品 | — | ❌ |
| `entrance_collapsed` | 入口崩塌 | bool | Beat 03 陷阱触发 | — | ✅ |
| `point_of_no_return_0` | 不可返回点 0 | bool | Beat 03 崩塌后 | — | ✅ |
| `first_save_point_activated` | 首个魂灯激活 | bool | Beat 04 魂灯交互 | — | ✅ |
| `first_battle_started` | 首战开始 | bool | Beat 05 战斗触发 | — | ✅ |
| `first_battle_won` | 首战胜利 | bool | Beat 05 击败敌人 | — | ✅ |
| `first_echo_awakened` | 首次异能觉醒 | bool | Beat 06 危机触发 | — | ✅ |
| `echo_tutorial_complete` | 异能教学完成 | bool | Beat 07 教学结束 | — | ✅ |
| `first_recognition` | 首次获得认可 | bool | Beat 08 战后奖励 | — | ✅ |
| `chapter_0_complete` | 第 0 章完成 | bool | Beat 10 进入层门 | — | ❌ |
| `chapter_1_unlocked` | 第 1 章解锁 | bool | Beat 10 完成 | — | ❌ |

### 第 1 章 Flag 表

| Flag ID | 中文含义 | 类型 | 设置条件 | 清除条件 | M1 必需 |
|---------|----------|------|----------|----------|---------|
| `chapter_1_started` | 第 1 章开始 | bool | 进入第 1 层 | — | ✅ |
| `floor_1_entered` | 进入第 1 层 | bool | Beat 01 场景加载 | — | ✅ |
| `intel_system_tutorial` | 情报系统教学 | bool | Beat 02 情报空白体验 | — | ✅ |
| `trap_tutorial_complete` | 陷阱教学完成 | bool | Beat 03 通过陷阱区 | — | ✅ |
| `traps_triggered_count` | 触发陷阱计数 | int | 每次触发 +1 | — | ❌ |
| `maze_section_entered` | 进入迷宫区 | bool | Beat 04 迷宫触发 | — | ❌ |
| `maze_section_cleared` | 通过迷宫区 | bool | 找到迷宫出口 | — | ❌ |
| `save_point_floor_1_mid` | 第 1 层中继存档 | bool | Beat 05 魂灯交互 | — | ✅ |
| `intel_collected_floor_1` | 情报收集计数 | int | 收集情报 +1 | — | ❌ |
| `elite_warning_triggered` | 精英预警触发 | bool | Beat 07 环境变化 | — | ✅ |
| `elite_corpse_knight_defeated` | 精英击败 | bool | Beat 08 战斗胜利 | — | ✅ |
| `guardian_1_hinted` | 守护者线索发现 | bool | Beat 09 发现证据 | — | ✅ |
| `shalltear_hook_found` | 夏提雅伏笔（可选） | bool | Beat 10 收集可选物品 | — | ❌ |
| `guardian_1_ready` | 准备守护者战 | bool | Beat 11 存档确认 | — | ✅ |
| `guardian_1_defeated` | 守护者战完成 | bool | Beat 12 战斗胜利 | — | ✅ |
| `guardian_1_recognition` | 守护者认可等级 | int | Beat 12 认可判定 (0-3) | — | ✅ |
| `chapter_1_complete` | 第 1 章完成 | bool | Beat 12 完成 | — | ✅ |

### 后续章节 Flag 存根

> 以下 Flag 为后续章节预留，详细设置条件待各章节设计完成后补充。

| 章节 | Flag ID | 中文含义 | 类型 |
|------|---------|----------|------|
| 第 2 章 | `chapter_2_started` | 第 2 章开始 | bool |
| 第 2 章 | `chapter_2_complete` | 第 2 章完成 | bool |
| 第 2 章 | `guardian_2_recognition` | 深渊领主认可 | int |
| 第 2 章 | `has_water_adaptation` | 获得水域适应 | bool |
| 第 3 章 | `chapter_3_started` | 第 3 章开始 | bool |
| 第 3 章 | `chapter_3_complete` | 第 3 章完成 | bool |
| 第 3 章 | `guardian_3_recognition` | 冰霜贵女认可 | int |
| 第 3 章 | `overload_level_2_unlocked` | 失控等级 2 解锁 | bool |
| 第 4 章 | `chapter_4_started` | 第 4 章开始 | bool |
| 第 4 章 | `chapter_4_complete` | 第 4 章完成 | bool |
| 第 4 章 | `guardian_4_recognition` | 双子精灵认可 | int |
| 第 4 章 | `has_ally_a` | 获得首位援护 | bool |
| 第 5 章 | `chapter_5_started` | 第 5 章开始 | bool |
| 第 5 章 | `chapter_5_complete` | 第 5 章完成 | bool |
| 第 5 章 | `guardian_5_recognition` | 炎魔将军认可 | int |
| 第 5 章 | `has_intel_discernment` | 情报辨别异能 | bool |
| 第 6 章 | `chapter_6_started` | 第 6 章开始 | bool |
| 第 6 章 | `chapter_6_complete` | 第 6 章完成 | bool |
| 第 6 章 | `guardian_6_recognition` | 荒野王认可 | int |
| 第 6 章 | `critical_choice_made` | 关键取舍完成 | bool |
| 第 7 章 | `chapter_7_started` | 第 7 章开始 | bool |
| 第 7 章 | `chapter_7_complete` | 第 7 章完成 | bool |
| 第 7 章 | `guardian_7_recognition` | 总管认可 | int |
| 第 7 章 | `all_abilities_unlocked` | 全异能解锁 | bool |
| 终章 | `final_chapter_started` | 终章开始 | bool |
| 终章 | `final_chapter_complete` | 终章完成 | bool |
| 终章 | `ending_achieved` | 达成结局类型 | string |
| 隐藏 | `treasure_hall_unlocked` | 宝物殿解锁 | bool |
| 隐藏 | `treasure_hall_complete` | 宝物殿完成 | bool |
| 隐藏 | `hidden_ending_achieved` | 隐藏结局达成 | bool |

---

## 四、核心状态变量

### 玩家数值状态

| 变量名 | 中文含义 | 类型 | 初始值 | 范围 | 存档 |
|--------|----------|------|--------|------|------|
| `echo_level` | 异能等级 | int | 0 | 0-5 | ✅ |
| `overload_gauge` | 失控槽 | int | 0 | 0-100 | ✅ |
| `overload_count` | 累计失控次数 | int | 0 | 0+ | ✅ |
| `recognition_total` | 认可总点数 | int | 0 | 0+ | ✅ |
| `hp` | 当前生命值 | int | 100 | 0-max_hp | ✅ |
| `max_hp` | 生命值上限 | int | 100 | 100+ | ✅ |

### 守护者认可状态

| 变量名 | 中文含义 | 类型 | 初始值 | 范围 | 说明 |
|--------|----------|------|--------|------|------|
| `guardian_recognition.floor_1` | 第一守护者认可 | int | 0 | -1~3 | -1=敌对, 0=未接触, 1-3=认可等级 |
| `guardian_recognition.floor_2` | 第二守护者认可 | int | 0 | -1~3 | 同上 |
| `guardian_recognition.floor_3` | 第三守护者认可 | int | 0 | -1~3 | 同上 |
| `guardian_recognition.floor_4` | 第四守护者认可 | int | 0 | -1~3 | 同上 |
| `guardian_recognition.floor_5` | 第五守护者认可 | int | 0 | -1~3 | 同上 |
| `guardian_recognition.floor_6` | 第六守护者认可 | int | 0 | -1~3 | 同上 |
| `guardian_recognition.floor_7` | 第七守护者认可 | int | 0 | -1~3 | 同上 |
| `guardian_recognition.final` | 最终守护者认可 | int | 0 | -1~3 | 同上 |

### 结局权重

| 变量名 | 中文含义 | 类型 | 说明 |
|--------|----------|------|------|
| `ending_weight.recognition` | 认可结局权重 | int | 运行时计算 |
| `ending_weight.pyrrhic` | 惨胜结局权重 | int | 运行时计算 |
| `ending_weight.corruption` | 堕落结局权重 | int | 运行时计算 |
| `ending_weight.hidden` | 隐藏结局权重 | int | 运行时计算 |

---

## 五、SaveManager 存档结构

### 当前实现 (v1)

```gdscript
# scripts/core/save_manager.gd
var save_data := {
    "version": 1,
    "timestamp": int,           # Unix 时间戳
    "player": Dictionary,       # GameManager.player_data 副本
    "scene": String             # 当前场景路径
}
```

### 建议扩展结构 (v2)

```gdscript
var save_data := {
    "version": 2,
    "timestamp": int,
    
    # 章节进度
    "chapter": {
        "current": int,                 # 当前章节号 (0-7, 8=终章, 9=隐藏)
        "checkpoint_id": String,        # 最近检查点 ID
        "unlocked_chapters": Array[int] # 已解锁章节列表
    },
    
    # 玩家数值
    "player": {
        "name": String,
        "hp": int,
        "max_hp": int,
        "overload": int,
        "max_overload": int,
        "recognition": int,
        "echo_level": int,
        "overload_count": int,
        "skills": Array[String],
        "inventory": Array[String]      # 物品 ID 列表（预留）
    },
    
    # 剧情 Flag
    "flags": {
        # 布尔 flag
        "chapter_0_started": bool,
        "first_echo_awakened": bool,
        # ... 其他 flag
    },
    
    # 守护者认可
    "guardian_recognition": {
        "floor_1": int,
        "floor_2": int,
        # ... floor_3 ~ final
    },
    
    # 情报收集
    "intel": {
        "enemies": Array[String],       # 已解锁敌人情报 ID
        "items": Array[String],         # 已收集物品情报 ID
        "lore": Array[String]           # 已读文献 ID
    },
    
    # 场景状态
    "scene": {
        "current_path": String,
        "player_position": Vector2,     # 玩家位置
        "interacted_objects": Array[String]  # 已交互物体 ID
    }
}
```

### 存档键说明

| 键路径 | 类型 | 说明 |
|--------|------|------|
| `version` | int | 存档格式版本，用于迁移 |
| `timestamp` | int | Unix 时间戳 |
| `chapter.current` | int | 当前章节号 |
| `chapter.checkpoint_id` | string | 最近检查点 ID |
| `chapter.unlocked_chapters` | array | 已解锁章节号数组 |
| `player.*` | mixed | 玩家数值状态 |
| `flags.*` | bool/int | 剧情 flag 字典 |
| `guardian_recognition.*` | int | 各守护者认可值 |
| `intel.*` | array | 情报收集状态 |
| `scene.*` | mixed | 场景恢复状态 |

---

## 六、VS 范围说明

### VS 必需 Flag（优先实现）

以下 Flag 为垂直切片必须实现：

```
chapter_0_started
entrance_collapsed
point_of_no_return_0
first_save_point_activated
first_battle_started
first_battle_won
first_echo_awakened
echo_tutorial_complete
first_recognition
```

### VS 必需存档键

```
version
timestamp
player.hp
player.max_hp
player.overload
player.recognition
player.echo_level
player.skills
flags.first_save_point_activated
flags.first_echo_awakened
flags.first_recognition
scene.current_path
```

### M1 扩展 Flag

在 VS 基础上，M1 里程碑需额外实现：

```
chapter_0_complete
chapter_1_started
chapter_1_complete
floor_1_entered
intel_system_tutorial
trap_tutorial_complete
elite_warning_triggered
elite_corpse_knight_defeated
guardian_1_hinted
guardian_1_ready
guardian_1_defeated
guardian_1_recognition
```

---

## 七、代码实现建议

### 1. Flag 管理器

建议创建 `FlagManager` 自动加载单例：

```gdscript
# scripts/core/flag_manager.gd
extends Node

var flags: Dictionary = {}

func set_flag(flag_id: String, value = true) -> void:
    flags[flag_id] = value

func get_flag(flag_id: String, default = false):
    return flags.get(flag_id, default)

func has_flag(flag_id: String) -> bool:
    return flags.has(flag_id) and flags[flag_id]

func increment_flag(flag_id: String, amount: int = 1) -> void:
    flags[flag_id] = flags.get(flag_id, 0) + amount
```

### 2. 章节检查点触发

```gdscript
# 魂灯交互时
func _on_save_point_interacted(checkpoint_id: String) -> void:
    FlagManager.set_flag(checkpoint_id)
    SaveManager.save_game_with_checkpoint(checkpoint_id)

# 章节完成时
func _on_chapter_complete(chapter_num: int) -> void:
    FlagManager.set_flag("chapter_%d_complete" % chapter_num)
    FlagManager.set_flag("chapter_%d_unlocked" % (chapter_num + 1))
```

### 3. 结局权重计算

```gdscript
func calculate_ending_weights() -> Dictionary:
    var weights := {
        "recognition": 0,
        "pyrrhic": 0,
        "corruption": 0,
        "hidden": 0
    }
    
    var recognition := GameManager.player_data.recognition
    var overload_count := GameManager.player_data.get("overload_count", 0)
    var overload_gauge := GameManager.player_data.overload
    
    # 认可结局：高认可 + 低失控
    if recognition >= 50 and overload_gauge < 50:
        weights.recognition += 100
    
    # 惨胜结局：中等认可 + 中等失控
    if recognition >= 25 and overload_gauge >= 50 and overload_gauge < 80:
        weights.pyrrhic += 100
    
    # 堕落结局：高失控或多次失控
    if overload_gauge >= 80 or overload_count >= 3:
        weights.corruption += 100
    
    # 隐藏结局：最高认可 + 全守护者好感
    if recognition >= 100 and _all_guardians_max_recognition():
        weights.hidden += 100
    
    return weights
```

---

## 八、文档关联

- [全章大纲.md](全章大纲.md) — 章节结构与多结局设计
- [第0-1章节拍.md](第0-1章节拍.md) — Flag 触发时机详细定义
- [主角一页纸.md](主角一页纸.md) — 玩家状态变量设计
- [工程-SpriteFrames导入约定.md](工程-SpriteFrames导入约定.md) — 美术资源导入规范
- [垂直切片验收表.md](垂直切片验收表.md) — VS 范围与验收标准

---

## 九、备注

1. Flag ID 使用 snake_case 英文，便于代码引用
2. 中文含义用于文档说明和调试工具显示
3. 存档版本升级时需实现数据迁移逻辑
4. 与 GDD-v1.1.md 如有冲突，以 GDD 为准
