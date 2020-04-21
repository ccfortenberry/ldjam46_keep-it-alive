extends Control

signal start_game
signal restart_game

var sarcasms = [
	"\"Poor little Meringue, couldn't even last more than a minute or two! Hah Hah Ha\"",
	"\"Another Droplet to eat...\"",
	"\"It's a shame you Droplets are so fragile. I'd have loved to keep the chase going!\"",
	"\"Was it all too much for you?\"",
	"\"It's almost like your kind WANTS to be eaten\"",
	"\"I wonder if the other Droplets are just as tasty as this little cookie... Hah Hah ha!\"",
	"\"What's wrong, Meringue? Couldn't get enough peaches?\""
	]

var endPos = Vector2(ProjectSettings.get_setting("display/window/size/width")/4, ProjectSettings.get_setting("display/window/size/height")/2*0.75)

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().connect("gamestate_changed", self, "_on_GameState_Changed"):
		print("CRITICAL ERROR: unable to connect signal for state change in player UI")
	$Ply/Health_Bar.max_value = get_parent().get_node("Level0/Ply_Droplet").max_health
	$Ply/Health_Bar.value = get_parent().get_node("Level0/Ply_Droplet").health
	if get_parent().get_node("Level0/Ply_Droplet").connect("health_changed", self, "_on_Ply_Health_Changed"):
		print("ERROR: Could not connect signal to update player health in UI")
	if get_parent().get_node("Level0/Ply_Droplet").connect("ply_dead", self, "_on_Ply_Death"):
		print("ERROR: Could not connect signal to player death in UI")
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Ply_Health_Changed(health):
	$Ply/Health_Bar.value = health

func _on_Start_Button_pressed():
	emit_signal("start_game")

func _on_GameState_Changed(state:String):
	if state == "game_start":
		$Start.visible = false
		$Ply.visible = true
	if state == "game_over":
		$Ply.visible = false

func _on_Ply_Death():
	$End/End_Menu/Sarcasm_Label.text = sarcasms[rand_range(0, sarcasms.size()-1)]
	$End.visible = true
	$End.rect_position.x = (endPos.x/2) - ($End.rect_size.x*1.1)

func _on_Retry_Button_pressed():
	emit_signal("restart_game")
