extends SceneTree
## One-shot: capture shore + cave PNGs for docs (320×200).

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	if packed == null:
		push_error("main.tscn missing")
		quit(1)
		return
	var main = packed.instantiate()
	root.add_child(main)
	# Let opening narration + room settle
	for i in 8:
		await process_frame
	await create_timer(0.15).timeout
	_save_shot("docs/images/shore.png")
	# Enter cave for second shot
	if main.has_method("_try_enter_cave"):
		main._try_enter_cave()
	for i in 10:
		await process_frame
	await create_timer(0.2).timeout
	_save_shot("docs/images/cave.png")
	print("SHOTS_OK")
	quit(0)

func _save_shot(path: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		push_error("No viewport image for " + path)
		return
	# Logical 320×200 — ensure we store base pixels
	if img.get_width() != 320 or img.get_height() != 200:
		img.resize(320, 200, Image.INTERPOLATE_NEAREST)
	var err := img.save_png(path)
	print("Saved %s err=%s size=%sx%s" % [path, err, img.get_width(), img.get_height()])
