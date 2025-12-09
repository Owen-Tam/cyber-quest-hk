extends Control
signal start_pressed
signal about_pressed

func _on_start_pressed():
	start_pressed.emit()


func _on_about_pressed():
	about_pressed.emit()
