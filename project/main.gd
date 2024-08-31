extends Node2D


func _ready():
	%initial_ui.visible = true
	%levels_ui.visible = false

func swap_ui():
	%initial_ui.visible = !%initial_ui.visible
	%levels_ui.visible = !%levels_ui.visible

func _on_inital_ui_start_pressed():
	swap_ui()

const FILE_FORMAT_STRING = "res://levels/level_{level}/level_{level}.tscn"


func _on_levels_ui_switch_level(level):
	$CanvasLayer/ConfirmLayer.addConfimScreen("Enter Chapter %s" % str(level), "Nevermind...", "Let's go!")
	var answer = await $CanvasLayer/ConfirmLayer.submittedAnswer
	if answer == 2:
		var next_level_path = FILE_FORMAT_STRING.format({"level": str(level)})
		print(next_level_path)
		get_tree().change_scene_to_file(next_level_path)
	


func _on_home_button_pressed():
	print("HII")
	swap_ui()
