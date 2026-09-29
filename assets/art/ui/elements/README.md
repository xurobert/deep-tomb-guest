# 属性图标（M1 技能与属性克制薄片）

16 色锁定色盘，alpha 只有 0/255。导入：Filter Nearest，Mipmaps 关。

| 属性 id | 16×16（按钮前缀） | 32×32（敌人情报栏弱点） | 主色 |
|---|---|---|---|
| physical | ui_elem_physical_16.png | ui_elem_physical_32.png | 骨白 #D8D0C4 |
| arcane | ui_elem_arcane_16.png | ui_elem_arcane_32.png | 金 #C9A24A |
| shadow | ui_elem_shadow_16.png | ui_elem_shadow_32.png | 紫 #6B3FA0 |

- 技能按钮：图标放在按钮左内沿，左/上各留 8px（按钮高 32，图标垂直居中）。`attack`、`slash` 用 physical，`arcane_bolt` 用 arcane，`deep_echo_pulse` 用 shadow；`insight` 不带属性图标。
- 洞察揭示后，情报栏的 `ui_intel_revealed_32` 旁边显示对应弱点的 32×32 图标；未揭示时仍用 `ui_intel_unknown_32`。
- 克制/被克的伤害飘字颜色建议：克制用金 #C9A24A，被克用灰 #7A8B9A，普通用骨白 #D8D0C4。
