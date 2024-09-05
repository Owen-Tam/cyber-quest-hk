extends CanvasLayer

signal submittedAnswer

@export var confirmHUD_scene: PackedScene
var triggered = false


var confirmHUD

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func addConfimScreen(question: String, answer1: String, answer2: String):
	if (!triggered):
		triggered = true
		print("Triggered = true")
		confirmHUD = confirmHUD_scene.instantiate()
		confirmHUD.question = question
		confirmHUD.answer1 = answer1
		confirmHUD.answer2 = answer2
		add_child(confirmHUD)
		
		var answer = await confirmHUD.submitAnswer
		if (!confirmHUD.overwritten):
			print("EMIT!")
			submittedAnswer.emit(answer)
			confirmHUD.queue_free()
			confirmHUD = null
			triggered=false
			return answer
		else:
			confirmHUD.queue_free()
			confirmHUD = null
			triggered=false
			return null
	
	
func removeConfirm():
	if confirmHUD:
		confirmHUD.overwritten = true
		confirmHUD.queue_free()
	confirmHUD = null
	triggered=false

