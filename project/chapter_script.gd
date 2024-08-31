extends Sprite2D

signal start_chapter

func _input(event):
	if !%levels_ui.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			start_chapter.emit()

