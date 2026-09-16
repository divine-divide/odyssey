extends Node
## Simple branching dialogue trees for Talk interactions.

signal dialogue_started
signal dialogue_ended
signal line_shown(speaker: String, text: String)
signal choices_shown(choices: Array)

var _tree: Dictionary = {}
var _node_id: String = ""
var _visible_choices: Array = []
var active: bool = false

func start(tree: Dictionary, start_node: String = "start") -> void:
	if active:
		return
	_tree = tree
	_node_id = start_node
	active = true
	GameState.dialogue_open = true
	GameState.input_locked = true
	dialogue_started.emit()
	_present_node()

func choose(index: int) -> void:
	if not active:
		return
	if index < 0 or index >= _visible_choices.size():
		return
	var choice: Dictionary = _visible_choices[index]
	_apply_side_effects(choice)
	var next: String = str(choice.get("next", ""))
	if next == "" or next == "end":
		end_dialogue()
		return
	_node_id = next
	_present_node()

func end_dialogue() -> void:
	active = false
	_tree = {}
	_node_id = ""
	_visible_choices = []
	GameState.dialogue_open = false
	GameState.input_locked = false
	dialogue_ended.emit()

func _present_node() -> void:
	var node: Dictionary = _tree.get(_node_id, {})
	if node.is_empty():
		end_dialogue()
		return
	_apply_side_effects(node)
	var speaker := str(node.get("speaker", ""))
	var text := str(node.get("text", ""))
	line_shown.emit(speaker, text)
	var choices: Array = node.get("choices", [])
	_visible_choices = []
	if choices.is_empty():
		choices_shown.emit([])
	else:
		for c in choices:
			if c is Dictionary and _choice_available(c):
				_visible_choices.append(c)
		choices_shown.emit(_visible_choices)

func continue_line() -> void:
	if not active:
		return
	var node: Dictionary = _tree.get(_node_id, {})
	var choices: Array = node.get("choices", [])
	if not choices.is_empty():
		return
	var next: String = str(node.get("next", "end"))
	if next == "" or next == "end":
		end_dialogue()
		return
	_node_id = next
	_present_node()

func _apply_side_effects(data: Dictionary) -> void:
	if data.has("set_flag"):
		GameState.set_flag(str(data["set_flag"]), true)
	if data.has("clear_flag"):
		GameState.set_flag(str(data["clear_flag"]), false)
	if data.has("add_item"):
		GameState.add_item(str(data["add_item"]))
	if data.has("remove_item"):
		GameState.remove_item(str(data["remove_item"]))
	if data.has("say"):
		GameState.say(str(data["say"]))

func _choice_available(choice: Dictionary) -> bool:
	if choice.has("require_flag") and not GameState.get_flag(str(choice["require_flag"])):
		return false
	if choice.has("forbid_flag") and GameState.get_flag(str(choice["forbid_flag"])):
		return false
	if choice.has("require_item") and not GameState.has_item(str(choice["require_item"])):
		return false
	return true
