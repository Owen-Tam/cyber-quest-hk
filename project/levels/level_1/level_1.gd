extends "res://BaseLevel.gd"
@export var level = 1
var corrupted = [[Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(3,3), Vector2i(4,3)], [Vector2i(-1, -4), Vector2i(0, -4), Vector2i(1, -4), Vector2i(0, -3), Vector2i(1, -3)], [Vector2i(-2, -8), Vector2i(-2, -7), Vector2i(-1, -7), Vector2i(-1, -8)]]
const FILE_FORMAT_STRING = "res://levels/level_{level}/level_{level}.tscn"
var adjCorrupted = []
var showPurifyDialog = false
const numberOfCorruptedAreas = 3
var labelList = []
var currentCorruptedArea #0-based
var guardianNumber = 4
signal startGame
var triggerFinalBoss = [Vector2i(-4, -10), Vector2i(-5, -10), Vector2i(-6, -10), Vector2i(-6, -11)]
var finalBossCorruptedTiles = [
	Vector2i(-4, -14),
	Vector2i(-5, -14),
	Vector2i(-6, -14),
	Vector2i(-7, -14),
	Vector2i(-3, -13),
	Vector2i(-4, -13),
	Vector2i(-5, -13),
	Vector2i(-6, -13),
	Vector2i(-7, -13),
	Vector2i(-6, -12),
	Vector2i(-5, -12),
	Vector2i(-4, -12),
	Vector2i(-5, -11)
];
var triggering_boss_battle = false
var cancelled_boss_battle = false

@onready var allCells = $TileMap.get_used_cells($Player.z_index-1)
func DialogicSignal(arg):
	if arg == "exit_beginning":
		$Player.isMovementDisabled = false

func _ready():
	spawnPlayer()
	$Player.isMovementDisabled = true
	Dialogic.signal_event.connect(DialogicSignal)
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
	
	await $CinematicCamera/AnimationPlayer.animation_finished
	$CinematicCamera/CanvasLayer.visible = false
	startGame.emit()

func _on_start_game():
	Dialogic.start("level_1_1")
	

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
				$BossLevelLayer.visible = true
				$BossLevelLayer/AnimationPlayer.play("bosshud_appear_animation")
				$BossLevelLayer/BossHUD.startBossBattle()
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


func _on_boss_hud_completed_boss(failed):
	$Player.isMovementDisabled = false
	$BossLevelLayer.visible = false
	if !failed:
		$Malwaremaster.visible = false
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
		triggering_boss_battle = false
		respawn()


func _on_cyberguardian_chatting():
	$Player.isMovementDisabled = true

func _on_cyberguardian_finished_chatting():
	$Player.isMovementDisabled = false




func _on_portal_entered_portal():
	$Player.isMovementDisabled = true
	# Animation on player
	# confirm pop up
	$ConfirmLayer_Next.addConfimScreen("Move to the Chapter %s" % str(level + 1), "Main Menu", "Let's go!")
	var answer = await $ConfirmLayer_Next.submittedAnswer
	if not is_inside_tree():
		return
	if answer == 1 :
		# Main menu
		global.loadMainWithLevels = true
		get_tree().change_scene_to_file("res://main_menu/main.tscn")
	else:
		# Next level
		var next_level_path = FILE_FORMAT_STRING.format({"level": str(level + 1)})
		var res = get_tree().change_scene_to_file(next_level_path)
		if res == 19:
			print("NEXT LEVEL NOT FOUND")
			global.loadMainWithLevels = true
			get_tree().change_scene_to_file("res://main_menu/main.tscn")
	



func _on_escape_ui_restart_game():
	var level_path = FILE_FORMAT_STRING.format({"level": str(level)})
	var res = get_tree().change_scene_to_file(level_path)



