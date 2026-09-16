extends Label
## Bottom command / narration line — pixel font.

var _tween: Tween

func _ready() -> void:
	PixelUI.apply_label(self, PixelUI.SIZE_UI)
	text = ""
	GameState.message_requested.connect(show_message)
	GameState.verb_changed.connect(func(_v): _refresh_prompt())
	GameState.selected_item_changed.connect(func(_i): _refresh_prompt())

func show_message(msg: String) -> void:
	text = msg
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(3.2)
	_tween.tween_callback(_refresh_prompt)

func _refresh_prompt() -> void:
	text = GameState.verb_phrase() + "..."

func set_hover_target(target_name: String) -> void:
	if target_name == "":
		_refresh_prompt()
	else:
		text = "%s %s" % [GameState.verb_phrase(), target_name]
