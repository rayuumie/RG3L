extends Node3D


@export_category(&"Camera Configuration")
@export var targetToFollow: Node3D = null
@export var mouseSensitivity: float = 0.0015
@export var cameraSpringLength: float = 6.0
@export var cameraZoomStep: float = 1.0
@export var cameraZoomSmoothness: float = 4.0
@export var cameraMaxZoom: float = 15.0
@export var cameraMinZoom: float = 2.0
@export var lookUpMaxAngle: float = 90.0
@export var lookDownMaxAngle: float = -80.0

# PRIVATE
@onready var _cameraPivotY: Node3D = $CameraPivotY
@onready var _cameraPivotX: Node3D = $CameraPivotY/CameraPivotX
@onready var _springArm: SpringArm3D = $CameraPivotY/CameraPivotX/SpringArm


func _ready() -> void:
	if targetToFollow is PhysicsBody3D:
		_springArm.add_excluded_object(targetToFollow.get_rid())

	_springArm.spring_length = cameraSpringLength


func _process(delta: float) -> void:
	if targetToFollow:
		global_position = global_position.lerp(targetToFollow.position, 0.1)

	if cameraSpringLength != _springArm.spring_length:
		_springArm.spring_length = lerpf(_springArm.spring_length, cameraSpringLength, 4.0 * delta)


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
