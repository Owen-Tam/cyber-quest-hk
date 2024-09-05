extends Node2D
@export var level = 2
var corrupted = [[Vector2i(1, -3), Vector2i(1, -4), Vector2i(2, -4), Vector2i(2,-3)], 
				[Vector2i(4,-9), Vector2i(5, -9), Vector2i(4, -10), Vector2i(5,-10)]]

var adjCorrupted = []
var showPurifyDialog = false
const numberOfCorruptedAreas = 2
var labelList = []
var currentCorruptedArea #0-based
var guardianNumber = 3

var triggerFinalBoss = [Vector2i(7, -14), Vector2i(8, -14), Vector2i(9, -14), Vector2i(7, -15)]
var finalBossCorruptedTiles = [Vector2i(7, -17), Vector2i(7, -16), Vector2i(8, -17), Vector2i(8, -16), Vector2i(8, -15), Vector2i(9, -17), Vector2i(9, -16), Vector2i(9, -15)]
var triggering_boss_battle = false
var cancelled_boss_battle = false

@onready var allCells = $TileMap.get_used_cells($Player.z_index-1)
func _ready():
	spawnPlayer()
	$Player.isMovementDisabled = true
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
			print("ADDED")
			$ConfirmLayer.addConfimScreen("Enter the boss battle with Malware Master?", "Nevermind...", "Let's go!")
			var answer = await $ConfirmLayer.submittedAnswer
			
			if (answer == 2 and !triggering_boss_battle) :
				print("ENTERING BOSS BATTLE")
				$Player.isMovementDisabled = true
				triggering_boss_battle = true
				$Malwaremaster.run_boss_dialogue()
				await $Malwaremaster.finishedChatting
				$BossLevelLayer.visible = true
				$BossLevelLayer/BossHUD.startBossBattle()
			else:
				cancelled_boss_battle = true
	
	
func _input(event):
	if event.is_action_pressed("accept_challenge") and showPurifyDialog == true:
		$Player.isMovementDisabled = true
		$MCLayer.visible = true
		$MCLayer/MCHUD.startQuestioning(currentCorruptedArea)
	
func respawn():
	$Player.isFalling = false
	spawnPlayer() 

func clearArea(currentCorruptedArea):
	var area = corrupted[currentCorruptedArea]
	for i in range(area.size()):
		$TileMap.set_cell($Player.z_index-1, area[i], 2, Vector2i(0, 0))
		#Replace with empty
		#$TileMap.set_cell($Player.z_index-1, area[i], 4, Vector2i(5, 0))
	var areaStr = "Area"+ str(currentCorruptedArea+1)
	var curAnimationPlayer = get_node(areaStr + "/AnimationPlayer")
	get_node(areaStr + "/Label").visible = false
	curAnimationPlayer.play("clear_area_animation")
	await curAnimationPlayer.animation_finished
	for i in get_node(areaStr + "/corruptedBlocks").get_children():
		if !i.name.begins_with("Explosion"):
			i.visible = false
	adjCorrupted[currentCorruptedArea] = []

func triggerCompleteEffect(currentCorruptedArea):
	var areaNodes = get_node("Area"+ str(currentCorruptedArea + 1)).get_children()
	var explosionNodes = []
	for i in areaNodes:
		if i.name.begins_with("Explosion"):
			explosionNodes.push_back(i)
	for i in explosionNodes:
		i.explode()

func changeCyberguardian():
	get_node("Cyberguardian " + str(currentCorruptedArea + 1)).visible = false
	var next = get_node("Cyberguardian " + str(currentCorruptedArea + 2))
	if (next and currentCorruptedArea+2 != guardianNumber):
		next.visible = true


func _on_mchud_completed_challenge():
	$Player.isMovementDisabled = false
	$MCLayer.visible = false
	triggerCompleteEffect(currentCorruptedArea)
	changeCyberguardian()
	clearArea(currentCorruptedArea)


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


const FILE_FORMAT_STRING = "res://levels/level_{level}/level_{level}.tscn"

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
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		# Next level
		var next_level_path = FILE_FORMAT_STRING.format({"level": str(level + 1)})
		var res = get_tree().change_scene_to_file(next_level_path)
		if res == 19:
			print("NEXT LEVEL NOT FOUND")
			global.loadMainWithLevels = true
			get_tree().change_scene_to_file("res://main.tscn")
	

