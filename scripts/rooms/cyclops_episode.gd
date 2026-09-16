extends Node
## Cyclops episode controller: multi-room puzzle chain + dialogue trees.

const ROOM_EXTERIOR := "cave_exterior"
const ROOM_INTERIOR := "cave_interior"

@onready var room_host: Node2D = $RoomHost
@onready var player: AdventurePlayer = $RoomHost/Player
@onready var message_line: Label = %MessageLine

var _rooms: Dictionary = {}
var _pending_action: Callable
var _polyphemus_tree := {}

func _ready() -> void:
	_build_dialogue()
	_rooms[ROOM_EXTERIOR] = preload("res://scenes/rooms/cyclops/cave_exterior.tscn")
	_rooms[ROOM_INTERIOR] = preload("res://scenes/rooms/cyclops/cave_interior.tscn")
	GameState.room_change_requested.connect(_on_room_change)
	GameState.adventure_won.connect(_on_won)
	GameState.flags_changed.connect(_refresh_hotspots)
	# Start episode
	if not GameState.get_flag("episode_started"):
		GameState.set_flag("episode_started", true)
		GameState.say("The black ships lie offshore. Ahead: the cave of the Cyclops.")
	_load_room(GameState.current_room)

func _on_room_change(room_id: String) -> void:
	_load_room(room_id)

func _load_room(room_id: String) -> void:
	for child in room_host.get_children():
		if child != player:
			child.queue_free()
	await get_tree().process_frame
	if not _rooms.has(room_id):
		push_error("Unknown room: " + room_id)
		return
	var room: Node2D = _rooms[room_id].instantiate()
	room_host.add_child(room)
	room_host.move_child(player, -1)
	player.snap_to(room.get_node("PlayerSpawn").position)
	_wire_hotspots(room)
	_refresh_hotspots()
	GameState.current_room = room_id

func _wire_hotspots(room: Node) -> void:
	for hotspot in room.find_children("*", "Hotspot", true, false):
		if not hotspot.hotspot_clicked.is_connected(_on_hotspot_clicked):
			hotspot.hotspot_clicked.connect(_on_hotspot_clicked)
		if not hotspot.hotspot_hovered.is_connected(_on_hotspot_hovered):
			hotspot.hotspot_hovered.connect(_on_hotspot_hovered)
	# Floor walk
	if room.has_node("Floor"):
		var floor_area: Area2D = room.get_node("Floor")
		if not floor_area.input_event.is_connected(_on_floor_input):
			floor_area.input_event.connect(_on_floor_input)

func _on_floor_input(_vp: Node, event: InputEvent, _idx: int) -> void:
	if GameState.input_locked or GameState.dialogue_open:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if GameState.current_verb == GameState.Verb.WALK:
			player.walk_to(room_host.get_local_mouse_position())

func _on_hotspot_hovered(hotspot: Hotspot, hovering: bool) -> void:
	if message_line and message_line.has_method("set_hover_target"):
		message_line.set_hover_target(hotspot.display_name if hovering else "")

func _on_hotspot_clicked(hotspot: Hotspot) -> void:
	if GameState.input_locked or GameState.dialogue_open:
		return
	var dest := hotspot.position
	if hotspot.walk_enabled:
		player.walk_to(dest)
		_pending_action = func(): _handle_verb(hotspot)
		if not player.arrived.is_connected(_on_player_arrived):
			player.arrived.connect(_on_player_arrived, CONNECT_ONE_SHOT)
	else:
		_handle_verb(hotspot)

func _on_player_arrived() -> void:
	if _pending_action.is_valid():
		_pending_action.call()
		_pending_action = Callable()

func _handle_verb(hotspot: Hotspot) -> void:
	var id := hotspot.hotspot_id
	match GameState.current_verb:
		GameState.Verb.WALK:
			if id in ["enter_cave", "cave_mouth"]:
				_try_enter_cave()
			elif id == "exit_to_sea":
				GameState.change_room(ROOM_EXTERIOR)
				GameState.say("You step back into the salt air.")
			elif id == "boulder" and GameState.get_flag("hiding_under_sheep") and GameState.get_flag("polyphemus_blinded"):
				_escape()
			else:
				GameState.say("You walk toward the %s." % hotspot.display_name)
		GameState.Verb.LOOK:
			_look(id, hotspot.display_name)
		GameState.Verb.TALK:
			_talk(id)
		GameState.Verb.PICK_UP:
			_pick_up(id)
		GameState.Verb.USE:
			_use(id)
		GameState.Verb.GIVE:
			_give(id)

func _look(id: String, fallback: String) -> void:
	match id:
		"cave_mouth":
			GameState.say("A yawning cave mouth in the cliff. Sheep bleat within.")
		"ship":
			GameState.say("Your black ship waits beyond the surf. Escape — eventually.")
		"polyphemus":
			if GameState.get_flag("polyphemus_blinded"):
				GameState.say("The Cyclops howls, clutching his ruined eye.")
			elif GameState.get_flag("polyphemus_asleep"):
				GameState.say("Polyphemus snores like an earthquake, dead drunk.")
			else:
				GameState.say("A towering one-eyed giant. He reeks of sheep and rage.")
		"olive_wood":
			GameState.say("A stout olive trunk, thick as a ship's mast. Good for a spear.")
		"fire":
			GameState.say("A cook-fire smolders. Coals glow hot enough to harden wood.")
		"sheep":
			if GameState.get_flag("polyphemus_blinded"):
				GameState.say("Fat rams. Wide enough to hide a man beneath...")
			else:
				GameState.say("Woolly sheep mill about the cave. Dinner, to the Cyclops.")
		"boulder":
			if GameState.get_flag("cave_open"):
				GameState.say("The great stone is rolled aside. Daylight spills in.")
			else:
				GameState.say("A boulder seals the cave — only the Cyclops can move it.")
		"exit_to_sea":
			GameState.say("The path back to the beach and your waiting crew.")
		"enter_cave":
			GameState.say("Darkness and the smell of cheese and danger.")
		_:
			GameState.say("You see nothing special about the %s." % fallback)

func _talk(id: String) -> void:
	match id:
		"polyphemus":
			if GameState.get_flag("polyphemus_blinded"):
				GameState.say("He only roars. Talking is finished.")
			elif GameState.get_flag("polyphemus_asleep"):
				GameState.say("He is past conversation — for now.")
			else:
				DialogueManager.start(_polyphemus_tree, "start")
		"sheep":
			GameState.say("Baa. They have nothing useful to say.")
		"ship":
			GameState.say("Your men shout from the shore: \"Don't linger, captain!\"")
		_:
			GameState.say("That doesn't want to talk.")

func _pick_up(id: String) -> void:
	match id:
		"olive_wood":
			if GameState.get_flag("took_olive_wood") or GameState.has_item("olive_wood") or GameState.has_item("stake") or GameState.has_item("hot_stake"):
				GameState.say("You already took what you need from the woodpile.")
			else:
				GameState.add_item("olive_wood")
				GameState.set_flag("took_olive_wood", true)
				GameState.say("You haul a heavy length of olive wood into your pack.")
				_refresh_hotspots()
		"sheep":
			if GameState.get_flag("polyphemus_blinded"):
				if not GameState.has_item("sheep_disguise"):
					GameState.add_item("sheep_disguise")
				GameState.set_flag("hiding_under_sheep", true)
				GameState.say("You cling under a great ram. Now wait by the boulder for dawn.")
				_refresh_hotspots()
			elif GameState.has_item("sheep_disguise"):
				GameState.say("You're already under a sheep.")
			else:
				GameState.say("The sheep shy away. Not yet — wait for your moment.")
		"wine":
			GameState.say("You already carry the Maronean wine.")
		_:
			GameState.say("You can't pick that up.")

func _use(id: String) -> void:
	var item := GameState.selected_item
	if item == "":
		# Use without item — contextual
		match id:
			"enter_cave", "cave_mouth":
				_try_enter_cave()
			"exit_to_sea":
				GameState.change_room(ROOM_EXTERIOR)
				GameState.say("You step back into the salt air.")
			"boulder":
				if GameState.get_flag("hiding_under_sheep") and GameState.get_flag("polyphemus_blinded"):
					_escape()
				elif GameState.get_flag("polyphemus_blinded"):
					GameState.say("He will open it at dawn. Hide first.")
				else:
					GameState.say("Only Polyphemus can roll that stone.")
			"sheep":
				if GameState.get_flag("polyphemus_blinded"):
					_pick_up("sheep")
				else:
					GameState.say("Use what with the sheep?")
			_:
				GameState.say("Use what?")
		return

	# Use item WITH hotspot
	match [item, id]:
		["olive_wood", "fire"], ["olive_wood", "olive_wood"]:
			# Sharpen into stake at fire / work the wood
			GameState.remove_item("olive_wood")
			GameState.add_item("stake")
			GameState.set_flag("carved_stake", true)
			GameState.say("You carve and harden a long pointed stake.")
			GameState.clear_selected_item()
		["stake", "fire"]:
			GameState.remove_item("stake")
			GameState.add_item("hot_stake")
			GameState.set_flag("stake_heated", true)
			GameState.say("The tip glows in the coals — a burning stake.")
			GameState.clear_selected_item()
		["hot_stake", "polyphemus"], ["stake", "polyphemus"]:
			if not GameState.get_flag("polyphemus_asleep"):
				GameState.say("He'd crush you. Get him drunk first.")
			elif item == "stake" and not GameState.has_item("hot_stake"):
				GameState.say("The tip should be hotter. Use the stake on the fire.")
			else:
				GameState.remove_item("hot_stake")
				if GameState.has_item("stake"):
					GameState.remove_item("stake")
				GameState.set_flag("polyphemus_blinded", true)
				GameState.set_flag("polyphemus_asleep", false)
				GameState.set_flag("cave_open", false)
				GameState.clear_selected_item()
				GameState.say("You drive the burning stake into his eye! He bellows — Nobody has ruined me!")
				_refresh_hotspots()
		["wine", "polyphemus"]:
			_give_wine()
		["sheep_disguise", "boulder"], ["sheep_disguise", "sheep"]:
			if GameState.get_flag("polyphemus_blinded"):
				GameState.set_flag("hiding_under_sheep", true)
				GameState.say("Hidden under the ram, you wait for the stone to roll.")
				_refresh_hotspots()
			else:
				GameState.say("Not yet.")
		_:
			GameState.say("That doesn't work.")

func _give(id: String) -> void:
	var item := GameState.selected_item
	if item == "":
		GameState.say("Give what?")
		return
	if id == "polyphemus" and item == "wine":
		_give_wine()
		return
	if id == "polyphemus":
		GameState.say("He scoffs at your offering.")
		return
	GameState.say("They don't want that.")

func _give_wine() -> void:
	if GameState.get_flag("polyphemus_drunk"):
		GameState.say("He's already had his fill of the dark wine.")
		return
	if not GameState.has_item("wine"):
		GameState.say("You have no wine left.")
		return
	if not GameState.get_flag("gave_nobody_name"):
		GameState.say("Speak with him first — learn the custom of guest-gifts.")
		return
	GameState.remove_item("wine")
	GameState.set_flag("polyphemus_drunk", true)
	GameState.set_flag("polyphemus_asleep", true)
	GameState.clear_selected_item()
	GameState.say("He gulps the Maronean wine, laughs, then topples into drunken sleep.")
	_refresh_hotspots()

func _try_enter_cave() -> void:
	if GameState.get_flag("cyclops_escaped"):
		GameState.say("You will not return to that cave.")
		return
	GameState.change_room(ROOM_INTERIOR)
	if not GameState.get_flag("entered_cave"):
		GameState.set_flag("entered_cave", true)
		GameState.say("Inside: cheese, pens, and a giant who calls this home.")

func _escape() -> void:
	GameState.set_flag("cave_open", true)
	GameState.set_flag("hiding_under_sheep", true)
	GameState.remove_item("sheep_disguise")
	GameState.say("Dawn. He rolls the stone, pats each sheep. The ram carries you out!")
	GameState.change_room(ROOM_EXTERIOR)
	GameState.win_adventure()

func _on_won() -> void:
	GameState.say("FREE! You race for the ships. Next: the isle of Aeolus... (Episode complete)")

func _refresh_hotspots() -> void:
	var room := _current_room_node()
	if room == null:
		return
	_set_hs(room, "olive_wood", not (GameState.get_flag("took_olive_wood") or GameState.has_item("olive_wood") or GameState.has_item("stake") or GameState.has_item("hot_stake")))
	# Visual state labels if present
	if room.has_node("PolyphemusLabel"):
		var lbl: Label = room.get_node("PolyphemusLabel")
		if GameState.get_flag("polyphemus_blinded"):
			lbl.text = "Polyphemus\n(BLINDED)"
			lbl.modulate = Color(0.9, 0.3, 0.3)
		elif GameState.get_flag("polyphemus_asleep"):
			lbl.text = "Polyphemus\n(ASLEEP)"
			lbl.modulate = Color(0.6, 0.6, 1.0)
		else:
			lbl.text = "Polyphemus"
			lbl.modulate = Color.WHITE
	if room.has_node("StatusLabel"):
		var status: Label = room.get_node("StatusLabel")
		var bits: PackedStringArray = []
		if GameState.get_flag("gave_nobody_name"):
			bits.append("Name: Nobody")
		if GameState.get_flag("polyphemus_drunk"):
			bits.append("Drunk")
		if GameState.get_flag("polyphemus_blinded"):
			bits.append("Blinded")
		if GameState.get_flag("hiding_under_sheep"):
			bits.append("Under sheep")
		if GameState.get_flag("cyclops_escaped"):
			bits.append("ESCAPED!")
		status.text = "  |  ".join(bits)

func _set_hs(room: Node, id: String, on: bool) -> void:
	for hotspot in room.find_children("*", "Hotspot", true, false):
		if hotspot.hotspot_id == id:
			hotspot.set_hotspot_enabled(on)

func _current_room_node() -> Node:
	for child in room_host.get_children():
		if child != player and child is Node2D:
			return child
	return null

func _build_dialogue() -> void:
	_polyphemus_tree = {
		"start": {
			"speaker": "Polyphemus",
			"text": "Strangers in my cave? Who are you, and where is your ship?",
			"choices": [
				{"text": "We are lost sailors. Our ship is wrecked.", "next": "lie_ship"},
				{"text": "I am Odysseus of Ithaca, here for guest-right.", "next": "true_name", "forbid_flag": "gave_nobody_name"},
				{"text": "Call me Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "Never mind.", "next": "end"},
			],
		},
		"lie_ship": {
			"speaker": "Polyphemus",
			"text": "Good. Then none will miss you. I may eat you last.",
			"choices": [
				{"text": "Perhaps a gift of wine would please you?", "next": "wine_hint", "require_item": "wine"},
				{"text": "What is your name, great Cyclops?", "next": "his_name"},
				{"text": "(Step back.)", "next": "end"},
			],
		},
		"true_name": {
			"speaker": "Polyphemus",
			"text": "Odysseus? I will remember that name when I crush your bones.",
			"set_flag": "revealed_true_name",
			"choices": [
				{"text": "On second thought — call me Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "(Leave him be.)", "next": "end"},
			],
		},
		"nobody": {
			"speaker": "Polyphemus",
			"text": "Nobody? Ha! Then Nobody shall be eaten last. Bring me a gift, little Nobody.",
			"set_flag": "gave_nobody_name",
			"choices": [
				{"text": "Offer the Maronean wine.", "next": "wine_accept", "require_item": "wine"},
				{"text": "I will find a worthy gift.", "next": "end"},
			],
		},
		"wine_hint": {
			"speaker": "Polyphemus",
			"text": "Wine? Give it, then. Guest-gifts bind even giants.",
			"choices": [
				{"text": "(Give him the wine.)", "next": "wine_accept", "require_item": "wine"},
				{"text": "Soon.", "next": "end"},
			],
		},
		"wine_accept": {
			"speaker": "Polyphemus",
			"text": "Ahhh — this is nectar! Tell me your name again, generous one...",
			"remove_item": "wine",
			"choices": [
				{"text": "Nobody.", "next": "drunk_end", "set_flag": "gave_nobody_name"},
			],
		},
		"drunk_end": {
			"speaker": "Polyphemus",
			"text": "Then I eat Nobody last—!  *hic*  ...zzzz...",
			"set_flag": "polyphemus_drunk",
			"next": "pass_out",
		},
		"pass_out": {
			"speaker": "",
			"text": "The Cyclops collapses in a drunken stupor. Time for the stake.",
			"set_flag": "polyphemus_asleep",
			"next": "end",
		},
		"his_name": {
			"speaker": "Polyphemus",
			"text": "I am Polyphemus, son of Poseidon. Fear me.",
			"choices": [
				{"text": "Call me Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "(Back away.)", "next": "end"},
			],
		},
	}
