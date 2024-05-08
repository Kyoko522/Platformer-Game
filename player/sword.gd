extends Area2D

@export var damage: int = 20
var is_attacking = false

func _ready():
	monitoring = false
	print("Ready to me used")

func _on_body_entered(body):
	print("is the On Body Entered function")
	# Check if the body has a property 'is_attacking' and if it's true
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		for child in body.get_children():
			if child is Damagable:
				child.hit(20)
				print(body.name + " took " + str(damage) + " damage.")
		is_attacking = false
	else:
		for child in body.get_children():
			if child is Damagable:
				print("Player has hit a " + body.name + " but is not attacking.")
