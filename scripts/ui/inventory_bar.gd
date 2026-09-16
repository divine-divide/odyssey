extends HBoxContainer
## Clickable inventory slots. Selecting an item arms Use/Give.

func _ready() -> void:
	GameState.inventory_changed.connect(_rebuild)
	GameState.selected_item_changed.connect(func(_id): _rebuild())
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	for item_id in GameState.inventory:
		var btn := Button.new()
		btn.text = GameState.item_display_name(item_id)
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(120, 36)
		btn.toggle_mode = true
		btn.button_pressed = (GameState.selected_item == item_id)
		btn.pressed.connect(_on_item_pressed.bind(item_id))
		add_child(btn)
	if GameState.inventory.is_empty():
		var empty := Label.new()
		empty.text = "(empty)"
		empty.modulate = Color(0.7, 0.7, 0.8)
		add_child(empty)

func _on_item_pressed(item_id: String) -> void:
	if GameState.selected_item == item_id:
		GameState.clear_selected_item()
		return
	GameState.select_item(item_id)
	# Arm Use by default when picking an inventory item (Monkey Island feel).
	if GameState.current_verb != GameState.Verb.GIVE:
		GameState.set_verb(GameState.Verb.USE)
