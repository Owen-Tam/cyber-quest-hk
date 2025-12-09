extends Control
signal home_button_pressed


func _on_home_button_pressed():
	home_button_pressed.emit()
