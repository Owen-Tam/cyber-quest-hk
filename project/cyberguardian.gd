extends Sprite2D

signal chatting



var player_in_area = false
var is_chatting = false
@export var chosen_dialogue = "password_basics"


func _ready():
	Dialogic.signal_event.connect(DialogicSignal)

func _input(event):
	if event.is_action_pressed("accept_dialogue") and !is_chatting:
		is_chatting = true
		chatting.emit(true)
		await run_dialogue(chosen_dialogue)




func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		$Label.visible = true
		player_in_area = true



func _on_area_2d_body_exited(body):
	if body.has_method("player"):
		$Label.visible = false
		player_in_area = false



func run_dialogue(dialogue_string):
	Dialogic.start(dialogue_string)

func DialogicSignal(arg):
	if arg == "exit_cyberguardian":
		is_chatting = false
		chatting.emit(false)