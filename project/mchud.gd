extends Control

signal selectedAnswer(selectedIndex)
signal moveToNextQuestion
signal completedChallenge


var isQuestioning = false
var questionDB = [[{
"question": "What is the primary purpose of using a password?",
"answers": [
	"To make it easier to remember account login information",
	"To prevent unauthorized access to personal or sensitive information",
	"To comply with website security policies",
	"To avoid having to type in a username every time"
], "correctIndex": 2 },
{
"question": "What are the risks of not properly safeguarding your passwords?",
"answers": [
	"Someone could gain access to your accounts and personal information",
	"There are no real risks, passwords aren't that important",
	"Your accounts may become unusable if you forget your passwords",
	"Your friends and family won't be able to access your accounts"
], "correctIndex": 1 },
{
"question": "Which of the following does not need a password?",
"answers": [
	"Mobile Phone",
	"Mobile banking",
	"Program installation",
	"Scientific calculator"
], "correctIndex": 4 },
{
"question": "Is it necessary to keep passwords secure even if they’re easy to remember?",
"answers": [
	"No, because easy-to-remember passwords are inherently secure",
	"Yes, because attackers can exploit weak passwords.",
	"Easy-to-remember passwords are always secure",
	"Only websites require secure passwords"
], "correctIndex": 2 }], 
[{
"question": "What makes a password considered 'strong' and secure?",
"answers": [
	"A password that is easy to remember, like your birthdate",
	"A short, simple password that is the same across all your accounts",
	"A long, complex password with a mix of characters and numbers",
	"A password that is automatically generated and stored in your browser"
], "correctIndex": 3
}, {
"question": "What characters should you include in a password?",
"answers": [
	"Special characters like @",
	"Both upper and lower case letters",
	"Numbers",
	"All of the above"
], "correctIndex": 4
},
{
"question": "Your friend asks for your gmail account's password, should you...",
"answers": [
	"Refuse; Never tell anyone your passwords",
	"Tell him",
	"Tell him if you know him in real life",
	"Ask for his password first"
], "correctIndex": 1
}, 
{
"question": "Longer passwords are stronger because...",
"answers": [
	"They must be more complex",
	"They take longer to bruteforce",
	"They are more difficult to remember",
	"Hackers are confused by longer passwords"
], "correctIndex": 2
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
			print(selectedIndex, currentQuestionObj.correctIndex)
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
