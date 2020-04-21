extends Node2D

# State logic
signal gamestate_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1280, 720), 2)
	if $Ply_UI.connect("start_game", self, "_on_Start_Game"):
		print("CRITCAL ERROR: Unable to connect signal for changing game state START in Main")
	if $Ply_UI.connect("restart_game", self, "_on_Restart_Game"):
		print("CRITCAL ERROR: Unable to connect signal for changing game state RESTART in Main")
	if $Level0/Ply_Droplet.connect("ply_killed", self, "_on_End_Game"):
		print("CRITCAL ERROR: Unable to connect signal for changing game state END in Main")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Start_Game():
	$Ply_UI.rect_position = Vector2(0,0)
	emit_signal("gamestate_changed", "game_start")

func _on_End_Game():
	$Ply_UI.rect_position = Vector2(280,120)
	emit_signal("gamestate_changed", "game_over")

func _on_Restart_Game():
	if get_tree().reload_current_scene():
		print("Restarting game...")
