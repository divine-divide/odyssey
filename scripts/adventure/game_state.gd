extends Node
## Global adventure state: verbs, inventory, flags, room transitions.

signal inventory_changed
signal flags_changed
signal verb_changed(verb: int)
signal selected_item_changed(item_id: String)
signal message_requested(text: String)
signal room_change_requested(room_id: String)
signal adventure_won

enum Verb { WALK, LOOK, TALK, USE, PICK_UP, GIVE }

const VERB_NAMES := {
	Verb.WALK: "Walk to",
	Verb.LOOK: "Look at",
	Verb.TALK: "Talk to",
	Verb.USE: "Use",
	Verb.PICK_UP: "Pick up",
	Verb.GIVE: "Give",
}

const ITEM_NAMES := {
	"olive_wood": "Olive Wood",
	"stake": "Wooden Stake",
	"hot_stake": "Burning Stake",
	"wine": "Maronean Wine",
	"sheep_disguise": "Sheep Fleece",
}

var current_verb: Verb = Verb.WALK
var inventory: Array[String] = []
var flags: Dictionary = {}
var selected_item: String = ""
var current_room: String = "cave_exterior"
var dialogue_open: bool = false
var input_locked: bool = false
## When true, room Title/StatusLabel show on playfield (dev only).
var debug_show_room_chrome: bool = false

func _ready() -> void:
	# Starting kit for Cyclops episode — wine brought from the ships.
	if not has_item("wine"):
		add_item("wine")

func set_verb(verb: Verb) -> void:
	if current_verb == verb:
		return
	current_verb = verb
	if verb != Verb.USE and verb != Verb.GIVE:
		clear_selected_item()
	verb_changed.emit(verb)

func verb_phrase() -> String:
	var base: String = VERB_NAMES.get(current_verb, "Walk to")
	if selected_item != "" and current_verb == Verb.USE:
		return "%s %s on" % [base, item_display_name(selected_item)]
	if selected_item != "" and current_verb == Verb.GIVE:
		return "%s %s to" % [base, item_display_name(selected_item)]
	return base

func item_display_name(item_id: String) -> String:
	return ITEM_NAMES.get(item_id, item_id.capitalize())

func has_item(item_id: String) -> bool:
	return item_id in inventory

func add_item(item_id: String) -> void:
	if item_id in inventory:
		return
	inventory.append(item_id)
	inventory_changed.emit()

func remove_item(item_id: String) -> void:
	var idx := inventory.find(item_id)
	if idx >= 0:
		inventory.remove_at(idx)
		if selected_item == item_id:
			clear_selected_item()
		inventory_changed.emit()

func select_item(item_id: String) -> void:
	selected_item = item_id
	selected_item_changed.emit(item_id)

func clear_selected_item() -> void:
	if selected_item == "":
		return
	selected_item = ""
	selected_item_changed.emit("")

func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value
	flags_changed.emit()

func get_flag(key: String, default: Variant = false) -> Variant:
	return flags.get(key, default)

func say(text: String) -> void:
	message_requested.emit(text)

func change_room(room_id: String) -> void:
	current_room = room_id
	room_change_requested.emit(room_id)

func win_adventure() -> void:
	set_flag("cyclops_escaped", true)
	adventure_won.emit()
