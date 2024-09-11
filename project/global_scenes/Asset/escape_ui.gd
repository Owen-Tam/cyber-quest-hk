extends CanvasLayer

signal restartGame

func _on_leave_button_pressed():
	var ans = await $ConfirmLayer.addConfimScreen("Progress will not be saved. Are you sure you want to leave the level?", "Nevermind...", "Sure")
	if ans == 2:
		const main_path = "res://main_menu/main.tscn"
		get_tree().change_scene_to_file(main_path)

func _on_restart_button_pressed():
	restartGame.emit()
