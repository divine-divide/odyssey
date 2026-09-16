class_name AdventurePlayer
extends Node2D
## Simple walk-to cursor avatar for point-and-click rooms.

signal arrived

@export var move_speed: float = 280.0

var _target: Vector2
var _moving: bool = false

func _ready() -> void:
	_target = position

func _process(delta: float) -> void:
	if not _moving:
		return
	var to_target := _target - position
	var dist := to_target.length()
	if dist <= move_speed * delta:
		position = _target
		_moving = false
		arrived.emit()
		return
	position += to_target.normalized() * move_speed * delta

func walk_to(world_pos: Vector2) -> void:
	_target = world_pos
	_moving = true

func snap_to(world_pos: Vector2) -> void:
	position = world_pos
	_target = world_pos
	_moving = false

func is_moving() -> bool:
	return _moving
