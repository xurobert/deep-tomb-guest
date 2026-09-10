# Deep Tomb Guest

A turn-based box RPG built with Godot 4.x featuring exploration and combat mechanics.

## Quick Start

### Requirements
- Godot 4.2+ (download from [godotengine.org](https://godotengine.org/download))

### Opening the Project
1. Launch Godot 4
2. Click "Import" in the Project Manager
3. Navigate to this repository folder and select `project.godot`
4. Click "Import & Edit"

### Running the Game
- Press **F5** to run the game
- Or click the Play button in the top-right corner

## Controls

| Action | Key |
|--------|-----|
| Move | WASD / Arrow Keys |
| Interact | E / Space |
| Confirm | Enter / Z |
| Cancel | Escape / X |

## Gameplay Loop

1. **Explore** the room using WASD
2. **Interact** with objects (yellow = artifact, red = enemy, blue = save point)
3. **Fight** enemies in turn-based combat
4. **Use skills** like "Deep Echo" (builds overload meter)
5. **Gain Recognition** after defeating enemies
6. **Save** at the blue save crystal

## Project Structure

```
deep-tomb-guest/
├── assets/
│   ├── art/
│   │   ├── characters/    # Character sprites (32×32)
│   │   ├── tiles/         # Tile sprites (16×16)
│   │   ├── ui/            # UI elements
│   │   └── fx/            # Visual effects
│   └── audio/             # Sound effects and music
├── data/                  # JSON data files (skills, enemies)
├── docs/                  # Design documentation
│   └── art/               # Art direction docs, shot lists
├── scenes/                # Godot scene files (.tscn)
│   └── ui/                # UI scenes
└── scripts/               # GDScript files
    ├── core/              # Autoloads (GameManager, TurnManager, SaveManager)
    ├── exploration/       # Player, interactables, triggers
    ├── combat/            # Combat UI and logic
    ├── systems/           # Game systems
    └── ui/                # HUD, toasts, menus
```

## Reserved Directories

- `docs/` - Reserved for Game Design Document (GDD)
- `docs/art/` - Reserved for art direction documents and shot lists

## Pixel Art Settings

All textures should use:
- **Filter**: OFF (Nearest neighbor)
- **Mipmaps**: OFF

See `docs/PIXEL_ART_SETTINGS.md` for detailed import instructions.

## Asset Naming Convention

```
subject_state_dir_frame.png
```

Examples:
- `hero_idle_s_00.png` - Hero idle facing south, frame 0
- `tile_floor_stone_00.png` - Stone floor tile

## Current Features (Prototype)

- [x] Top-down exploration with collision
- [x] Interactable objects with prompts
- [x] Turn-based combat system
- [x] "Deep Echo" skill with overload mechanic
- [x] Recognition gain after combat
- [x] Post-battle toast notification
- [x] Local save/load at save points
- [x] HUD displaying HP and Recognition

## Known Limitations

- Placeholder colored rectangles instead of sprites
- Single room only (no room transitions)
- One enemy type (Tomb Shade)
- One skill (Deep Echo)
- No inventory or equipment system
- No game over screen (restart required if HP reaches 0)
- No audio yet
- Combat UI covers full screen (no spatial combat view)

## VS Code / Editor Checklist

For VS Code users with Godot Tools extension:
1. Install "Godot Tools" extension
2. Set the Godot executable path in extension settings
3. GDScript files will have syntax highlighting and autocompletion

## Development Notes

### Autoloads
The game uses three autoload singletons:
- `GameManager` - Global game state, player data, scene transitions
- `TurnManager` - Combat flow, turn order, skill execution
- `SaveManager` - Local save/load to `user://save_data.json`

### Adding New Skills
Edit `data/skills.json` to add new skills:
```json
{
  "skill_id": {
    "id": "skill_id",
    "name": "Skill Name",
    "description": "Skill description",
    "base_damage": 20,
    "overload_cost": 25,
    "type": "magic",
    "element": "void"
  }
}
```

### Adding New Enemies
Edit `data/enemies.json`:
```json
{
  "enemy_id": {
    "id": "enemy_id",
    "name": "Enemy Name",
    "hp": 50,
    "max_hp": 50,
    "attack": 10,
    "defense": 2,
    "recognition_value": 15
  }
}
```

## License

[Add license information here]
