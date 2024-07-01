extends CharacterBody2D

const MAX_SPEED = 90.0
const FRICTION = 450
const GRAVITY = 600
const ACCEL = 2300

var facingFront = true
@export var isFalling = false
@export var isMovementDisabled = false

func _physics_process(delta):
	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if isFalling:
		$PlayerPos.disabled = true 
		if facingFront:
			$AnimationPlayer.play("idle_front")
		else:
			$AnimationPlayer.play("idle_back")
		velocity.y += GRAVITY * delta
		z_index	= 0
		

		
	else:
		z_index	= 1
		$PlayerPos.disabled = false
		if direction:
			self.velocity += direction * ACCEL * delta 
			velocity = velocity.limit_length(MAX_SPEED)
			#velocity = direction * MAX_SPEED
			if velocity.y > 0:
				#Front
				$AnimationPlayer.play("front_walk")
				$Sprite2D.flip_h = velocity.x > 0
				facingFront = true
			elif velocity.y < 0:
				#Back
				$AnimationPlayer.play("back_walk")
				$Sprite2D.flip_h = velocity.x < 0
				facingFront = false
			else:
				$AnimationPlayer.play("front_walk")
				$Sprite2D.flip_h = velocity.x > 0
				facingFront = true
		else:
			if facingFront:
				$AnimationPlayer.play("idle_front")
			else:
				$AnimationPlayer.play("idle_back")
			
			velocity = Vector2.ZERO
	if !isMovementDisabled:
		move_and_slide()
	
func player():
	pass
