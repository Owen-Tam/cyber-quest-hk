extends Node2D
func spawnPlayer():
	$Player.global_position = $Spawn.global_position
	
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

func clearArea(corrupted, adjCorrupted, currentCorruptedArea):
	var area = corrupted[currentCorruptedArea]
	for i in range(area.size()):
		$TileMap.set_cell($Player.z_index-1, area[i], 2, Vector2i(0, 0))
		#Replace with empty
		#$TileMap.set_cell($Player.z_index-1, area[i], 4, Vector2i(5, 0))
	var areaStr = "Area"+ str(currentCorruptedArea+1)
	var curAnimationPlayer = get_node(areaStr + "/AnimationPlayer")
	get_node(areaStr + "/Label").visible = false
	curAnimationPlayer.play("clear_area_animation")
	$AudioStreamPlayer2D.play()
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

func changeCyberguardian(currentCorruptedArea, guardianNumber):
	get_node("Cyberguardian " + str(currentCorruptedArea + 1)).visible = false
	var next = get_node("Cyberguardian " + str(currentCorruptedArea + 2))
	if (next and currentCorruptedArea+2 != guardianNumber):
		next.visible = true


