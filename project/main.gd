extends Node2D

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
	
func spawnPlayer():
	$Player.global_position = $Spawn.global_position

func _process(delta):
	var playerCell = $TileMap.local_to_map($TileMap.to_local($Player/PlayerPos.global_position))

	# Check if should be falling
	if !allCells.has(playerCell) and !corrupted.has(playerCell)  and !$Player.isFalling:
		#player falling!
		$Player.isFalling = true
		$RespawnTimer.start(1.2)
		
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
	
	if triggerFinalBoss.has(playerCell) and !triggering_boss_battle:
		if !cancelled_boss_battle and !$ConfirmLayer.triggered:
			$ConfirmLayer.addConfimScreen("Enter the boss battle with Malware Master?", "Nevermind...", "Let's go!")
			var answer = await $ConfirmLayer.submittedAnswer

			if (answer == 2) :
				$Player.isMovementDisabled = true
				triggering_boss_battle = true
				$Malwaremaster.run_boss_dialogue()
				await $Malwaremaster.finishedChatting
				$BossLevelLayer.visible = true
				$BossLevelLayer/BossHUD.startBossBattle()
				
			else:
				cancelled_boss_battle = true
	if !triggerFinalBoss.has(playerCell):
		cancelled_boss_battle = false
		$ConfirmLayer.removeConfirm()
	
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
	
	for i in get_node("Area"+ str(currentCorruptedArea+1)).get_children():
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
		for tile in finalBossCorruptedTiles:
			$TileMap.set_cell($Player.z_index-1, tile, 2, Vector2i(0, 0))
		if currentCorruptedArea:
			get_node("Cyberguardian " + str(currentCorruptedArea + 1)).visible = false
			get_node("Cyberguardian " + str(guardianNumber)).visible = true
	else:
		triggering_boss_battle = false
		respawn()


func _on_cyberguardian_chatting(is_chatting):
	$Player.isMovementDisabled = is_chatting
