extends Control

signal selectedAnswer(selectedIndex)
signal moveToNextQuestion
signal completedChallenge


var isQuestioning = false
var questionDB = [[{
	"question": "Why is safeguarding passwords so important?",
	"answers": ["Passwords are not actually important, and can be easily shared with others.",
	"Passwords prevent unauthorized access to personal or sensitive information.",
	"Passwords can be easily remembered, so there's no need to keep them secure.",
	"Passwords are only needed for logging into websites, not for accessing important accounts or devices."],
	"correctIndex": 2 #1-based 
}, {
	"question": "Why is safeguarding passwords so important?",
	"answers": ["Passwords are not actually important, and can be easily shared with others.",
	"Passwords prevent unauthorized access to personal or sensitive information.",
	"Passwords can be easily remembered, so there's no need to keep them secure.",
	"Passwords are only needed for logging into websites, not for accessing important accounts or devices."],
	"correctIndex": 2 #1-based 
}], [{
	"question": "Why is safeguarding passwords so important?",
	"answers": ["Passwords are not actually important, and can be easily shared with others.",
	"Passwords prevent unauthorized access to personal or sensitive information.",
	"Passwords can be easily remembered, so there's no need to keep them secure.",
	"Passwords are only needed for logging into websites, not for accessing important accounts or devices."],
	"correctIndex": 2 #1-based 
}, {
	"question": "Why is safeguarding passwords so important?",
	"answers": ["Passwords are not actually important, and can be easily shared with others.",
	"Passwords prevent unauthorized access to personal or sensitive information.",
	"Passwords can be easily remembered, so there's no need to keep them secure.",
	"Passwords are only needed for logging into websites, not for accessing important accounts or devices."],
	"correctIndex": 2 #1-based 
}]]
var currentQuestionObj
func startQuestioning(questionSet): #questionSet is the area number (which is 0 based)
	var questions = questionDB[questionSet]
	# Macro setup
	isQuestioning = true
	$ProgressBar.value = 0
	$ProgressBar.max_value = questions.size()
	$NextButton.text = "Next"
	$ProgressBar/PurifyStatusLabel.text = "Purifying..."
	for i in range(questions.size()):
		#setup
		currentQuestionObj = questions[i]
		$Question_Label.text = currentQuestionObj.question
		for k in range(currentQuestionObj.answers.size()):
			get_node("Answer_Label_" + str(k+1)).text = currentQuestionObj.answers[k]
			get_node("Answer_Label_" + str(k+1)).add_theme_color_override("font_color", Color8(0, 0, 0))
			get_node("Answer_Box_" + str(k+1)).self_modulate = Color8(255,255,255, 255)
		# wait for answering
		var isCorrect = false
		$NextButton.visible = false
		while(!isCorrect):
			var selectedIndex = await self.selectedAnswer
			if selectedIndex != currentQuestionObj.correctIndex:
				# BLANK OUT THE WRONG ONE
				get_node("Answer_Box_" + str(selectedIndex)).self_modulate = Color(1, 1, 1, 0.3)
			else:
				isCorrect = true
				# 1. SHOW CORRECT
				for k in range(currentQuestionObj.answers.size()):
					if k + 1 != selectedIndex:
						get_node("Answer_Box_" + str(k + 1)).self_modulate = Color(1, 1, 1, 0.3)
				get_node("Answer_Label_" + str(selectedIndex)).add_theme_color_override("font_color", Color8(255, 102, 0))
				# 2. MOVE PROGRESS BAR
				$ProgressBar.value += 1
	
		# See if 100% 
		if $ProgressBar.value == questions.size():
			$NextButton.visible = true
			$NextButton.text = "Leave"
			$ProgressBar/PurifyStatusLabel.text = "Purification completed!"
			await self.moveToNextQuestion
			# If yes, hurray
			isQuestioning = false
			completedChallenge.emit()
		else: 
			# NEXT Q
			$NextButton.visible = true
			await self.moveToNextQuestion
			i += 1
			

			

		
		
	
		
	


	



func _on_answer_button_1_pressed():
	selectedAnswer.emit(1)
func _on_answer_button_2_pressed():
	selectedAnswer.emit(2)
func _on_answer_button_3_pressed():
	selectedAnswer.emit(3)
func _on_answer_button_4_pressed():
	selectedAnswer.emit(4)


func _on_next_button_pressed():
	moveToNextQuestion.emit()
