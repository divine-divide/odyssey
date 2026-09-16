extends HBoxContainer
## SCUMM-style verb bar: Walk / Look / Talk / Use / Pick Up / Give

const VERBS := [
	[GameState.Verb.WALK, "Walk"],
	[GameState.Verb.LOOK, "Look"],
	[GameState.Verb.TALK, "Talk"],
	[GameState.Verb.USE, "Use"],
	[GameState.Verb.PICK_UP, "Pick Up"],
	[GameState.Verb.GIVE, "Give"],
]

var _buttons: Dictionary = {}

func _ready() -> void:
	for entry in VERBS:
		var verb: int = entry[0]
		var label: String = entry[1]
		var btn := Button.new()
		btn.text = label
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(96, 36)
		btn.pressed.connect(_on_verb_pressed.bind(verb))
		add_child(btn)
		_buttons[verb] = btn
	GameState.verb_changed.connect(_on_verb_changed)
	_on_verb_changed(GameState.current_verb)

func _on_verb_pressed(verb: int) -> void:
	GameState.set_verb(verb)

func _on_verb_changed(verb: int) -> void:
	for v in _buttons:
		_buttons[v].button_pressed = (v == verb)
