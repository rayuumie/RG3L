extends CharacterBody3D


@export_category("Character Atributes")
@export var speed: float = 5.4
@export var number_of_jumps: int = 2
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var rotation_speed: float = 0.1

# PRIVATE
@onready var _jump_counter: int = number_of_jumps
@onready var _model: Node3D = $Model
@onready var _spring_arm: SpringArm3D = $SpringArm

const HALF_PI: float = PI / 2


func _ready() -> void:
	_spring_arm.add_excluded_object(get_rid())


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed(&"JUMP") and _jump_counter > 0:
		velocity.y = jump_velocity
		_jump_counter -= 1

	var input_dir = Input.get_vector(&"LEFT", &"RIGHT", &"UP", &"DOWN")
	var direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# The (-) and HALF_PI are used to offset the rotation of the model where
		# front is Godot Z+, Blender Y-
		var angle_motion: float = atan2(-input_dir.y, input_dir.x) + HALF_PI
		_model.rotation.y =  lerp_angle(_model.rotation.y, angle_motion, rotation_speed)

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if _jump_counter < number_of_jumps and is_on_floor():
		_jump_counter = number_of_jumps
