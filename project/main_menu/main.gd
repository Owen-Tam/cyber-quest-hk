extends Node2D


func _ready():
	%initial_ui.visible = !global.loadMainWithLevels
	%levels_ui.visible = global.loadMainWithLevels
	%about_ui.visible = false

func swap_ui(ui1, ui2):
	ui1.visible = !ui1.visible
	ui2.visible = !ui2.visible



func _on_inital_ui_start_pressed():
	swap_ui(%initial_ui, %levels_ui)

const FILE_FORMAT_STRING = "res://levels/level_{level}/level_{level}.tscn"
func _on_levels_ui_switch_level(level):
	if (!%levels_ui.visible and %initial_ui.visible):
		return
	$CanvasLayer/ConfirmLayer.addConfimScreen("Enter Chapter %s" % str(level), "Nevermind...", "Let's go!")
	var answer = await $CanvasLayer/ConfirmLayer.submittedAnswer
	
	if not is_inside_tree():
		return
	if answer == 2:
		var next_level_path = FILE_FORMAT_STRING.format({"level": str(level)})
		print(next_level_path)
		get_tree().change_scene_to_file(next_level_path)
		


func _on_levels_ui_home_button_pressed():
	swap_ui(%initial_ui, %levels_ui)

func _on_initial_ui_about_pressed():
	swap_ui(%initial_ui, %about_ui)
	
func _on_about_ui_home_button_pressed():
	swap_ui(%initial_ui, %about_ui)
