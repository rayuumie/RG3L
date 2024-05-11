extends CharacterBody3D


@export_category(&"Character Atributes")
@export var speed: float = 5.0
@export var numberOfJumps: int = 2
@export var jumpVelocity: float = 4.5
@export var gravity: float = 9.8
@export var rotationSpeed: float = 6.0

@export_category(&"Camera Configuration")
@export var cameraSpringLength: float = 5.0
@export var mouseSensitivity: float = 0.0015
@export var cameraZoomStep: float = 1.0
@export var cameraZoomSmoothness: float = 4.0
@export var cameraMaxZoom: float = 15.0
@export var cameraMinZoom: float = 2.0
@export var lookUpMaxAngle: float = 90.0
@export var lookDownMaxAngle: float = -80.0

@onready var _cameraPivotY: Node3D = $CameraPivotY
@onready var _cameraPivotX: Node3D = $CameraPivotY/CameraPivotX
@onready var _springArm: SpringArm3D = $CameraPivotY/CameraPivotX/SpringArm
@onready var _model: Node3D = $RogueCharacter
@onready var _jumpCounter: int = numberOfJumps

const HalfPI: float = PI / 2


func _ready() -> void:
	# Avoid the spring_arm colliding with the Character
	_springArm.add_excluded_object(get_rid())

	_springArm.spring_length = cameraSpringLength


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed(&"ui_camera_rotation") and (event as InputEventMouseMotion):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		_cameraPivotY.rotate_y(-event.relative.x * mouseSensitivity)

		_cameraPivotX.rotate_x(-event.relative.y * mouseSensitivity)
		_cameraPivotX.rotation_degrees.x = clampf(_cameraPivotX.rotation_degrees.x, lookDownMaxAngle, lookUpMaxAngle)

	if Input.is_action_just_released(&"ui_camera_rotation"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_pressed(&"ui_camera_zoom_up"):
		cameraSpringLength = clampf(cameraSpringLength + cameraZoomStep, cameraMinZoom, cameraMaxZoom)


	if Input.is_action_pressed(&"ui_camera_zoom_down"):
		cameraSpringLength = clampf(cameraSpringLength - cameraZoomStep, cameraMinZoom, cameraMaxZoom)


func _process(delta: float) -> void:
	if cameraSpringLength != _springArm.spring_length:
		_springArm.spring_length = lerpf(_springArm.spring_length, cameraSpringLength, delta * cameraZoomSmoothness)


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

		# Rotates the Model only when theres Directional Input, allowing the Player to see the front
		# of the Character, when not inputing movement.
		var angle = atan2(direction.z, -direction.x) + HalfPI
		_model.rotation.y  = lerp_angle(_model.rotation.y, angle, delta * rotationSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if _jumpCounter < numberOfJumps and is_on_floor():
		_jumpCounter = numberOfJumps
