extends Node2D

var damage : float = 20.0

func damage_player(ply):
	ply.take_damage(damage)
	ply.knockback()
