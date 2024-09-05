extends Node2D


func _ready():
	%initial_ui.visible = !global.loadMainWithLevels
	%levels_ui.visible = global.loadMainWithLevels

func swap_ui():
	%initial_ui.visible = !%initial_ui.visible
	%levels_ui.visible = !%levels_ui.visible

func _on_inital_ui_start_pressed():
	swap_ui()

const FILE_FORMAT_STRING = "res://levels/level_{level}/level_{level}.tscn"
func _on_levels_ui_switch_level(level):
	if (!%levels_ui.visible and %initial_ui.visible):
		return
	$CanvasLayer/ConfirmLayer.addConfimScreen("Enter Chapter %s" % str(level + 1), "Nevermind...", "Let's go!")
	var answer = await $CanvasLayer/ConfirmLayer.submittedAnswer
	if not is_inside_tree():
		return
	if answer == 2:
		var next_level_path = FILE_FORMAT_STRING.format({"level": str(level)})
		print(next_level_path)
		get_tree().change_scene_to_file(next_level_path)
		


func _on_levels_ui_home_button_pressed():
	swap_ui()
