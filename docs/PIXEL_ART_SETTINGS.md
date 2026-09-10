# Pixel Art Import Settings

This document describes the required import settings for pixel art assets in Deep Tomb Guest.

## Global Settings (Already Configured)

The `project.godot` file includes:
```
[rendering]
textures/canvas_textures/default_texture_filter=0
```

This sets the default texture filter to **Nearest** (no filtering), which is essential for crisp pixel art.

## Per-Asset Import Settings

When importing new pixel art textures, ensure these settings in the Import dock:

### Textures (.png, .jpg)
- **Filter**: OFF (Nearest)
- **Mipmaps**: OFF (Generate Mipmaps = false)
- **Repeat**: Disabled (unless tiling texture)

### How to Configure

1. Select the texture in FileSystem
2. Go to Import tab
3. Set:
   - Compress > Mode: Lossless
   - Flags > Filter: OFF
   - Flags > Mipmaps: OFF
4. Click "Reimport"

### Preset Creation (Recommended)

To create a reusable preset:
1. Configure one texture as above
2. Click "Preset" dropdown in Import dock
3. Select "Save Current as..."
4. Name it "Pixel Art"

## Asset Specifications

| Asset Type | Canvas Size | Notes |
|------------|-------------|-------|
| Tiles | 16×16 px | Seamless edges for tiling |
| Characters | 32×32 px | Centered, with room for animations |
| UI Elements | Variable | Use multiples of 8px |
| Effects/FX | Variable | Match context (tile or character scale) |

## Naming Convention

```
subject_state_dir_frame.png
```

Examples:
- `hero_idle_s_00.png` - Hero, idle animation, facing south, frame 0
- `hero_walk_e_02.png` - Hero, walking, facing east, frame 2
- `tile_floor_stone_00.png` - Floor tile, stone variant
- `ui_btn_attack_normal.png` - UI button, attack, normal state

### Direction Codes
- `n` = North (up)
- `s` = South (down)
- `e` = East (right)
- `w` = West (left)
