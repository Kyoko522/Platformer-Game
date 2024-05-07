extends CharacterBody2D

const WALK_SPEED = 150.0
var is_facing_right = false  # Keeps track of the current direction

var gravity = ProjectSettings.get("physics/2d/default_gravity")

var health = 50

@onready var floor_detector_2 = $FloorDetector2 as RayCast2D
@onready var floor_detector = $FloorDetector as RayCast2D
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	floor_detector.enabled = true
	floor_detector_2.enabled = true

func _physics_process(delta):
	if floor_detector.is_colliding() and floor_detector_2.is_colliding():
		# Keep moving in the current direction
		velocity.x = WALK_SPEED if is_facing_right else -WALK_SPEED
		animation_player.play("run")  # Play walking animation
	else:
		# If no floor, turn around
		is_facing_right = not is_facing_right
		velocity.x = WALK_SPEED if is_facing_right else -WALK_SPEED
		animation_player.play("run")  # Play walking animation

	velocity.y += gravity * delta  # Apply gravity
	move_and_slide()  # Assuming this function is adapted to use internal velocity

	# Optionally, update the sprite direction
	sprite_2d.flip_h = not is_facing_right

func update_floor_detector_direction():
	# Adjust the RayCast2D position and direction based on the facing direction
	if is_facing_right:
		floor_detector.position.x = abs(floor_detector.position.x)
		floor_detector.cast_to = Vector2(0, 50)  # Adjust if needed
	else:
		floor_detector.position.x = -abs(floor_detector.position.x)
		floor_detector.cast_to = Vector2(0, 50)  # Adjust if needed

