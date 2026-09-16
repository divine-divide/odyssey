extends GridContainer
## Classic SCUMM 3×2 verb grid — chunky VGA labels, no modern chrome.

const VERBS := [
	[GameState.Verb.WALK, "Walk to"],
	[GameState.Verb.LOOK, "Look at"],
	[GameState.Verb.TALK, "Talk to"],
	[GameState.Verb.USE, "Use"],
	[GameState.Verb.PICK_UP, "Pick up"],
	[GameState.Verb.GIVE, "Give"],
]

var _buttons: Dictionary = {}

func _ready() -> void:
	columns = 3
	add_theme_constant_override("h_separation", 2)
	add_theme_constant_override("v_separation", 2)
	for entry in VERBS:
		var verb: int = entry[0]
		var label: String = entry[1]
		var btn := Button.new()
		btn.text = label
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(52, 16)
		btn.add_theme_font_size_override("font_size", 8)
		btn.pressed.connect(_on_verb_pressed.bind(verb))
		_style_verb_button(btn, false)
		add_child(btn)
		_buttons[verb] = btn
	GameState.verb_changed.connect(_on_verb_changed)
	_on_verb_changed(GameState.current_verb)

func _style_verb_button(btn: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.05, 0.05, 0.4) if not selected else Color(0.25, 0.15, 0.55)
	normal.border_color = Color(0.7, 0.7, 0.9) if selected else Color(0.35, 0.35, 0.55)
	normal.set_border_width_all(1)
	normal.set_content_margin_all(2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("focus", normal)
	btn.add_theme_color_override("font_color", Color(0.95, 0.95, 0.55) if selected else Color(0.75, 0.75, 0.95))
	btn.add_theme_color_override("font_pressed_color", Color(0.95, 0.95, 0.55))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.7))

func _on_verb_pressed(verb: int) -> void:
	GameState.set_verb(verb)

func _on_verb_changed(verb: int) -> void:
	for v in _buttons:
		_buttons[v].button_pressed = (v == verb)
		_style_verb_button(_buttons[v], v == verb)
