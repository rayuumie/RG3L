extends CharacterBody3D


@export_category("Character Atributes")
@export var speed: float = 4.0
@export var number_of_jumps: int = 2
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

@export_category("Camera Configuration")
@export var mouse_sensitivity: float = 0.0015
@export var look_up_max_angle: float = 90.0
@export var look_down_max_angle: float = -80.0

# PRIVATE
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _jump_counter: int = number_of_jumps


func _ready() -> void:
	_toggle_mouse_captured()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotates the whole Character on the Y axis, which also rotates the child CameraPivot on Y.
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotates the CameraPivot only on the X axis
		_camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		_camera_pivot.rotation_degrees.x = clampf(_camera_pivot.rotation_degrees.x, look_down_max_angle, look_up_max_angle)


	if Input.is_action_just_pressed(&"UNLOCK_MOUSE"):
		_toggle_mouse_captured()


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
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if _jump_counter < number_of_jumps and is_on_floor():
		_jump_counter = number_of_jumps


func _toggle_mouse_captured() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
