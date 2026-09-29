# 敌人地图精灵 / 战斗剪影

> 状态：**待用户正式过检（先按「全部上 GitHub」入库）**  
> 日期：2026-09-14

| 文件 | 尺寸 | 用途 |
|------|------|------|
| `enemy_bone_guard_idle_s_00.png` | 64×64 | 骨卫地图 idle（南） |
| `enemy_bone_guard_combat_sil_idle.png` | 64×64 | 战斗剪影占位 |

导入：Filter=Nearest，Mipmaps OFF。挂 SpriteFrames 前请对照 `docs/工程-SpriteFrames导入约定.md`。

---

# M1 精英 / 守护者 — 战斗 idle 精灵（暂存）

> 项目：《深墓来客》Godot 4 · 日期：2026-09-29（Asia/Shanghai）· 未推送仓库、未开 PR

## 文件

| 文件 | 尺寸 | 说明 |
|------|------|------|
| `enemy_death_knight_combat_idle_p1_00.png` | 64×64 RGBA | 死骸骑士 **第一阶段 · 奥术（ARCANE）**：金色（#C9A24A）发光眼窝、盾面金色奥术符印、剑身金色符文细线；角盔骷髅面、冷色暗甲（#1A1C22/#3A4A52）亮铜边、暗红披风与罩袍 |
| `enemy_death_knight_combat_idle_p2_00.png` | 64×64 RGBA | 死骸骑士 **第二阶段 · 暗影（SHADOW，狂暴/破损）**：强调色金→紫（#6B3FA0）；盾牌丢失、右角折断、右肩甲碎裂、胸甲破洞与裂纹溢出紫色魂火、眼窝紫火、双手举剑、站姿更开 |
| `enemy_undead_overlord_combat_idle_00.png` | 64×64 RGBA | 第一守护者「死者统领」**· 物理（PHYSICAL，弱暗影）**：重型骨甲骷髅统领——骨白（#D8D0C4）肋板肩甲（带小颅骨饰）、覆于长袍外的肋骨胸甲、骨片腰垂、骨质护臂与握拳骨手、颅骨杖首；青铜（#886644）饰边；金色仅用于王冠（杖首铜叉尖少量点缀）；**无任何紫色**；原创造型，仅用功能性称号 |

## 规格

- 画布 64×64，alpha 仅 0/255，硬像素无抗锯齿，1px 暗色外描边（左/上缘带少量 #553322/#8B1E2D 边光，与骨卫一致）
- 仅使用锁定 16 色板（见 `/workspace/vs-frames/stage/m1_look_polish/palette.txt`）
- 3/4 正面朝南，脚底留 3px；角色身体中轴 x≈32（武器可偏出）
- p1 / p2 躯干、头盔、左肩甲、披风上缘坐标一致（p2 仅腿部各外移 2px 表现狂暴站姿，右肩甲/右角为破损变体），切换贴图时位置不跳动
- 元素识别：p1 金色强调 = 奥术，p2 紫色强调 = 暗影；两阶段盔甲同为冷色暗甲，保证切换时第一眼看到的是强调色变化

## Godot 导入

- Filter：**Nearest**（关闭）
- Mipmaps：**关**
- Compress：Lossless；Repeat：Disabled

## 工程说明

- 死骸骑士进入第二阶段时，工程侧将战斗 Sprite 的 texture 从 `..._p1_00.png` **直接替换**为 `..._p2_00.png`（可配合闪白/震屏特效）。
- 本批为手绘像素（Pillow 程序化逐像素绘制），源脚本：`m1_elite_guardian/src/`（knight.py / overlord.py）。

## 审阅（非进仓）

- `m1_elite_guardian/review/m1_elite_guardian_sheet_x4.png`：骨卫 / 骑士 p1 / 骑士 p2 / 死者统领 4× 对照 + 战斗地板 1× 行
- `m1_elite_guardian/review/m1_elite_guardian_floor_x2.png`：战斗地板 2× 可读性检查
- `m1_elite_guardian/review/verify_output.txt`：尺寸 / alpha / 色板校验输出
