extends Node2D

@export var color = Color8(167, 193, 196)

func _ready():
	$CPUParticles2D.color = color
