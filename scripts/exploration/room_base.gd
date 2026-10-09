extends Node2D
class_name RoomBase
## 房间基类 - 处理地砖和墙壁铺设

const TILE_SIZE := 32
const ROOM_WIDTH := 20
const ROOM_HEIGHT := 11

@export var room_seed: int = 12345
@export var auto_fill_floor: bool = true
@export var auto_fill_walls: bool = true
@export var gate_x_tiles: Array[int] = []

var floor_tiles: Array[Sprite2D] = []
var floor_tile_types: Array[int] = []
var wall_corner_refs: Array[Sprite2D] = []

var _floor_textures: Array[Texture2D] = []
var _wall_textures: Dictionary = {}


func _ready() -> void:
	_load_textures()
	if auto_fill_floor:
		call_deferred("_fill_floor")
	if auto_fill_walls:
		call_deferred("_fill_walls")


func _load_textures() -> void:
	_floor_textures = [
		load("res://assets/art/tiles/floor/tile_floor_stone_00.png"),
		load("res://assets/art/tiles/floor/tile_floor_stone_01.png"),
		load("res://assets/art/tiles/floor/tile_floor_stone_02.png")
	]
	_wall_textures = {
		"n": load("res://assets/art/tiles/wall/tile_wall_stone_n.png"),
		"s": load("res://assets/art/tiles/wall/tile_wall_stone_s.png"),
		"w": load("res://assets/art/tiles/wall/tile_wall_stone_w.png"),
		"e": load("res://assets/art/tiles/wall/tile_wall_stone_e.png"),
		"corner_nw": load("res://assets/art/tiles/wall/tile_wall_stone_corner_nw.png"),
		"corner_ne": load("res://assets/art/tiles/wall/tile_wall_stone_corner_ne.png"),
		"corner_sw": load("res://assets/art/tiles/wall/tile_wall_stone_corner_sw.png"),
		"corner_se": load("res://assets/art/tiles/wall/tile_wall_stone_corner_se.png"),
	}


func _fill_floor() -> void:
	var floor_container := get_node_or_null("Floor")
	if floor_container == null:
		floor_container = Node2D.new()
		floor_container.name = "Floor"
		floor_container.z_index = -10
		add_child(floor_container)
		move_child(floor_container, 0)
	
	for child in floor_container.get_children():
		if child is Sprite2D and child.name.begins_with("FloorTile_"):
			child.queue_free()
	
	floor_tiles.clear()
	floor_tile_types.clear()
	
	var rng := RandomNumberGenerator.new()
	rng.seed = room_seed
	
	for y in range(1, ROOM_HEIGHT - 1):
		for x in range(1, ROOM_WIDTH - 1):
			var tile_type := _get_random_floor_tile(rng)
			var sprite := Sprite2D.new()
			sprite.name = "FloorTile_%d_%d" % [x, y]
			sprite.texture = _floor_textures[tile_type]
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.centered = false
			sprite.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			floor_container.add_child(sprite)
			floor_tiles.append(sprite)
			floor_tile_types.append(tile_type)


func _fill_walls() -> void:
	var walls_node := get_node_or_null("Walls")
	if walls_node == null:
		return
	
	var wall_visuals := walls_node.get_node_or_null("WallVisuals")
	if wall_visuals == null:
		wall_visuals = Node2D.new()
		wall_visuals.name = "WallVisuals"
		wall_visuals.z_index = -5
		walls_node.add_child(wall_visuals)
	
	for child in wall_visuals.get_children():
		if child is Sprite2D and (child.name.begins_with("Wall_") or child.name.begins_with("Corner_")):
			child.queue_free()
	
	wall_corner_refs.clear()
	
	_add_corner(wall_visuals, "corner_nw", 0, 0)
	_add_corner(wall_visuals, "corner_ne", ROOM_WIDTH - 1, 0)
	_add_corner(wall_visuals, "corner_sw", 0, ROOM_HEIGHT - 1)
	_add_corner(wall_visuals, "corner_se", ROOM_WIDTH - 1, ROOM_HEIGHT - 1)
	
	for x in range(1, ROOM_WIDTH - 1):
		if x not in gate_x_tiles:
			_add_wall_tile(wall_visuals, "n", x, 0)
	
	for x in range(1, ROOM_WIDTH - 1):
		_add_wall_tile(wall_visuals, "s", x, ROOM_HEIGHT - 1)
	
	for y in range(1, ROOM_HEIGHT - 1):
		_add_wall_tile(wall_visuals, "w", 0, y)
	
	for y in range(1, ROOM_HEIGHT - 1):
		_add_wall_tile(wall_visuals, "e", ROOM_WIDTH - 1, y)


func _add_wall_tile(parent: Node, wall_type: String, tile_x: int, tile_y: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = "Wall_%s_%d_%d" % [wall_type, tile_x, tile_y]
	sprite.texture = _wall_textures[wall_type]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.position = Vector2(tile_x * TILE_SIZE, tile_y * TILE_SIZE)
	parent.add_child(sprite)
	return sprite


func _add_corner(parent: Node, corner_type: String, tile_x: int, tile_y: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = "Corner_%s" % corner_type
	sprite.texture = _wall_textures[corner_type]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.position = Vector2(tile_x * TILE_SIZE, tile_y * TILE_SIZE)
	parent.add_child(sprite)
	wall_corner_refs.append(sprite)
	return sprite


func _get_random_floor_tile(rng: RandomNumberGenerator) -> int:
	var roll := rng.randf() * 100.0
	if roll < 78.0:
		return 0
	elif roll < 90.0:
		return 1
	else:
		return 2


func get_floor_tile_count() -> int:
	return floor_tiles.size()


func get_used_floor_tile_types() -> Array[int]:
	var used: Array[int] = []
	for t in floor_tile_types:
		if not t in used:
			used.append(t)
	return used


func has_all_corners() -> bool:
	return wall_corner_refs.size() == 4
