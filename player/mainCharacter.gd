extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = $AttackTimer  # Reference to the Timer node

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity_value")
var attacking: bool = false

func _ready():
	attack_timer.connect("timeout", Callable(self, "_on_AttackTimer_timeout"))

func _physics_process(delta: float) -> void:
	var direction: float = Input.get_axis("left", "right")

	if not attacking:
		# Update horizontal velocity
		velocity.x = direction * SPEED

		# Animation handling
		if direction != 0:
			sprite_2d.animation = "walking"
			sprite_2d.flip_h = direction < 0
		else:
			sprite_2d.animation = "idle"

		# Handle jumping
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

		# Handle attacking
		if Input.is_action_just_pressed("attack"):
			start_attack()

	# Apply gravity every frame
	velocity.y += gravity * delta

	# Pass the velocity to move_and_slide without any arguments
	move_and_slide()

func start_attack() -> void:
	attacking = true
	sprite_2d.animation = "attacking"
	attack_timer.start()

func _on_AttackTimer_timeout() -> void:
	attacking = false
	sprite_2d.animation = "idle" if velocity.x == 0 else "walking"
