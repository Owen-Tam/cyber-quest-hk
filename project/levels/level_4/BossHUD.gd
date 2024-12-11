extends Control
signal completedBoss
signal submittedAnswer



func _process(float):
	if ($Timer):
		$Timer_Control/timer_label.text = str(round($Timer.time_left))

var questionAnswer = [
	{
		"from": "support@banksecure.com",
		"subject": "Urgent: Verify Your Account Information",
		"body": "Dear Customer,\n\nWe have detected unusual activity in your account. Please verify your information immediately to avoid suspension.\nClick here: [u][color=FF6400]Verify Now[/color][/u]\n\nThank you,\nBank Secure Team",
		"phishing": true,
		"justification": "The email is from a suspicious domain and urges immediate action, creating a sense of urgency."
	},
	{
		"from": "info@dbspd.edu",
		"subject": "Important School Event Announcement",
		"body": "Dear Parents,\n\nWe are excited to announce our upcoming school event next week! For more details, visit our website: [u][color=FF6400]School Events[/color][/u].\n\nBest,\nSchool Administration",
		"phishing": false,
		"justification": "This email comes from a legitimate school domain and provides useful information about a school event."
	},
	{
		"from": "newsletter@hobbyclub.com",
		"subject": "Monthly Hobby Club Newsletter",
		"body": "Hi Hobbyist,\n\nCheck out our latest newsletter for tips and events! Visit: [u][color=FF6400]Club Newsletter[/color][/u].\n\nBest,\nHobby Club",
		"phishing": false,
		"justification": "This email comes from a recognized hobby club and shares legitimate information without asking for personal details."
	},
	{
		"from": "info@unknownsource.com",
		"subject": "Congratulations! You've Won a Prize!",
		"body": "Dear Winner,\n\nYou have been selected to win a gift card! Claim your prize here: [u][color=FF6400]Claim Now[/color][/u].\n\nBest,\nPrize Team",
		"phishing": true,
		"justification": "The email comes from an unknown source and promotes a prize that seems too good to be true, a common tactic in scams."
	},
	{
		"from": "support@decesanboysschool.edu",
		"subject": "Urgent: Account Verification Required",
		"body": "Dear Student,\n\nWe noticed unusual activity on your school account. Please verify your account here: [u][color=FF6400]https://decesanboysschool.edu/verifyAccount[/color][/u] to avoid suspension.\n\nThank you,\nDiocesan Boys' School IT Support",
		"phishing": true,
		"justification": "This email creates a false sense of urgency and directs users to verify their account through a suspicious link. The email address also includes a misspelled school name."
	},
	{
		"from": "info@school.edu",
		"subject": "Field Trip Permission Slip",
		"body": "Hello Parents,\n\nYour child is invited to a field trip next week! Please fill out the permission slip: [u][color=FF6400]Permission Slip[/color][/u].\n\nBest,\nSchool Administration",
		"phishing": false,
		"justification": "The email is from a recognized school domain and includes relevant information for parents."
	},
	{
		"from": "noreply@diocesanboyssch00l.edu",
		"subject": "Your Feedback is Needed!",
		"body": "Dear Student,\n\nWe’d love to hear your thoughts! Take this survey: [u][color=FF6400]Feedback Survey[/color][/u].\n\nThank you,\nSchool Committee",
		"phishing": true,
		"justification": "The email requests feedback through a link that could lead to a phishing site. No further context is given about the survey and the email address is misspelled."
	},
	{
		"from": "noreply@thelibrary.com",
		"subject": "Your Library Account Needs Attention",
		"body": "Dear Student,\n\nThere is an issue with your library account. Please verify it here: [u][color=FF6400]https://dbspd/thelibrary.com[/color][/u].\n\nThank you,\nLibrary Staff",
		"phishing": true,
		"justification": "The email creates a sense of urgency and requests verification through a suspicious link. The email address and url is also suspicious."
	},
]

const correctColor = Color8(93, 232, 93)
const incorrectColor  = Color8(232, 88, 88)

var failed = false

func startBossBattle():
	var time_per_q = 10
	var failedAttempts = 0 
	failed = false
	randomize()
	questionAnswer.shuffle()
	# completed text

	for question in questionAnswer:
		$Answer_Control.visible = false
		$Email_Control.visible = true
		$Timer_Control.visible = true
		$next_button.visible = false
		$Button_Control.visible = true
		$Email_Control/from_label.text = "From: [u][color=FF6400]%s[/color][/u]" % question.from
		$Email_Control/subject_label.text = "Subject: %s" % question.subject
		$Email_Control/body_label.text = question.body
		var model_ans = question.phishing
		var justification = question.justification
		$Timer.start(time_per_q)
		var submittedAns = await submittedAnswer
		$Timer.stop()
		$Button_Control.visible = false
		if (submittedAns != model_ans):
			# WRONK
			failedAttempts += 1
			$ObjectiveLabel.text = "Objective: Distinguish whether the incoming email is a phishing email or a legitimate one; %s/3 fails" % failedAttempts
			$Answer_Control/feedback.text = "Incorrect!"
			$Answer_Control/feedback.add_theme_color_override("font_color", incorrectColor)
		else:
			# RIGHT
			$Answer_Control/feedback.text = "Correct!"
			$Answer_Control/feedback.add_theme_color_override("font_color", correctColor)
		
		$Answer_Control/justification.text = justification
		$Answer_Control.visible = true
		$Timer_Control.visible = false
		$next_button.visible = true
		await $next_button.pressed
		
		if failedAttempts >= 3:
			failed = true
			break
	
	$Email_Control.visible = false
	$Timer_Control.visible = false
	$next_button.visible = false
	$leave_button.visible = false
	$Answer_Control.visible = false
	
	if failed:
		$CompletedText.text = "You were mind-controlled by Malware Master. Try again."
	else:
		$ObjectiveLabel.text = "Objective completed! Leave the GUI now."
		$CompletedText.text = "You've blocked Malware Master's attacks"
	$CompletedText.visible = true
	$leave_button.visible = true

	
	
	# purify the land in main


func _on_leave_button_pressed():
	print("LEAVE")
	completedBoss.emit(failed)


func _on_legit_button_pressed():
	submittedAnswer.emit(false)


func _on_phish_button_pressed():
	submittedAnswer.emit(true)


func _on_timer_timeout():
	submittedAnswer.emit(null)
