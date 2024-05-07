extends CharacterBody2D

@export var action_suffix := ""

const SPEED = 300.0
const ACCELERATION_SPEED = SPEED * 6.0
const JUMP_VELOCITY = -565.0
const TERMINAL_VELOCITY = 700.0  # Define TERMINAL_VELOCITY constant

@onready var sprite_2d = $Sprite2D  # Reference to the Sprite2D node for the main character
@onready var jump_sound := $Jump 
@onready var animation_player = $AnimationPlayer 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _double_jump_charged = false
var last_facing_direction = 1  # 1 for right, -1 for left

var is_attacking = false

func _physics_process(delta):
	if is_on_floor():
		_double_jump_charged = true
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		velocity.y *= 0.6

	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	if is_attacking == false:
		var direction = Input.get_axis("left" + action_suffix, "right" + action_suffix)
		if direction != 0:
			last_facing_direction = sign(direction)
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION_SPEED * delta)
	else: 
		var direction = Input.get_axis("left" + action_suffix, "right" + action_suffix)
		velocity.x = 0

	if not is_attacking:
		if abs(velocity.x) > 1:
			animation_player.play("run")
		else:
			animation_player.play("idle")

	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		velocity.x = 0
		velocity.y = 0
		animation_player.play("attack")
		await get_tree().create_timer(1).timeout
		is_attacking = false
		if abs(velocity.x) > 1:
			animation_player.play("run")
		else:
			animation_player.play("idle")

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
