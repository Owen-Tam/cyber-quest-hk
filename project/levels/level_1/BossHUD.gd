extends Control

signal submittedAns
signal completedBoss(failed)


const correctColor = Color8(93, 232, 93)
const incorrectColor  = Color8(232, 88, 88)
var questions = [
	{
		"question": "Cybersecurity is only important for large companies and not for individuals or students.",
		"answer": false,
		"explanation": "Cybersecurity is essential for everyone, including individuals and students, as they can also be targets of cyber attacks."
	},
	{
		"question": "Sharing your full name, address, and phone number on social media is safe if your profile is private.",
		"answer": false,
		"explanation": "Even with privacy settings, shared information can be exposed or misused, making it unsafe to share sensitive data."
	},
	{
		"question": "It’s unsafe to share personal information in public chat rooms even when most users are trustworthy.",
		"answer": true,
		"explanation": "Public chat rooms can expose you to unknown individuals, increasing the risk of data theft or harassment."
	},
	{
		"question": "Cybersecurity measures are only necessary when using a computer, not on mobile devices.",
		"answer": false,
		"explanation": "Mobile devices are just as vulnerable to cyber threats and require strong security measures."
	},
	{
		"question": "Educating yourself about personal information security can help protect you from cyber threats.",
		"answer": true,
		"explanation": "Knowledge about cybersecurity helps individuals recognize threats and take preventive actions."
	},
	{
		"question": "Not all websites that require personal information are secure and trustworthy.",
		"answer": true,
		"explanation": "Many websites can be fraudulent or compromised, so it's crucial to verify their security before sharing information."
	},
	{
		"question": "It’s a good idea to post your achievements and personal milestones on public forums.",
		"answer": false,
		"explanation": "Sharing personal milestones publicly can expose you to privacy risks and unwanted attention."
	},
	{
		"question": "You can trust requests for personal information if they come from someone with a verified account.",
		"answer": false,
		"explanation": "Verified accounts can still be compromised; always exercise caution before sharing personal information."
	},
	{
		"question": "You should always verify the identity of someone before sharing personal information with them online.",
		"answer": true,
		"explanation": "Verifying identity helps prevent scams and unauthorized access to your personal information."
	},
	{
		"question": "You don't have to pay as much attention to sharing personal information in real life as online.",
		"answer": false,
		"explanation": "Both online and offline sharing can pose risks, so it's important to be cautious in all situations."
	},
];

const LIVES_NUM = 3
	

func startBossBattle():
	$"Q&A_UI".visible = false
	$Completed_UI.visible = false
	$Failed_UI.visible = false
	$Objective_label.visible = true
	$start_button.visible = true
	# completed text
	randomize()
	questions.shuffle()


func _process(float):
	if ($Timer):
		$"Q&A_UI/TimerControl/timer_label".text = str(round($Timer.time_left))

func _on_start_button_pressed():
	var time_per_q = 10
	$"Q&A_UI".visible = true
	var failed = false
	$Objective_label.visible = false
	$start_button.visible = false
	$"Q&A_UI/ProgressBar".max_value = LIVES_NUM
	$"Q&A_UI/ProgressBar".value = LIVES_NUM
	for question in questions:
		$"Q&A_UI/TimerControl".visible = true
		$"Q&A_UI/true_button".disabled = false
		$"Q&A_UI/false_button".disabled = false
		$"Q&A_UI/next_button".visible = false
		$Timer.start(time_per_q)
		
		$"Q&A_UI/Statement_label".text = question.question
		var correct_ans = question.answer
		var explanation = question.explanation
		$"Q&A_UI/explanation_label".visible = false
		var submitted_ans = await submittedAns
		$Timer.stop()
			
		if correct_ans == submitted_ans:
			# correct
			$"Q&A_UI/explanation_label".text = "Correct! " + question.explanation
			$"Q&A_UI/explanation_label".add_theme_color_override("font_color", correctColor)
		else: 
			$"Q&A_UI/explanation_label".text = "Incorrect! " + question.explanation
			$"Q&A_UI/explanation_label".add_theme_color_override("font_color", incorrectColor)
			time_per_q -= 1
			$"Q&A_UI/ProgressBar".value -= 1
		
		$"Q&A_UI/explanation_label".visible = true
		$"Q&A_UI/true_button".disabled = true
		$"Q&A_UI/false_button".disabled = true
		$"Q&A_UI/TimerControl".visible = false
		$"Q&A_UI/next_button".visible = true
		await $"Q&A_UI/next_button".pressed
		if $"Q&A_UI/ProgressBar".value <= 0:
			failed = true
			break
	$"Q&A_UI".visible = false
	if !failed:
		$Completed_UI.visible = true
	else:
		$Failed_UI.visible = true

func _on_true_button_pressed():
	submittedAns.emit(true)


func _on_false_button_pressed():
	submittedAns.emit(false)


func _on_timer_timeout():
	submittedAns.emit(null)


func _on_leave_button_pressed():
	completedBoss.emit(false)


func _on_failed_button_pressed():
	completedBoss.emit(true)
