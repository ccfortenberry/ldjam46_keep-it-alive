extends Node2D

# Spawning logic for health pickups, ie. peaches
onready var Peach_Spawns = [$Peach_Spawn_1, $Peach_Spawn_2, $Peach_Spawn_3, $Peach_Spawn_4, $Peach_Spawn_5, $Peach_Spawn_6, $Peach_Spawn_7, $Peach_Spawn_8, $Peach_Spawn_9, $Peach_Spawn_10, $Peach_Spawn_11]
var isPeachSpawned = false
var peach = preload("res://assets/scenes/object/Pickup_Peach.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().connect("gamestate_changed", self, "_on_GameState_Changed"):
		print("CRITICAL ERROR: Could not connect signal for state changes in Level scene")
	if $NPC_Phantom.connect("intro_complete", self, "_on_NPC_Intro_Complete"):
		print("CRITICAL ERROR: unable to connect signal for NPC intro complete")
	if $Ply_Droplet.connect("ply_wounded", self, "_on_Ply_Wounded"):
		print("CRITICAL ERROR: Could not connect signal for ply_wounded")
	if $Ply_Droplet.connect("ply_killed", self, "_on_Ply_Killed"):
		print("CRITICAL ERROR: Could not connect signal for ply_killed")

func _on_GameState_Changed(state:String):
	if state == "game_start":
		randomize()
	if state == "game_over":
		$BGM.stop()
		$TileMap_Blocks.visible = false
		$TileMap_Spikes.visible = false

func _on_NPC_Intro_Complete():
	$BGM.play()

func _on_Peach_Spawn_Timer_timeout():
	if !isPeachSpawned:
		var spawnPos = Peach_Spawns[rand_range(0,Peach_Spawns.size()-1)]
		var peachToSpawn = peach.instance()
		add_child(peachToSpawn)
		peachToSpawn.position = spawnPos.position
		isPeachSpawned = true

func _on_Ply_Wounded():
	$Peach_Spawn_Timer.start()

func _on_Ply_Killed():
	$Peach_Spawn_Timer.stop()
