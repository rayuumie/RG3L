extends CharacterBody3D


@export_category(&"Character Atributes")
@export var speed: float = 4.0
@export var numberOfJumps: int = 2
@export var jumpVelocity: float = 4.5
@export var gravity: float = 9.8

@export_category(&"Camera Configuration")
@export var mouseSensitivity: float = 0.0015
@export var lookUpMaxAngle: float = 90.0
@export var lookDownMaxAngle: float = -80.0

@onready var _cameraPivot: Node3D = $CameraPivot
@onready var _jumpCounter: int = numberOfJumps


func _ready() -> void:
	_toggleMouseCaptured()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotates the whole Character on the Y axis, which also rotates the child CameraPivot on Y.
		rotate_y(-event.relative.x * mouseSensitivity)

		# Rotates the CameraPivot only on the X axis
		_cameraPivot.rotate_x(-event.relative.y * mouseSensitivity)
		_cameraPivot.rotation_degrees.x = clampf(_cameraPivot.rotation_degrees.x, lookDownMaxAngle, lookUpMaxAngle)


	if Input.is_action_just_pressed(&"ui_unlock_mouse"):
		_toggleMouseCaptured()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed(&"ui_jump") and _jumpCounter > 0:
		velocity.y = jumpVelocity
		_jumpCounter -= 1

	var input_dir = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if _jumpCounter < numberOfJumps and is_on_floor():
		_jumpCounter = numberOfJumps


func _toggleMouseCaptured() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
