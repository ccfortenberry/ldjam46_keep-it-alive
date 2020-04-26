extends KinematicBody2D

# Physics consts
const _FLOOR = Vector2(0,-1)
const _G = 9.8
const _F = 0.3

# Physics logic
var _canMove = false
var _isAlive = false
var speed = 350
var velocity = Vector2()
var last_velocity = velocity # Peach collision workaround
var accel = Vector2(100, _G)
var jump = -350
var collision : KinematicCollision2D

# State logic
var _gameEnd = false
var endPos = Vector2(ProjectSettings.get_setting("display/window/size/width")/2/2, ProjectSettings.get_setting("display/window/size/height")/2*0.75)
var _isDying = false
signal ply_dead

# Ply logic
var max_health : float = 100.0
var health : float = max_health
var _invincible = false
var _wounded = false
signal health_changed
signal ply_wounded
signal ply_killed

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().get_parent().connect("gamestate_changed", self, "_on_GameState_Changed"):
		print("CRITICAL ERROR: unable to connect signal for state change in player")
	if get_parent().get_node("NPC_Phantom").connect("intro_complete", self, "_on_NPC_Intro_Complete"):
		print("CRITICAL ERROR: unable to connect signal for NPC intro complete")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if _canMove:
		if velocity.y < 0:
			velocity.y += accel.y
		elif velocity.y >= 0:
			velocity.y += accel.y * 1.5
		if _isAlive:
			if Input.is_action_pressed("ui_right"):
				velocity.x = min(velocity.x+accel.x, speed)
				$Ply_Sprite.flip_h = true
				if !_invincible: $Ply_Sprite.animation = "walk"
			elif Input.is_action_pressed("ui_left"):
				velocity.x = max(velocity.x-accel.x, -speed)
				$Ply_Sprite.flip_h = false
				if !_invincible: $Ply_Sprite.animation = "walk"
			else:
				if !_invincible: $Ply_Sprite.animation = "idle"
			
			if is_on_floor():
				if Input.is_action_just_pressed("ui_jump"):
					velocity.y = jump
					$SFX_Jump.play()
				velocity = velocity.linear_interpolate(Vector2(0,velocity.y), _F)
			else:
				if !_invincible: $Ply_Sprite.animation = "jump"
				velocity.x = lerp(velocity.x, 0, _F)
			
			if $Ply_Sprite.animation == "damage" and $Ply_Sprite.frame == $Ply_Sprite.frames.get_frame_count("damage")-1:
				_invincible = false
			
			take_damage(delta)
			
		velocity = move_and_slide(velocity, _FLOOR)
		for i in get_slide_count():
			collision = get_slide_collision(i)
			if collision.collider.has_method("damage_player"):
				collision.collider.damage_player(self)
				knockback()
			elif collision.collider.has_method("heal_player"):
				collision.collider.heal_player(self)
				$SFX_Pickup.play()
				velocity = last_velocity
		
		last_velocity = velocity
	
	elif _gameEnd:
		position.x = lerp(position.x, endPos.x, delta)
		position.y = lerp(position.y, endPos.y, delta)
		if (abs(position.length() - endPos.length()) < 2.5) and !_isDying:
			_isDying = true
			$Ply_Sprite.animation = "death"
			$SFX_Death.play()
			emit_signal("ply_dead")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _on_GameState_Changed(state:String):
	if state == "game_start":
		_canMove = true
	if state == "game_over":
		_gameEnd = true

func _on_NPC_Intro_Complete():
	_isAlive = true

func take_damage(damage:float):
	if !_invincible:
		health -= damage
		emit_signal("health_changed", health)
		if !_wounded and health < 70.0:
			_wounded = true
			emit_signal("ply_wounded")
		elif health <= 0:
			kill()

func knockback():
	if !_invincible:
		_invincible = true
		$SFX_Damage.play()
		$Ply_Sprite.animation = "damage"
		velocity.x *= -5
		velocity.y -= 100

func restore_health(hp:float):
	health += hp
	if health > max_health:
		health = 100.0
	emit_signal("health_changed", health)

func kill():
	_canMove = false
	_isAlive = false
	emit_signal("ply_killed")
