extends Node3D


@export_category(&"Camera Configuration")
@export var target_to_follow: Node3D = null
@export var mouse_sensitivity: float = 0.0015
@export var camera_spring_length: float = 6.0
@export var camera_zoom_step: float = 1.0
@export var camera_zoom_smoothness: float = 4.0
@export var camera_max_zoom: float = 15.0
@export var camera_min_zoom: float = 2.0
@export var look_up_max_angle: float = 90.0
@export var look_down_max_angle: float = -80.0

# PRIVATE
@onready var _camera_pivot_y: Node3D = $CameraPivotY
@onready var _camera_pivot_x: Node3D = $CameraPivotY/CameraPivotX
@onready var _spring_arm: SpringArm3D = $CameraPivotY/CameraPivotX/SpringArm


func _ready() -> void:
	if target_to_follow is PhysicsBody3D:
		_spring_arm.add_excluded_object(target_to_follow.get_rid())

	_spring_arm.spring_length = camera_spring_length


func _process(delta: float) -> void:
	if target_to_follow:
		global_position = global_position.lerp(target_to_follow.position, 0.1)

	if camera_spring_length != _spring_arm.spring_length:
		_spring_arm.spring_length = lerpf(_spring_arm.spring_length, camera_spring_length, 4.0 * delta)


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
