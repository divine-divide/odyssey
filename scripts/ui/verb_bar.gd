extends GridContainer
## Classic SCUMM 3×2 verb grid — chunky VGA labels, Tiny5 pixel font.

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
		PixelUI.apply_button(btn, PixelUI.SIZE_UI)
		btn.pressed.connect(_on_verb_pressed.bind(verb))
		_style_verb_button(btn, false)
		add_child(btn)
		_buttons[verb] = btn
	GameState.verb_changed.connect(_on_verb_changed)
	_on_verb_changed(GameState.current_verb)

func _style_verb_button(btn: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	# Deep indigo bar always; selected = warm yellow text (docs/ART.md), not purple.
	normal.bg_color = PixelUI.INDIGO
	normal.border_color = PixelUI.INDIGO_BORDER_SEL if selected else PixelUI.INDIGO_BORDER
	normal.set_border_width_all(1)
	normal.set_content_margin_all(2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("focus", normal)
	var fc := PixelUI.VERB_SELECTED if selected else PixelUI.VERB_IDLE
	btn.add_theme_color_override("font_color", fc)
	btn.add_theme_color_override("font_pressed_color", PixelUI.VERB_SELECTED)
	btn.add_theme_color_override("font_hover_color", PixelUI.VERB_HOVER)

func _on_verb_pressed(verb: int) -> void:
	GameState.set_verb(verb)

func _on_verb_changed(verb: int) -> void:
	for v in _buttons:
		_buttons[v].button_pressed = (v == verb)
		_style_verb_button(_buttons[v], v == verb)
