extends Node
## Cyclops episode controller: multi-room puzzle chain + dialogue trees.
## Homer beat order: Nobody → wine → stake → blind → sheep → shore boast/curse.

const ROOM_EXTERIOR := "cave_exterior"
const ROOM_INTERIOR := "cave_interior"

@onready var room_host: Node2D = $RoomHost
@onready var player: AdventurePlayer = $RoomHost/Player
@onready var message_line: Label = %MessageLine

var _rooms: Dictionary = {}
var _pending_action: Callable
var _polyphemus_tree := {}
var _eurylochus_tree := {}
var _shore_coda_tree := {}

func _ready() -> void:
	_build_dialogue()
	_rooms[ROOM_EXTERIOR] = preload("res://scenes/rooms/cyclops/cave_exterior.tscn")
	_rooms[ROOM_INTERIOR] = preload("res://scenes/rooms/cyclops/cave_interior.tscn")
	GameState.room_change_requested.connect(_on_room_change)
	GameState.adventure_won.connect(_on_won)
	GameState.flags_changed.connect(_refresh_hotspots)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	_apply_pixel_ui_chrome()
	# Start episode
	if not GameState.get_flag("episode_started"):
		GameState.set_flag("episode_started", true)
		GameState.say("The black ships lie offshore. Inland waits the cave of the Cyclops — and the oldest mistake in hospitality.")
	_load_room(GameState.current_room)

func _apply_pixel_ui_chrome() -> void:
	var inv_label := get_node_or_null("UI/InvLabel") as Label
	if inv_label:
		PixelUI.apply_label(inv_label, PixelUI.SIZE_UI)

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
	_apply_room_debug_chrome(room)
	_refresh_hotspots()
	GameState.current_room = room_id

func _apply_room_debug_chrome(room: Node) -> void:
	# Title + StatusLabel: playfield hidden unless debug flag.
	if room.has_node("Title"):
		room.get_node("Title").visible = GameState.debug_show_room_chrome
	if room.has_node("StatusLabel"):
		room.get_node("StatusLabel").visible = GameState.debug_show_room_chrome
	# Always-on hotspot nameplates stay off — names only on sentence line.
	for hotspot in room.find_children("*", "Hotspot", true, false):
		var lbl := hotspot.get_node_or_null("Label")
		if lbl:
			lbl.visible = false
	if room.has_node("PolyphemusLabel"):
		room.get_node("PolyphemusLabel").visible = false

func _wire_hotspots(room: Node) -> void:
	for hotspot in room.find_children("*", "Hotspot", true, false):
		if not hotspot.hotspot_clicked.is_connected(_on_hotspot_clicked):
			hotspot.hotspot_clicked.connect(_on_hotspot_clicked)
		if not hotspot.hotspot_hovered.is_connected(_on_hotspot_hovered):
			hotspot.hotspot_hovered.connect(_on_hotspot_hovered)
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
			GameState.say("Your black ship frets at anchor. Escape is a plan, not a mood.")
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
				GameState.say("He only roars now. Words will not help him — or you, yet.")
			elif GameState.get_flag("polyphemus_asleep"):
				GameState.say("He sleeps the sleep of the over-wined. Do not wake the mountain.")
			else:
				DialogueManager.start(_polyphemus_tree, "start")
		"sheep":
			GameState.say("Baa. Loyal, woolly, and blessedly incurious.")
		"ship":
			if GameState.get_flag("cyclops_escaped") and not GameState.get_flag("shore_boast_done"):
				DialogueManager.start(_shore_coda_tree, "start")
			elif GameState.get_flag("shore_boast_done"):
				GameState.say("Eurylochus is already rewriting the story to make himself cautious and you lucky.")
			else:
				DialogueManager.start(_eurylochus_tree, "start")
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
				GameState.say("You bind yourself beneath a great ram. When he counts his flock, he will count you as wool.")
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

	match [item, id]:
		["olive_wood", "fire"], ["olive_wood", "olive_wood"]:
			GameState.remove_item("olive_wood")
			GameState.add_item("stake")
			GameState.set_flag("carved_stake", true)
			GameState.say("From the olive wood you shape a long stake, thick as a shipwright's spar.")
			GameState.clear_selected_item()
		["stake", "fire"]:
			GameState.remove_item("stake")
			GameState.add_item("hot_stake")
			GameState.set_flag("stake_heated", true)
			GameState.say("You harden the point in the fire until it glows — ready for one terrible thrust.")
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
				GameState.say("You drive the burning stake into his eye. He bellows that Nobody has ruined him — and the cave answers.")
				_refresh_hotspots()
		["wine", "polyphemus"]:
			_give_wine()
		["sheep_disguise", "boulder"], ["sheep_disguise", "sheep"]:
			if GameState.get_flag("polyphemus_blinded"):
				GameState.set_flag("hiding_under_sheep", true)
				GameState.say("Under the ram you wait for dawn, when he must roll the stone for his flocks.")
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
		GameState.say("He has drunk his fill. The wine has done its work.")
		return
	if not GameState.has_item("wine"):
		GameState.say("You have no wine left.")
		return
	if not GameState.get_flag("gave_nobody_name"):
		GameState.say("First the custom: give a name he will carry. Then the gift.")
		return
	GameState.remove_item("wine")
	GameState.set_flag("polyphemus_drunk", true)
	GameState.set_flag("polyphemus_asleep", true)
	GameState.clear_selected_item()
	GameState.say("He drinks the Maronean deep, praises the gift — then sleep takes him like a thrown net.")
	_refresh_hotspots()

func _try_enter_cave() -> void:
	if GameState.get_flag("cyclops_escaped"):
		GameState.say("You will not return to that cave.")
		return
	GameState.change_room(ROOM_INTERIOR)
	if not GameState.get_flag("entered_cave"):
		GameState.set_flag("entered_cave", true)
		GameState.say("Cheese, pens, and a giant's household. Guest-right hangs in the air like a dare.")

func _escape() -> void:
	GameState.set_flag("cave_open", true)
	GameState.set_flag("hiding_under_sheep", true)
	GameState.set_flag("cyclops_escaped", true)
	GameState.remove_item("sheep_disguise")
	GameState.say("Dawn. He rolls the stone aside and feels along the sheep. Your ram bears you out into the light.")
	GameState.change_room(ROOM_EXTERIOR)
	# Homer IX: boast comes on the shore — not as the in-cave win condition.
	DialogueManager.start(_shore_coda_tree, "start")

func _on_dialogue_ended() -> void:
	if GameState.get_flag("cyclops_escaped") and GameState.get_flag("shore_boast_done") and not GameState.get_flag("adventure_won_fired"):
		GameState.set_flag("adventure_won_fired", true)
		GameState.win_adventure()

func _on_won() -> void:
	GameState.say("Oars bite water. Behind you, a blinded giant's curse rides the wind toward Poseidon... (Episode complete)")

func _refresh_hotspots() -> void:
	var room := _current_room_node()
	if room == null:
		return
	_apply_room_debug_chrome(room)
	_set_hs(room, "olive_wood", not (GameState.get_flag("took_olive_wood") or GameState.has_item("olive_wood") or GameState.has_item("stake") or GameState.has_item("hot_stake")))
	if room.has_node("PolyphemusLabel") and GameState.debug_show_room_chrome:
		var lbl: Label = room.get_node("PolyphemusLabel")
		lbl.visible = true
		if GameState.get_flag("polyphemus_blinded"):
			lbl.text = "Polyphemus\n(BLINDED)"
			lbl.modulate = Color(0.9, 0.3, 0.3)
		elif GameState.get_flag("polyphemus_asleep"):
			lbl.text = "Polyphemus\n(ASLEEP)"
			lbl.modulate = Color(0.6, 0.6, 1.0)
		else:
			lbl.text = "Polyphemus"
			lbl.modulate = Color.WHITE
	if room.has_node("StatusLabel") and GameState.debug_show_room_chrome:
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
		if GameState.get_flag("shore_boast_done"):
			bits.append("Boast done")
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
			"text": "Strangers in my cave? Who are you — and where is your ship?",
			"choices": [
				{"text": "We are lost men. Poseidon wrecked our ship.", "next": "lie_ship"},
				{"text": "I am Odysseus of Ithaca. Grant us guest-right.", "next": "true_name", "forbid_flag": "gave_nobody_name"},
				{"text": "My name is Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "(Say nothing useful and step back.)", "next": "end"},
			],
		},
		"lie_ship": {
			"speaker": "Polyphemus",
			"text": "No ship left? Then none will come searching when I am done with you.",
			"choices": [
				{"text": "Perhaps a guest-gift of wine would please you?", "next": "wine_hint", "require_item": "wine"},
				{"text": "How are you called, great one?", "next": "his_name"},
				{"text": "Then hear this: I am Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "(Back toward the pens.)", "next": "end"},
			],
		},
		"true_name": {
			# Trap only — in-cave true name is NOT the win path (Homer: boast on shore).
			"speaker": "Polyphemus",
			"text": "Odysseus? I will remember that name — when I grind your bones.",
			"set_flag": "revealed_true_name",
			"choices": [
				{"text": "A jest. Call me Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "(Leave the name hanging and withdraw.)", "next": "end"},
			],
		},
		"nobody": {
			"speaker": "Polyphemus",
			"text": "Nobody? Then Nobody shall be eaten last. Bring me a gift worthy of that mercy, little Nobody.",
			"set_flag": "gave_nobody_name",
			"choices": [
				{"text": "Take this Maronean wine — a guest-gift.", "next": "wine_accept", "require_item": "wine"},
				{"text": "I will find a gift fit for you.", "next": "end"},
			],
		},
		"wine_hint": {
			"speaker": "Polyphemus",
			"text": "Wine? Name yourself by the custom, then give. Even I keep guest-law when it serves me.",
			"choices": [
				{"text": "I am Nobody. Drink.", "next": "wine_accept", "require_item": "wine", "set_flag": "gave_nobody_name"},
				{"text": "Very well — I am Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "The gift can wait.", "next": "end"},
			],
		},
		"wine_accept": {
			"speaker": "Polyphemus",
			"text": "Ahh — this is nectar after sheep's milk! Tell me your name again, generous one...",
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
			"text": "The Cyclops topples into drunken sleep. The fire still burns. The olive wood waits.",
			"set_flag": "polyphemus_asleep",
			"next": "end",
		},
		"his_name": {
			"speaker": "Polyphemus",
			"text": "I am Polyphemus, son of Poseidon. Fear that name.",
			"choices": [
				{"text": "And I am Nobody.", "next": "nobody", "set_flag": "gave_nobody_name"},
				{"text": "(Withdraw.)", "next": "end"},
			],
		},
	}

	_eurylochus_tree = {
		"start": {
			"speaker": "Eurylochus",
			"text": "Captain — the men are watching the cave like it owes them money. Tell me we are not going in.",
			"choices": [
				{"text": "We go as guests. Brief ones.", "next": "guests"},
				{"text": "Keep the ship ready. If dawn comes without me, row.", "next": "dawn"},
				{"text": "Your caution is noted, Eurylochus.", "next": "ready"},
				{"text": "Hold the line. I'll return.", "next": "end"},
			],
		},
		"guests": {
			"speaker": "Eurylochus",
			"text": "Guest-right with a Cyclops is a prayer with teeth.",
			"choices": [
				{"text": "Then we bring wine to the prayer.", "next": "wine_crew", "require_item": "wine"},
				{"text": "Stay with the ship.", "next": "end"},
			],
		},
		"dawn": {
			"speaker": "Eurylochus",
			"text": "Dawn. I'll have the oars wet and the excuses ready.",
			"choices": [
				{"text": "Good. Fear is useful if it keeps the hull ready.", "next": "end"},
			],
		},
		"ready": {
			"speaker": "Eurylochus",
			"text": "Ship's ready. Crew's pale. I'm practicing 'I told you so' under my breath.",
			"choices": [
				{"text": "Save it for open water.", "next": "end"},
			],
		},
		"wine_crew": {
			"speaker": "Eurylochus",
			"text": "Maronean wine for a giant. If this works, I'll call you clever. If not, I'll call you lunch.",
			"choices": [
				{"text": "Keep the ship. I'll keep the plan.", "next": "end"},
			],
		},
	}

	# Homer IX coda: after escape, boast the true name → curse
	_shore_coda_tree = {
		"start": {
			"speaker": "Eurylochus",
			"text": "You're out! By the gods — get aboard before he stacks the hills on us!",
			"choices": [
				{"text": "(To the cave mouth, loud:) Hear me, Cyclops!", "next": "boast"},
				{"text": "Silence. We row first, boast never.", "next": "cowed"},
			],
		},
		"cowed": {
			"speaker": "Eurylochus",
			"text": "Wise. Dignity makes a poor sail, but living doesn't.",
			"choices": [
				{"text": "(You cannot help it — the name burns.) Cyclops! Hear me!", "next": "boast"},
			],
		},
		"boast": {
			"speaker": "Odysseus",
			"text": "If any man asks who blinded you, say it was Odysseus, sacker of cities, son of Laertes, of Ithaca!",
			"set_flag": "shore_boast_started",
			"next": "curse",
		},
		"curse": {
			"speaker": "Polyphemus",
			"text": "Odysseus?! Then hear my prayer, Poseidon Earth-shaker: if I am your son, let him not reach home — or reach it late, alone, to find a house of trouble!",
			"set_flag": "shore_boast_done",
			"next": "coda_end",
		},
		"coda_end": {
			"speaker": "",
			"text": "The curse rides the wind. The oars answer. The voyage is longer now.",
			"next": "end",
		},
	}
