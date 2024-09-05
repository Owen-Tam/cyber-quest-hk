extends Control
signal submitAnswer

@export var question = ""
@export var answer1 = ""
@export var answer2 = ""

var answer = 0
var overwritten = false
func _ready():
	$Question.text = question
	$"Answer 1".text = answer1
	$"Answer 2".text = answer2
	play_appear_animation()

func play_appear_animation():
	$AnimationPlayer.play("popup_appear")

func _on_answer_1_pressed():
	answer = 1
	submitAnswer.emit(1)

func _on_answer_2_pressed():
	answer = 2
	submitAnswer.emit(2)
