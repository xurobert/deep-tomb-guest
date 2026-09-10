# VS 第 0 章提示词模板

本文档为垂直切片（Vertical Slice）第 0 章（Beat 01–08）提供工具无关的图像生成提示词模板。

> **重要说明**：本文档为提示词模板，非最终美术资产。实际生成效果需根据所选工具（Grok Imagine / MidJourney / Stable Diffusion-ComfyUI 等）调整参数。

---

## 通用风格块（Style Block）

以下风格描述可复用于所有提示词的开头或末尾：

```
Dark gothic line art with Japanese portrait readability. Top-down 2.5D perspective 
for environment, bust portrait for characters. Muted 16+ palette: stone-black 
#1A1C22, teal-stone #3A4A52, bone-white #D8D0C4, gilt-gold #C9A24A, blood-red 
#8B1E2D, power-ash #7A8B9A, overload-purple #6B3FA0, readable-green #4A7C59. 
Pixel art style, clean edges, high silhouette readability.
```

**中文参考**：暗黑哥特线稿风格，兼具日系立绘可读性。环境采用 2.5D 俯视视角，角色为胸像立绘。16+ 柔化配色：石底黑 #1A1C22，石青 #3A4A52，骨白 #D8D0C4，鎏金 #C9A24A，血曜红 #8B1E2D，异能灰光 #7A8B9A，失控紫 #6B3FA0，可读绿 #4A7C59。像素美术风格，边缘干净，剪影高辨识度。

---

## 通用负面提示词（Negative Prompts）

适用于所有游戏美术生成：

```
no baked shadows, no background for sprites, no watermark, no anti-aliasing for 
pixel art, no gradients on pixel edges, no blur, no signature, no realistic gore, 
no official Overlord character likeness, no copyrighted character design
```

**中文参考**：禁止烘焙阴影、精灵图禁止背景、禁止水印、像素美术禁止抗锯齿、像素边缘禁止渐变、禁止模糊、禁止签名、禁止写实血腥、禁止官方 Overlord 角色肖像、禁止受版权保护的角色设计。

---

## 主体提示词（Subject Prompts）

### 1. 玩家地图精灵（Player Map Sprite）

**规格**：32×32 像素，4 方向，待机 + 行走帧

#### 1.1 玩家待机（Idle）

```
[STYLE BLOCK]
Subject: adventurer character idle sprite, 32x32 pixel art, 4-directional (down, up, 
left, right), single frame per direction. Hooded traveler with dark cloak, visible 
face silhouette, neutral standing pose. Stone-black and bone-white dominant. 
Transparent background.
[NEGATIVE PROMPTS]
```

#### 1.2 玩家行走（Walk）

```
[STYLE BLOCK]
Subject: adventurer character walk cycle sprite sheet, 32x32 pixel art, 4-directional, 
4 frames per direction (16 total). Hooded traveler with dark cloak, fluid walking 
animation, cape movement. Transparent background.
[NEGATIVE PROMPTS]
```

---

### 2. 玩家立绘肖像（Player Portrait Bust）

**规格**：独立尺寸（建议 256×256 或更高），胸像构图

```
[STYLE BLOCK]
Subject: adventurer portrait bust, upper body framing, three-quarter view facing 
slightly left. Hooded figure with visible face in shadow, determined expression, 
dark traveling cloak with bone-white trim. Gilt-gold accent on clasp. Gothic line 
art with Japanese anime influence. Dark teal-stone background gradient.
[NEGATIVE PROMPTS]
```

---

### 3. 墓道入口地砖（Tomb Approach Tiles）

**规格**：16×16 像素，可拼接瓦片集

#### 3.1 石质地砖基础（Floor Stone Base）

```
[STYLE BLOCK]
Subject: dungeon floor tile, 16x16 pixel art, top-down view. Cracked stone slab, 
weathered texture, stone-black #1A1C22 base with teal-stone #3A4A52 cracks. 
Seamlessly tileable. Transparent or solid black background.
[NEGATIVE PROMPTS]
```

#### 3.2 墓道墙壁（Tomb Wall）

```
[STYLE BLOCK]
Subject: dungeon wall tile, 16x16 pixel art, top-down view for wall edge. Dark 
stone brick pattern, gothic arch texture hint, stone-black dominant with bone-white 
mortar lines. Auto-tile compatible edges.
[NEGATIVE PROMPTS]
```

#### 3.3 入口阶梯（Entrance Stairs）

```
[STYLE BLOCK]
Subject: dungeon entrance stairway tile, 16x32 pixel art (2 tiles tall), top-down 
view. Stone steps descending into darkness, gilt-gold light glow from below, 
ominous atmosphere. Scene transition marker.
[NEGATIVE PROMPTS]
```

---

### 4. 骷髅守卫敌人（Skeleton Guard Enemy）

**规格**：32×32 像素，敌人精灵

```
[STYLE BLOCK]
Subject: skeleton guard enemy sprite, 32x32 pixel art, front-facing idle pose. 
Animated skeleton warrior with rusted sword and partial armor, bone-white skeleton 
structure with blood-red eye glow. Gothic stylized bones, no realistic anatomy. 
Transparent background.
[NEGATIVE PROMPTS]
```

---

### 5. 魂灯存档点（Soul Lamp Save Point）

**规格**：32×32 或 16×32 像素，环境物件

```
[STYLE BLOCK]
Subject: soul lamp save point object, 32x32 pixel art, gothic lantern on stone 
pedestal. Floating ethereal flame inside, power-ash #7A8B9A glow with readable-green 
#4A7C59 tint. Bone-white metalwork frame with gilt-gold accents. Soft ambient light 
radius.
[NEGATIVE PROMPTS]
```

---

### 6. 异能共鸣觉醒特效（Deep Echo Awaken VFX Stub）

**规格**：32×32 像素帧序列（4–8 帧），叠加特效

```
[STYLE BLOCK]
Subject: magical awakening VFX sprite sheet, 32x32 pixel art, 4-8 frame animation. 
Ethereal energy burst emanating from center, power-ash #7A8B9A primary glow with 
bone-white sparks. Radial expansion pattern, fading edges. Transparent background, 
additive blend compatible.
[NEGATIVE PROMPTS]
```

---

### 7. 认可提示框（Recognition Toast Frame）

**规格**：UI 元素，尺寸待定（建议 160×48 或适配文本）

```
[STYLE BLOCK]
Subject: UI toast notification frame, pixel art style, horizontal banner shape. 
Stone-black #1A1C22 background panel with gilt-gold #C9A24A ornate border. Gothic 
arch motif corners, space for text in center. Subtle bone-white inner glow. 
Clean edges for UI overlay.
[NEGATIVE PROMPTS]
```

---

## 参数区域（Parameters）

> **工具待定，当前为通用**
> 
> 以下参数区域将在确定生成工具后补充具体设置。
> 
> | 参数类型 | Grok Imagine | MidJourney | SD-ComfyUI |
> |----------|--------------|------------|------------|
> | 采样器 | TBD | TBD | TBD |
> | 步数 | TBD | TBD | TBD |
> | CFG | TBD | TBD | TBD |
> | 尺寸倍率 | TBD | TBD | TBD |
> | 特殊参数 | TBD | --stylize / --chaos | LoRA / ControlNet |
> 
> 待用户选定工具后更新此表。

---

## 使用说明

1. **组合方式**：将 `[STYLE BLOCK]` 替换为通用风格块，`[NEGATIVE PROMPTS]` 替换为通用负面提示词
2. **调整顺序**：不同工具对提示词顺序敏感度不同，MJ 偏好主体在前，SD 可用加权语法
3. **色值引用**：提示词中已包含 HEX 色值，部分工具可能不识别——可改用描述词如 "dark charcoal black" 替代 #1A1C22
4. **迭代流程**：首轮生成后根据效果微调关键词权重与负面词

---

## 附注

- 本表仅覆盖 VS 第 0 章（Beat 01–08）核心资产
- 后续章节提示词将在对应章节设计完成后补充
- 所有角色设计为原创，避免任何官方 Overlord 肖像或命名
