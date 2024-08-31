extends Control

signal switch_level


func _on_chapter_2_start_chapter():
	switch_level.emit(2)
