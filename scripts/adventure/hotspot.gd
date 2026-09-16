class_name Hotspot
extends Area2D
## Clickable adventure hotspot. Room scripts handle verb responses via signals.

signal hotspot_clicked(hotspot: Hotspot)
signal hotspot_hovered(hotspot: Hotspot, hovering: bool)

@export var hotspot_id: String = ""
@export var display_name: String = "Something"
@export var walk_enabled: bool = true
@export var enabled: bool = true

@onready var _shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	monitoring = true
	monitorable = true

func set_hotspot_enabled(value: bool) -> void:
	enabled = value
	visible = value
	if _shape:
		_shape.disabled = not value

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled or GameState.input_locked or GameState.dialogue_open:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hotspot_clicked.emit(self)
		get_viewport().set_input_as_handled()

func _on_mouse_entered() -> void:
	if enabled and not GameState.dialogue_open:
		hotspot_hovered.emit(self, true)

func _on_mouse_exited() -> void:
	hotspot_hovered.emit(self, false)
