extends CanvasLayer

signal submittedAnswer

@export var confirmHUD_scene: PackedScene
var triggered = false
var confirmHUD
func addConfimScreen(question: String, answer1: String, answer2: String):
	print("Adding confirm screen", triggered)
	if (!triggered):
		triggered = true
		confirmHUD = confirmHUD_scene.instantiate()
		confirmHUD.question = question
		confirmHUD.answer1 = answer1
		confirmHUD.answer2 = answer2
		add_child(confirmHUD)
		
		var answer = await confirmHUD.submitAnswer
		submittedAnswer.emit(answer)
		confirmHUD.queue_free()
		confirmHUD = null
		triggered=false
		return answer
		
	
func removeConfirm():
	if confirmHUD:
		confirmHUD.queue_free()
	confirmHUD = null
	triggered=false

