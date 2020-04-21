extends StaticBody2D

var heal : float = 20.0

func _ready():
	if get_parent().get_parent().connect("gamestate_changed", self, "_on_GameState_Changed"):
		print("CRITICAL ERROR: unable to connect signal for state change in Peach")

func heal_player(ply):
	ply.restore_health(heal)
	queue_free()

func _on_Pickup_Peach_tree_exiting():
	get_parent().isPeachSpawned = false

func _on_GameState_Changed(state:String):
	if visible and state == "game_over":
		visible = false