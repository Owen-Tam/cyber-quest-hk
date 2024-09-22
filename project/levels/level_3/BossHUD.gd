extends Control

signal completedBoss(failed)

const POSTS = 5
const MAX_HEALTH = 8

const correctColor = Color8(93, 232, 93)
const incorrectColor  = Color8(232, 88, 88)

var answerDB = [
	{
		"correctSeq": [false, true, false, false, false, false],
		"explanation": "Malware Master's location is known by the tags and description of the post."
	},
	{
		"correctSeq": [false, true, true, false, false, true],
		"explanation": "The photo features Malware Master and his friends in school uniform, as well as their location at a specific time."
	}, 
	{
		"correctSeq": [true, true, false, false, false, true],
		"explanation": "This screenshot contains the full name of one of his friends and one of their addresses. Malware Master's face is featured in the profile picture."
	}, 
	{
		"correctSeq": [true, false, true, false, false, true],
		"explanation": "Malware Master's full name and class can be found in the screenshot. Their face is featured in the photo."
	}, 
	{
		"correctSeq": [false, false, false, false, true, false],
		"explanation": "Malware Master's birthday is inferred by the description and date of posting."
	}, 
]



	
func startBossBattle():
	# Reset global things
	$CompletedText.visible = false
	$LeaveButton.visible = false
	$FailedText.visible = false
	$FailedButton.visible = false
	$ProgressBar.visible = true
	$ProgressBar.max_value = MAX_HEALTH
	$ProgressBar.value = MAX_HEALTH
	
	$Post.visible = true
	$ControlBox.visible = true
	var health = MAX_HEALTH
	var failed = false
	
	# Loop through posts
	var playing = true
	var postIndex = 1
	var tryAgain = false
	while (playing):
		var answers = answerDB[postIndex - 1].correctSeq
		var explanation = answerDB[postIndex - 1].explanation
		# Reset per post things
		if !tryAgain:
			$ControlBox/BottomText.text = "Waiting for input..."
			$ControlBox/BottomText.add_theme_color_override("font_color", Color8(255, 255, 255))
		tryAgain = false
		var submittedSeq = []
		for check in $ControlBox/CheckboxContainer.get_children():
			check.button_pressed = false
		$ControlBox/SubmitButton.visible = true
		$ControlBox/NextButton.visible = false
		for post in $Post.get_children():
			post.visible = false
		var post = get_node("Post/Post%s" % (postIndex))
		# Display the post
		post.visible = true
		
		# Await submit
		await $ControlBox/SubmitButton.pressed
		
		# Get answers
		for check in $ControlBox/CheckboxContainer.get_children():
			submittedSeq.push_back(check.button_pressed)
		
		# Check answers
		var correct = true
		
		for k in range(len(submittedSeq)):
			if submittedSeq[k] != answers[k]:
				correct = false
				break
				
		if correct:
			$ControlBox/SubmitButton.visible = false
			$ControlBox/NextButton.visible = true
			$ControlBox/BottomText.text = "Correct! " + explanation
			$ControlBox/BottomText.add_theme_color_override("font_color", correctColor)
			await $ControlBox/NextButton.pressed
			postIndex+=1
			if postIndex > POSTS:
				playing=false
		else:
			$ControlBox/BottomText.text = "Incorrect! " + explanation
			$ControlBox/BottomText.add_theme_color_override("font_color", incorrectColor)
			tryAgain = true
			health -= 1
			$ProgressBar.value = health
			
			if health <= 0:
				playing=false
				failed = true
	
	$ControlBox.visible = false
	$Post.visible = false
	$ProgressBar.visible = false
	if !failed:
		$CompletedText.visible = true
		$LeaveButton.visible = true
	else:
		$FailedText.visible = true
		$FailedButton.visible = true


func _on_leave_button_pressed():
	completedBoss.emit(false)


func _on_failed_button_pressed():
	completedBoss.emit(true)
