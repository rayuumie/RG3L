extends CharacterBody3D


@export_category(&"Character Atributes")
@export var speed: float = 5.0
@export var numberOfJumps: int = 2
@export var jumpVelocity: float = 4.5
@export var gravity: float = 9.8
@export var rotationSpeed: float = 0.1

@export_category(&"Camera Configuration")
@export var mouseSensitivity: float = 0.0015
@export var cameraSpringLength: float = 2.0
@export var lookUpMaxAngle: float = 90.0
@export var lookDownMaxAngle: float = -80.0


@onready var _cameraPivotY: Node3D = $CameraPivotY
@onready var _cameraPivotX: Node3D = $CameraPivotY/CameraPivotX
@onready var _springArm: SpringArm3D = $CameraPivotY/CameraPivotX/SpringArm
@onready var _model: Node3D = $RogueCharacter
@onready var _jumpCounter: int = numberOfJumps


func _ready() -> void:
	_toggleMouseCaptured()
	_springArm.spring_length = cameraSpringLength


func _input(event: InputEvent) -> void:
	# Press key [TAB] to unlock the mouse
	if Input.is_action_just_pressed(&"ui_unlock_mouse"):
		_toggleMouseCaptured()

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and (event as InputEventMouseMotion):
		_cameraPivotY.rotate_y(-event.relative.x * mouseSensitivity)

		_cameraPivotX.rotate_x(-event.relative.y * mouseSensitivity)
		_cameraPivotX.rotation_degrees.x = clampf(_cameraPivotX.rotation_degrees.x, lookDownMaxAngle, lookUpMaxAngle)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


	if Input.is_action_just_pressed(&"ui_jump") and _jumpCounter > 0:
		velocity.y = jumpVelocity
		_jumpCounter -= 1

	var input_dir = Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	var direction = (_cameraPivotY.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	_model.rotation.y = lerp_angle(_model.rotation.y, _cameraPivotY.rotation.y, rotationSpeed)

	if _jumpCounter < numberOfJumps and is_on_floor():
		_jumpCounter = numberOfJumps


func _toggleMouseCaptured() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
