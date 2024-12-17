extends CharacterBody2D

const SPEED = 400.0
const ACCELERATION = 1500
const FRICTION = 1000

func player_movement(input, delta):

	if input: velocity = velocity.move_toward(input * SPEED , delta * ACCELERATION)

	else: velocity = velocity.move_toward(Vector2(0,0), delta * FRICTION)


func _physics_process(delta):

	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")

	player_movement(input, delta)

	move_and_slide()
