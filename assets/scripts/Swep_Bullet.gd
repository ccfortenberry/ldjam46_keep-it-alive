extends KinematicBody2D

var speed = 200
var velocity = Vector2()
var damage : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	rotation += 10
	var collision = move_and_collide(velocity*delta)
	if collision:
		if collision.collider.has_method("take_damage"):
			collision.collider.take_damage(damage)
			collision.collider.knockback()
		queue_free()

func fire(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed, 0).rotated(rotation)

func damage_player(ply):
	ply.take_damage(damage)
