extends Control
## Dialogue line + choice list overlay.

@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/Margin/VBox/Speaker
@onready var line_label: Label = $Panel/Margin/VBox/Line
@onready var choices_box: VBoxContainer = $Panel/Margin/VBox/Choices
@onready var continue_btn: Button = $Panel/Margin/VBox/Continue

func _ready() -> void:
	visible = false
	continue_btn.pressed.connect(_on_continue)
	DialogueManager.dialogue_started.connect(_on_started)
	DialogueManager.dialogue_ended.connect(_on_ended)
	DialogueManager.line_shown.connect(_on_line)
	DialogueManager.choices_shown.connect(_on_choices)

func _on_started() -> void:
	visible = true

func _on_ended() -> void:
	visible = false
	_clear_choices()

func _on_line(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	speaker_label.visible = speaker != ""
	line_label.text = text

func _on_choices(choices: Array) -> void:
	_clear_choices()
	if choices.is_empty():
		continue_btn.visible = true
		return
	continue_btn.visible = false
	var i := 0
	for c in choices:
		var btn := Button.new()
		btn.text = str(c.get("text", "..."))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_choice.bind(i))
		choices_box.add_child(btn)
		i += 1

func _on_choice(index: int) -> void:
	# Map visible button index to filtered choices — DialogueManager filters again
	# by re-reading; pass the index among currently shown buttons.
	DialogueManager.choose(index)

func _on_continue() -> void:
	DialogueManager.continue_line()

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()
