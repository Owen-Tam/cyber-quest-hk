extends Control

signal submittedPwd
signal completedBoss(failed)
var allowed_characters = r'^[a-zA-Z\d!@#$%^&*(),.?":{}|<>\-_+=\/\\\[\]]+$'


var inputtedPassword
const scoreGoal = 150
const maxAttempts= 10
var failed = false

func generateAttemptsText(attempts):
	var str = ""
	
	for i in range(attempts.size()):
		var color
		if (attempts[i].strength >= 7):
			color = "#69ff9d"
		elif (attempts[i].strength >= 5):
			color = "#faff69"
		else:
			color = "#ff7d69"

		str += "[color=" + color + "]" + attempts[i].pwd + "[/color]"
		if i < attempts.size() - 1:
			str += ", "
	return str
func generateScoreText(score):
	var str = "[center]Score: "
	var color
	if (score >= scoreGoal * 0.85):
		color = "#69ff9d"
	elif (score >= scoreGoal * 0.5):
		color = "#faff69"
	else:
		color = "#fff"
	str += "[color=" + color + "]" + str(score)
	str += "/" + str(scoreGoal) + "[/color][/center]"
	return str
func startBossBattle():
	var score = 0 
	failed = false
	var attempts = []
	$ScoreLabel.visible = true
	$SubmitButton.visible = true
	$LineEdit.visible = true
	$LeaveButton.visible = false
	$CompletedText.visible = false
	$ObjectiveLabel.text = "Objective: Reach " + str(scoreGoal) + " password strength score within " + str(maxAttempts) + " attempts to prevent Malware Master from cracking the passwords."
	$AttemptCounterLabel.text = "Attempts: " + str(attempts.size()) + "/10"
	$ScoreLabel.text = generateScoreText(score)
	$AttemptsLabel.text = generateAttemptsText(attempts)
	while score < scoreGoal:
		await submittedPwd
		var strength = check_password_strength(inputtedPassword, attempts)
		if strength >= 7:
			score += 30
		elif strength >= 5:
			score += 20
		else:
			score += 5
		attempts.push_front({"pwd": inputtedPassword, "strength": strength})
		inputtedPassword = ""
		$LineEdit.set_text("")
		$AttemptCounterLabel.text = "Attempts: " + str(attempts.size()) + "/10"
		$ScoreLabel.text = generateScoreText(score)
		$AttemptsLabel.text = generateAttemptsText(attempts)
		
		if attempts.size() >= 10:
			failed = true
			break
	# completed text
	$LineEdit.visible = false
	$ScoreLabel.visible = false
	$CompletedText.visible = true
	$ObjectiveLabel.text = "Objective completed! Leave the GUI now."
	$CompletedText.text = "You've blocked Malware Master's attacks"
	
	if failed:
		$ObjectiveLabel.text = "Objective failed... Review the past knowledge and try again!"
		$CompletedText.text = "Malware Master hacked you..."

	
	# button to leave
	$SubmitButton.visible = false
	$LeaveButton.visible = true
	# purify the land in main

func _on_line_edit_text_changed(new_text):
	var old_caret_position = $LineEdit.caret_column
	var text = ''
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	for char in new_text:
		if regex.search_all(char).size() > 0:
			text += char
	$LineEdit.set_text(text)
	$LineEdit.caret_column = old_caret_position
	inputtedPassword = text

func logWithBase(value, base): return log(value) / log(base)

func is_all_alphabet(str):
	# Define the regular expression pattern
	var pattern = "^[a-zA-Z]+$"
	var regex = RegEx.new()
	regex.compile(pattern)
	# Use the `match()` method to check if the string matches the pattern
	if regex.search(str):
		return true
	else:
		return false
func check_password_strength(password: String, attempts: Array) -> int:
	var known_passwords = []
	for attempt in attempts:
		known_passwords.push_back(attempt.pwd)
	var strength: int = 0
	# Check length
	if len(password) >= 12:
		strength += 4
	elif len(password) >= 8:
		strength += 3
	else:
		strength += 1
	# Check complexity
	var has_uppercase: bool = false
	var has_lowercase: bool = false
	var has_number: bool = false
	var has_special: bool = false
	
	for char in password:
		if is_all_alphabet(char) && char == char.to_upper():
			has_uppercase = true
		elif is_all_alphabet(char) && char == char.to_lower():
			has_lowercase = true
		elif char.is_valid_int():
			has_number = true
		elif not is_all_alphabet(char):
			has_special = true
	if has_uppercase:
		strength += 1
	if has_lowercase:
		strength += 1
	if has_number:
		strength += 1
	if has_special:
		strength += 1
	
	# Check uniqueness
	if known_passwords.has(password):
		strength -= 4
	
	# Check repeats
	var seq_len: int = 1
	var prev_char: String = ""
	for i in range(len(password)):
		if i > 0 and password[i] == password[i-1]:
			seq_len += 1
		else:
			seq_len = 1
		if seq_len >= 3:
			strength -= 2
			break
	# Ensure strength is between 0 and 8
	strength = clamp(strength, 0, 8)
	return strength
#func checkStrength(pwd):
	#var total = 0
	#for char in pwd:
		#if char.is_valid_int():
			#total+=10
		#if (not char.is_valid_int() and not is_all_alphabet(char) and char!=" "):
			#total+=20
		#if ( is_all_alphabet(char) and char.isupper()):
			#total+=52
		#elif ( is_all_alphabet(char)):
			#total+=26
	#print("CHECKING STRENGTH")
	#return max(min(ceil(logWithBase(pow(pwd.length(), total), 2)/60),5),1)
func _on_submit_button_pressed():
	if inputtedPassword != "":
		submittedPwd.emit()


func _on_leave_button_pressed():
	completedBoss.emit(failed)
