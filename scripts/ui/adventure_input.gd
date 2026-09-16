extends Node
## Keyboard shortcuts for verb selection (W/L/T/U/P/G).

func _unhandled_input(event: InputEvent) -> void:
	if GameState.dialogue_open:
		return
	if event.is_action_pressed("verb_walk"):
		GameState.set_verb(GameState.Verb.WALK)
	elif event.is_action_pressed("verb_look"):
		GameState.set_verb(GameState.Verb.LOOK)
	elif event.is_action_pressed("verb_talk"):
		GameState.set_verb(GameState.Verb.TALK)
	elif event.is_action_pressed("verb_use"):
		GameState.set_verb(GameState.Verb.USE)
	elif event.is_action_pressed("verb_pickup"):
		GameState.set_verb(GameState.Verb.PICK_UP)
	elif event.is_action_pressed("verb_give"):
		GameState.set_verb(GameState.Verb.GIVE)
