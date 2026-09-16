extends SceneTree
## Run: godot --headless --path . -s res://scripts/tests/cyclops_logic_test.gd

var _failed := false
var GS: Node

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	GS = root.get_node("GameState")
	GS.inventory.clear()
	GS.flags.clear()
	GS.add_item("wine")
	GS.set_flag("gave_nobody_name", true)
	_expect(GS.has_item("wine"), "start wine")
	GS.remove_item("wine")
	GS.set_flag("polyphemus_drunk", true)
	GS.set_flag("polyphemus_asleep", true)
	GS.add_item("olive_wood")
	GS.remove_item("olive_wood")
	GS.add_item("stake")
	GS.remove_item("stake")
	GS.add_item("hot_stake")
	GS.remove_item("hot_stake")
	GS.set_flag("polyphemus_blinded", true)
	GS.set_flag("polyphemus_asleep", false)
	GS.add_item("sheep_disguise")
	GS.set_flag("hiding_under_sheep", true)
	GS.set_flag("cyclops_escaped", true)
	_expect(GS.get_flag("cyclops_escaped"), "escaped")
	_expect(GS.get_flag("polyphemus_blinded"), "blinded")
	_expect(not GS.has_item("wine"), "wine consumed")
	if _failed:
		print("CYCLOPS_LOGIC_TEST_FAIL")
		quit(1)
	else:
		print("CYCLOPS_LOGIC_TEST_OK")
		quit(0)

func _expect(cond: bool, label: String) -> void:
	if not cond:
		_failed = true
		push_error("FAIL: " + label)
