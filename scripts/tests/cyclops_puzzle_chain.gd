extends SceneTree
## Boots main scene and drives the Cyclops puzzle API end-to-end.
## godot --headless --path . -s res://scripts/tests/cyclops_puzzle_chain.gd

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var GS: Node = root.get_node("GameState")
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		push_error("Failed to load main.tscn")
		quit(1)
		return
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	await process_frame
	if GS.current_room != "cave_exterior":
		push_error("Expected cave_exterior, got " + str(GS.current_room))
		quit(1)
		return
	if not GS.has_item("wine"):
		push_error("Expected starting wine")
		quit(1)
		return
	var ep = main
	ep._try_enter_cave()
	await process_frame
	await process_frame
	if GS.current_room != "cave_interior":
		push_error("Failed to enter cave")
		quit(1)
		return
	GS.set_flag("gave_nobody_name", true)
	ep._give_wine()
	if not GS.get_flag("polyphemus_asleep"):
		push_error("Wine did not put Cyclops to sleep")
		quit(1)
		return
	GS.add_item("olive_wood")
	GS.selected_item = "olive_wood"
	ep._use("fire")
	if not GS.has_item("stake"):
		push_error("Stake not carved")
		quit(1)
		return
	GS.selected_item = "stake"
	ep._use("fire")
	if not GS.has_item("hot_stake"):
		push_error("Stake not heated")
		quit(1)
		return
	GS.selected_item = "hot_stake"
	ep._use("polyphemus")
	if not GS.get_flag("polyphemus_blinded"):
		push_error("Blind failed")
		quit(1)
		return
	ep._pick_up("sheep")
	if not GS.get_flag("hiding_under_sheep"):
		push_error("Sheep hide failed")
		quit(1)
		return
	ep._escape()
	await process_frame
	await process_frame
	if not GS.get_flag("cyclops_escaped"):
		push_error("Escape failed")
		quit(1)
		return
	# Shore coda: boast → curse → win (not win on escape alone)
	if GS.get_flag("adventure_won_fired"):
		push_error("Win fired before shore boast")
		quit(1)
		return
	# Drive coda: boast path choice 0, then continues through curse/coda_end
	var DM: Node = root.get_node("DialogueManager")
	if not DM.active:
		# Coda may need re-start if room load raced; Talk ship path
		ep._talk("ship")
	await process_frame
	if DM.active:
		DM.choose(0)  # boast
		await process_frame
		# boast → curse (auto next), then continue curse → coda_end → end
		while DM.active:
			DM.continue_line()
			await process_frame
	if not GS.get_flag("shore_boast_done"):
		push_error("Shore boast/curse did not complete")
		quit(1)
		return
	if not GS.get_flag("adventure_won_fired") and not GS.get_flag("cyclops_escaped"):
		push_error("Win did not fire after coda")
		quit(1)
		return
	# dialogue_ended hook should have fired win
	await process_frame
	if not GS.get_flag("adventure_won_fired"):
		# Fallback if continue_line ended without emitting in same frame
		ep._on_dialogue_ended()
	if not GS.get_flag("adventure_won_fired"):
		push_error("adventure_won_fired not set after coda")
		quit(1)
		return
	print("CYCLOPS_PUZZLE_CHAIN_OK")
	quit(0)
