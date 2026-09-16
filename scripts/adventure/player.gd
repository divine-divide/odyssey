class_name AdventurePlayer
extends Node2D
## Simple walk-to cursor avatar for point-and-click rooms.

signal arrived

@export var move_speed: float = 280.0

var _target: Vector2
var _moving: bool = false
var _walk_timer: float = 0.0
var _sprite: Sprite2D
var _tex_idle: Texture2D
var _tex_walk1: Texture2D
var _tex_walk2: Texture2D
var _tex_walk3: Texture2D

func _ready() -> void:
	_target = position
	_sprite = get_node_or_null("Visual") as Sprite2D
	_tex_idle = load("res://assets/cyclops/odysseus_idle.png")
	_tex_walk1 = load("res://assets/cyclops/odysseus_walk1.png")
	_tex_walk2 = load("res://assets/cyclops/odysseus_walk2.png")
	_tex_walk3 = load("res://assets/cyclops/odysseus_walk3.png")
	_apply_idle()

func _process(delta: float) -> void:
	if not _moving:
		_apply_idle()
		return
	var to_target := _target - position
	var dist := to_target.length()
	if dist <= move_speed * delta:
		position = _target
		_moving = false
		_apply_idle()
		arrived.emit()
		return
	if absf(to_target.x) > 0.1 and _sprite:
		_sprite.flip_h = to_target.x < 0.0
	position += to_target.normalized() * move_speed * delta
	_walk_timer += delta
	_apply_walk_frame()

func walk_to(world_pos: Vector2) -> void:
	_target = world_pos
	_moving = true
	_walk_timer = 0.0

func snap_to(world_pos: Vector2) -> void:
	position = world_pos
	_target = world_pos
	_moving = false
	_apply_idle()

func is_moving() -> bool:
	return _moving

func _apply_idle() -> void:
	if _sprite and _tex_idle:
		_sprite.texture = _tex_idle

func _apply_walk_frame() -> void:
	if _sprite == null:
		return
	var frames: Array = [_tex_walk1, _tex_walk2]
	if _tex_walk3:
		frames.append(_tex_walk3)
	var frame := int(_walk_timer * 8.0) % frames.size()
	var tex: Texture2D = frames[frame]
	if tex:
		_sprite.texture = tex
