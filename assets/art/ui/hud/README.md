# 战斗 HUD 九宫格皮肤（M1 去灰块）

全部使用 16 色锁定色盘，alpha 只有 0/255。导入：Filter Nearest，Mipmaps 关。

| 文件 | 尺寸 | 用途 | StyleBoxTexture texture_margin（左/上/右/下） |
|---|---|---|---|
| ui_bar_hp_bg_16.png | 32×16 | 玩家/敌人血条底框 | 4/4/4/4 |
| ui_bar_hp_fill_16.png | 32×16 | 血条填充（外圈 3px 透明，与底框内沿对齐） | 4/4/4/4 |
| ui_bar_res_bg_12.png | 32×12 | 共鸣条底框 | 4/4/4/4 |
| ui_bar_res_fill_12.png | 32×12 | 共鸣条填充 | 4/4/4/4 |
| ui_bar_loc_bg_12.png | 32×12 | 失控条底框 | 4/4/4/4 |
| ui_bar_loc_fill_12.png | 32×12 | 失控条填充 | 4/4/4/4 |
| ui_btn_normal_32.png | 48×32 | 按钮 normal | 6/6/6/6 |
| ui_btn_hover_32.png | 48×32 | 按钮 hover（金边） | 6/6/6/6 |
| ui_btn_pressed_32.png | 48×32 | 按钮 pressed | 6/6/6/6 |
| ui_btn_disabled_32.png | 48×32 | 按钮 disabled | 6/6/6/6 |

- 底框和填充尺寸一致，填充贴图外圈留透明，直接叠在底框上即可，不需要额外 expand margin。
- 按钮文字色建议：normal/hover/pressed 用 `#D8D0C4`，disabled 用 `#7A8B9A`。pressed 态文字可下移 1px。
- axis_stretch 横向用 Stretch 即可（中段是纯色）。
