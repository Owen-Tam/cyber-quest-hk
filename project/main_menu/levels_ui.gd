extends Control

signal switch_level
signal home_button_pressed

func _on_chapter_1_start_chapter():
	switch_level.emit(1)

func _on_chapter_2_start_chapter():
	switch_level.emit(2)


func _on_home_button_pressed():
	home_button_pressed.emit()



