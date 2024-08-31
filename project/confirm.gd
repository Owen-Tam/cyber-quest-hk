extends Control
signal submitAnswer

@export var question = ""
@export var answer1 = ""
@export var answer2 = ""

func _ready():
	$Question.text = question
	$"Answer 1".text = answer1
	$"Answer 2".text = answer2



func _on_answer_1_pressed():
	submitAnswer.emit(1)


func _on_answer_2_pressed():
	submitAnswer.emit(2)
