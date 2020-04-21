extends KinematicBody2D

# State logic
var introWake = false
var introLaugh = false
signal intro_complete
var gameEnd = false

# Physics logic
var canMove = false
var speed = sin(1)
var isAttacking = false
var canShoot = false
var bullet = preload("res://assets/scenes/object/Swep_Bullet.tscn")
var dir
var contact_damage : float = 30.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().get_parent().connect("gamestate_changed", self, "_on_GameState_Changed"):
		print("CRITICAL ERROR: unable to connect signal for state change in NPC_Phantom")
	$AnimatedSprite.animation = "awake"
	$AnimatedSprite.frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if introWake:
		if $AnimatedSprite.frame == $AnimatedSprite.frames.get_frame_count("awake")-1:
			$AnimatedSprite.animation = "idle"
			introWake = false
			introLaugh = true
	elif introLaugh:
		if $AnimatedSprite.animation == "idle" and $AnimatedSprite.frame == $AnimatedSprite.frames.get_frame_count("idle")-1:
			$AnimatedSprite.animation = "laugh"
			$SFX_Chuckle.play()
		elif $AnimatedSprite.animation == "laugh" and $AnimatedSprite.frame == $AnimatedSprite.frames.get_frame_count("laugh")-1:
			$AnimatedSprite.animation = "idle"
			introLaugh = false
			canMove = true
			canShoot = true
			$Attack_Timer.start()
			emit_signal("intro_complete")
	elif canMove:
		position.x += speed
		if position.x <= get_parent().get_node("Phantom_Start").position.x or position.x >= get_parent().get_node("Phantom_End").position.x:
			speed *= -1
		
		dir = get_parent().get_node("Ply_Droplet").global_position - global_position
		
		if $AnimatedSprite.animation == "chuckle" and $AnimatedSprite.frame == $AnimatedSprite.frames.get_frame_count("chuckle")-1:
			$AnimatedSprite.animation = "idle"
		
		if isAttacking:
			shoot()
	elif gameEnd:
		position.x = lerp(position.x, ProjectSettings.get_setting("display/window/size/width")/2/2, delta)

# Called when bullets need to be fired
func shoot():
	if canShoot:
		canShoot = false
		$ROF_Timer.start()
		var bulletToSpawn = bullet.instance()
		bulletToSpawn.fire($Bullet_Spawn_1.global_position, dir.angle())
		get_parent().add_child(bulletToSpawn)
		$SFX_Bullet.play()

# Called when the player comes into contact with a hostile spirit
func damage_player(ply):
	ply.take_damage(contact_damage)
	ply.knockback()

func _on_Attack_Timer_timeout():
	if !isAttacking:
		isAttacking = true
		$AnimatedSprite.animation = "chuckle"
		$SFX_Chuckle.play()
		$Attack_Duration.start()

func _on_ROF_Timer_timeout():
	canShoot = true

func _on_Attack_Duration_timeout():
	isAttacking = false

func _on_GameState_Changed(state:String):
	if state == "game_start":
		introWake = true
		$AnimatedSprite.play("awake")
	elif state == "game_over":
		$Attack_Timer.stop()
		$ROF_Timer.stop()
		$Attack_Duration.stop()
		canMove = false
		canShoot = false
		$AnimatedSprite.animation = "laugh"
		$SFX_Chuckle.play()
		gameEnd = true
