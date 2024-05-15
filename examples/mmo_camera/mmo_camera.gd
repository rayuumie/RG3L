extends CharacterBody3D


@export_category(&"Character Atributes")
@export var speed: float = 5.0
@export var number_of_jumps: int = 2
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var rotation_speed: float = 6.0

@export_category(&"Camera Configuration")
@export var camera_spring_length: float = 5.0
@export var mouse_sensitivity: float = 0.0015
@export var camera_zoom_step: float = 1.0
@export var camera_zoom_smoothness: float = 4.0
@export var camera_max_zoom: float = 15.0
@export var camera_min_zoom: float = 2.0
@export var look_up_max_angle: float = 90.0
@export var look_down_max_angle: float = -80.0

@onready var _camera_pivot_y: Node3D = $CameraPivotY
@onready var _camera_pivot_x: Node3D = $CameraPivotY/CameraPivotX
@onready var _spring_arm: SpringArm3D = $CameraPivotY/CameraPivotX/SpringArm
@onready var _model: Node3D = $Model
@onready var _jump_counter: int = number_of_jumps

const HALF_PI: float = PI / 2.0


func _ready() -> void:
	# Avoid the spring_arm colliding with the Character
	_spring_arm.add_excluded_object(get_rid())

	_spring_arm.spring_length = camera_spring_length


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed(&"camera_rotation") and (event as InputEventMouseMotion):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		_camera_pivot_y.rotate_y(-event.relative.x * mouse_sensitivity)

		_camera_pivot_x.rotate_x(-event.relative.y * mouse_sensitivity)
		_camera_pivot_x.rotation_degrees.x = clampf(_camera_pivot_x.rotation_degrees.x, look_down_max_angle, look_up_max_angle)

	if Input.is_action_just_released(&"camera_rotation"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_pressed(&"camera_zoom_up"):
		camera_spring_length = clampf(camera_spring_length + camera_zoom_step, camera_min_zoom, camera_max_zoom)

	if Input.is_action_pressed(&"camera_zoom_down"):
		camera_spring_length = clampf(camera_spring_length - camera_zoom_step, camera_min_zoom, camera_max_zoom)


func _process(delta: float) -> void:
	if camera_spring_length != _spring_arm.spring_length:
		_spring_arm.spring_length = lerpf(_spring_arm.spring_length, camera_spring_length, delta * camera_zoom_smoothness)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed(&"jump") and _jump_counter > 0:
		velocity.y = jump_velocity
		_jump_counter -= 1

	var input_dir = Input.get_vector(&"left", &"right", &"up", &"down")
	var direction = (_camera_pivot_y.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# Rotates the Model only when theres Directional Input, allowing the Player to see the front
		# of the Character, when not inputing movement.
		var angle = atan2(-direction.z, direction.x) + HALF_PI
		_model.rotation.y  = lerp_angle(_model.rotation.y, angle, delta * rotation_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if _jump_counter < number_of_jumps and is_on_floor():
		_jump_counter = number_of_jumps
