extends Control
signal start_pressed

func _on_start_pressed():
	start_pressed.emit()
