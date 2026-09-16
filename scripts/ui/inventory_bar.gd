extends HBoxContainer
## Chunky inventory tokens — VGA inventory strip (MI2-era feel).

func _ready() -> void:
	add_theme_constant_override("separation", 2)
	GameState.inventory_changed.connect(_rebuild)
	GameState.selected_item_changed.connect(func(_id): _rebuild())
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	for item_id in GameState.inventory:
		var btn := Button.new()
		btn.text = _short_name(item_id)
		btn.tooltip_text = GameState.item_display_name(item_id)
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(44, 24)
		btn.toggle_mode = true
		btn.button_pressed = (GameState.selected_item == item_id)
		btn.add_theme_font_size_override("font_size", 7)
		_style_item(btn, GameState.selected_item == item_id)
		btn.pressed.connect(_on_item_pressed.bind(item_id))
		add_child(btn)
	if GameState.inventory.is_empty():
		var empty := Label.new()
		empty.text = "(none)"
		empty.add_theme_font_size_override("font_size", 8)
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.65))
		add_child(empty)

func _short_name(item_id: String) -> String:
	match item_id:
		"olive_wood":
			return "Wood"
		"stake":
			return "Stake"
		"hot_stake":
			return "HotStake"
		"wine":
			return "Wine"
		"sheep_disguise":
			return "Fleece"
		_:
			return item_id.left(8)

func _style_item(btn: Button, selected: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.12, 0.05) if not selected else Color(0.45, 0.3, 0.1)
	sb.border_color = Color(0.9, 0.75, 0.3) if selected else Color(0.5, 0.4, 0.25)
	sb.set_border_width_all(1)
	sb.set_content_margin_all(2)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("focus", sb)
	btn.add_theme_color_override("font_color", Color(0.95, 0.9, 0.7))

func _on_item_pressed(item_id: String) -> void:
	if GameState.selected_item == item_id:
		GameState.clear_selected_item()
		return
	GameState.select_item(item_id)
	if GameState.current_verb != GameState.Verb.GIVE:
		GameState.set_verb(GameState.Verb.USE)
