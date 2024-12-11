extends "res://BaseLevel.gd"
@export var level = 2
var corrupted = [[Vector2i(3, 0), Vector2i(4, 0), Vector2i(2, -1), Vector2i(3, -1),
	Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2)], [Vector2i(1, -9), Vector2i(2, -9), Vector2i(0, -10),
	Vector2i(1, -10), Vector2i(2, -10), Vector2i(0, -11), Vector2i(1, -11), Vector2i(2, -11), Vector2i(-1, -12)
]]
const FILE_FORMAT_STRING = "res://levels/level_{level}/level_{level}.tscn"
var adjCorrupted = []
var showPurifyDialog = false
const numberOfCorruptedAreas = 2
var labelList = []
var currentCorruptedArea #0-based
var guardianNumber = 3

var triggerFinalBoss = [Vector2i(9, -8), Vector2i(9, -9), Vector2i(9, -10), Vector2i(9, -11), Vector2i(10, -9), Vector2i(11, -9)]
var finalBossCorruptedTiles = [Vector2i(10, -10), Vector2i(11, -10), Vector2i(12, -10), Vector2i(13, -10), Vector2i(10, -11), Vector2i(11, -11), Vector2i(12, -11), Vector2i(10, -12), Vector2i(11, -12), Vector2i(12, -12), Vector2i(13, -12), Vector2i(10, -13), Vector2i(11, -13), Vector2i(12, -13), Vector2i(13, -13), Vector2i(10, -14), Vector2i(11, -14), Vector2i(12, -14)]
var triggering_boss_battle = false
var cancelled_boss_battle = false

@onready var allCells = $TileMap.get_used_cells($Player.z_index-1)
func _ready():
	spawnPlayer()
	$Player.isMovementDisabled = true

	$MCLayer/MCHUD.setQuestionDB(level)
	for i in range(numberOfCorruptedAreas):
		labelList.push_back(get_node("Area" + str(i+1) + "/Label"))

	# Detect corrupted tiles
	for i in corrupted:
		var adjCont = []
		for corrupted_cell in i:
			for b in range(15):
				var adj = $TileMap.get_neighbor_cell(corrupted_cell, b)
				if $TileMap.get_cell_source_id($Player.z_index-1, adj) != -1 and !i.has(adj) and !adjCont.has(adj):
					adjCont.push_back(adj)
		adjCorrupted.push_back(adjCont)
	print(adjCorrupted)
	play_starting_animation()

func play_starting_animation():
	$CinematicCamera.make_current()
	$CinematicCamera/CanvasLayer.visible = true
	$CinematicCamera/AnimationPlayer.play("camera_animation")
	await $CinematicCamera/AnimationPlayer.animation_finished
	$Player/Camera2D.make_current()
	$Player/Camera2D.position_smoothing_enabled = true
	$Player/Camera2D.position_smoothing_speed = 15
	$CinematicCamera/AnimationPlayer.play("fade_animation")
	$Player.isMovementDisabled = false
	await $CinematicCamera/AnimationPlayer.animation_finished
	$CinematicCamera/CanvasLayer.visible = false

func spawnPlayer():
	$Player.global_position = $Spawn.global_position

func _process(delta):
	var playerCell = $TileMap.local_to_map($TileMap.to_local($Player/PlayerPos.global_position))

	# Check if should be falling
	if !allCells.has(playerCell) and !corrupted.has(playerCell)  and !$Player.isFalling:
		#player falling!
		$Player.isFalling = true
		$RespawnTimer.start(1)
		
	# Check if adjacent to corrupted
	var isAdjToCorrupted = false
	
	for i in range(adjCorrupted.size()):
		if adjCorrupted[i].has(playerCell):
			isAdjToCorrupted = true
			currentCorruptedArea = i
			break
	if isAdjToCorrupted:
		if (!showPurifyDialog):
			showPurifyDialog = true
			labelList[currentCorruptedArea].visible = true
			var tween = create_tween().set_loops()
			tween.tween_property(labelList[currentCorruptedArea],"position", labelList[currentCorruptedArea].global_position - Vector2(0, 2), 2).set_ease(2)
			tween.tween_property(labelList[currentCorruptedArea],"position", labelList[currentCorruptedArea].global_position - Vector2(0, -2), 2).set_ease(2)
	else:
		showPurifyDialog = false
		for k in labelList:
			k.visible = false
	if !triggerFinalBoss.has(playerCell):
		cancelled_boss_battle = false
		$ConfirmLayer.removeConfirm()
		
	if triggerFinalBoss.has(playerCell) and !triggering_boss_battle:
		if !cancelled_boss_battle and !$ConfirmLayer.triggered:
			$ConfirmLayer.addConfimScreen("Enter the boss battle with Malware Master?", "Nevermind...", "Let's go!")
			var answer = await $ConfirmLayer.submittedAnswer

			if (answer == 2 and !triggering_boss_battle) :
				$Player.isMovementDisabled = true
				triggering_boss_battle = true
				$Malwaremaster.run_boss_dialogue()
				await $Malwaremaster.finishedChatting
				$Player.isMovementDisabled = false
				$CreditsLayer/Credits.visible = false
				$ConfirmLayer.removeConfirm()
				for tile in finalBossCorruptedTiles:
					$TileMap.set_cell($Player.z_index-1, tile, 2, Vector2i(0, 0))
				if currentCorruptedArea:
					get_node("Cyberguardian " + str(currentCorruptedArea + 1)).visible = false
				var final_guardian = get_node("Cyberguardian " + str(guardianNumber))
				final_guardian.visible = true
				$Portal.visible = true
				await final_guardian.finishedChat
				$Portal.activate()
			else:
				cancelled_boss_battle = true

func _input(event):
	if event.is_action_pressed("accept_challenge") and showPurifyDialog == true:
		$Player.isMovementDisabled = true
		$MCLayer.visible = true
		$MCLayer/AnimationPlayer.play("mchud_appear_animation")
		$MCLayer/MCHUD.startQuestioning(currentCorruptedArea)
	elif event.is_action_pressed("toggle-ingame-menu"):
		$"Escape UI".visible = !$"Escape UI".visible
	
func respawn():
	$Player.isFalling = false
	spawnPlayer() 




func _on_mchud_completed_challenge():
	$Player.isMovementDisabled = false
	$MCLayer.visible = false
	triggerCompleteEffect(currentCorruptedArea)
	changeCyberguardian(currentCorruptedArea, guardianNumber)
	clearArea(corrupted, adjCorrupted, currentCorruptedArea)




func _on_cyberguardian_chatting():
	$Player.isMovementDisabled = true

func _on_cyberguardian_finished_chatting():
	$Player.isMovementDisabled = false




func _on_portal_entered_portal():
	$Player.isMovementDisabled = true
	# Animation on player
	# confirm pop up
	$CreditsLayer/Credits.visible = true
	$CreditsLayer/AnimationPlayer.play("credits_appear_animation")

	
	



func _on_escape_ui_restart_game():
	var level_path = FILE_FORMAT_STRING.format({"level": str(level)})
	var res = get_tree().change_scene_to_file(level_path)


func _on_credits_end_reached():
		# Main menu
	global.loadMainWithLevels = true
	get_tree().change_scene_to_file("res://main_menu/main.tscn")
