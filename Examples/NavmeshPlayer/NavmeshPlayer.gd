extends CharacterBody3D


@export_category("Character Atributes")
@export var speed: float = 5.4
@export var rotationSpeed: float = 0.1


# PRIVATE
@onready var _model: Node3D = $Model
@onready var _springArm: SpringArm3D = $SpringArm
@onready var _spaceState = get_world_3d().direct_space_state
@onready var _camera: Camera3D = $SpringArm/Camera
@onready var _viewport: Viewport = get_viewport()
@onready var _navigationAgent: NavigationAgent3D = $NavigationAgent


const HalfPI: float = PI / 2
const RayLength: float = 1000.0


func _ready() -> void:
	# Avoid the spring arm colliding with the character
	_springArm.add_excluded_object(get_rid())

	_navigationAgent.velocity_computed.connect(_onVelocityComputed)


func _physics_process(_delta: float) -> void:
	# Get a point for move to
	if Input.is_action_just_pressed(&"ui_pick"):
		var from = _camera.project_ray_origin( _viewport.get_mouse_position() )
		var to = from + _camera.project_ray_normal( _viewport.get_mouse_position() ) * RayLength

		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [self]

		var result = _spaceState.intersect_ray(query)

		if result:
			setMovementTarget(result.position)

	# Movement
	if _navigationAgent.is_navigation_finished():
		return

	var nextPathPosition: Vector3 = _navigationAgent.get_next_path_position()
	var newVelocity: Vector3 = global_position.direction_to(nextPathPosition) * speed

	if _navigationAgent.avoidance_enabled:
		_navigationAgent.set_velocity(newVelocity)
	else:
		_onVelocityComputed(newVelocity)


func setMovementTarget(movement_target: Vector3) -> void:
	_navigationAgent.set_target_position(movement_target)


func _onVelocityComputed(safeVelocity: Vector3) -> void:
	velocity = safeVelocity
	move_and_slide()

	# Rotate the character
	var angleMotion: float = atan2(-safeVelocity.z, safeVelocity.x) + HalfPI
	_model.rotation.y =  lerp_angle(_model.rotation.y, angleMotion, rotationSpeed)
