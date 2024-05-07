extends CharacterBody2D

@export var action_suffix := ""

const SPEED = 300.0
const ACCELERATION_SPEED = SPEED * 6.0
const JUMP_VELOCITY = -565.0
const TERMINAL_VELOCITY = 700.0  # Define TERMINAL_VELOCITY constant

@onready var sprite_2d = $Sprite2D  # Reference to the Sprite2D node for the main character
@onready var jump_sound := $Jump 
@onready var animation = $AnimationPlayer 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Declare _double_jump_charged at the top of the script
var _double_jump_charged = false
var doubleSpace := false 
var last_facing_direction = 1  # 1 for right, -1 for left

func _physics_process(delta):
	if is_on_floor():
		_double_jump_charged = true  # Reset the double jump charge when on the floor
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6

	# Handle vertical and horizontal movements.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	var direction := Input.get_axis("left" + action_suffix, "right" + action_suffix)
	if direction != 0:
		last_facing_direction = sign(direction)  # Update last known direction
	velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION_SPEED * delta)

	# Handle animations and direction.
	if abs(velocity.x) > 1:
		sprite_2d.animation = "walking"
	else:
		sprite_2d.animation = "default"
	
	if Input.is_action_just_pressed("attack"):
		animation.play("attacking")
	
	# Perform movement and handle sprite flipping based on last facing direction.
	move_and_slide()
	sprite_2d.flip_h = last_facing_direction == -1

func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 0.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()
