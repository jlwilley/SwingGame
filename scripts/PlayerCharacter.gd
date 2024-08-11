extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var grappled = false
var grapple_point = Vector2()
var max_grapple_distance = 500

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	
	if Input.is_action_just_released("grapple"):
		grappled = false
		print("released")
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("grapple"):
		if !grappled:
			grapple()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func grapple():
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = player_pos
	query.to = mouse_pos	
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Grappled to: ", result.collider)
		grappled = true
		grapple_point = result.position
		
