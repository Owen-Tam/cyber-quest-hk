extends Node2D

signal entered_portal

var can_enter = false

func _ready():
	$AnimationPlayer.play("portal_animation")

func activate():
	can_enter = true
	$AnimationPlayer2.play("portal_activate")

func _on_area_2d_body_entered(body):
	if can_enter and body.is_in_group("player"):
		entered_portal.emit()
