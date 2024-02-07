extends CharacterBody3D


@export_category("Character Atributes")
@export var speed: float = 5.4
@export var rotation_speed: float = 0.1


# PRIVATE
@onready var _model: Node3D = $Model
@onready var _spring_arm: SpringArm3D = $SpringArm
@onready var _space_state = get_world_3d().direct_space_state
@onready var _camera: Camera3D = $SpringArm/Camera
@onready var _viewport: Viewport = get_viewport()
@onready var _navigation_agent: NavigationAgent3D = $NavigationAgent


const HALF_PI: float = PI / 2
const RAY_LENGTH: float = 1000.0


func _ready() -> void:
	# Avoid the spring arm colliding with the character
	_spring_arm.add_excluded_object(get_rid())

	_navigation_agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(_delta: float) -> void:
	# Get a point for move to
	if Input.is_action_just_pressed(&"PICK"):
		var from = _camera.project_ray_origin( _viewport.get_mouse_position() )
		var to = from + _camera.project_ray_normal( _viewport.get_mouse_position() ) * RAY_LENGTH

		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [self]

		var result = _space_state.intersect_ray(query)

		if result:
			set_movement_target(result.position)

	# Movement
	if _navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector3 = _navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed

	if _navigation_agent.avoidance_enabled:
		_navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func set_movement_target(movement_target: Vector3) -> void:
	_navigation_agent.set_target_position(movement_target)


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()

	# Rotate the character
	var angle_motion: float = atan2(-safe_velocity.z, safe_velocity.x) + HALF_PI
	_model.rotation.y =  lerp_angle(_model.rotation.y, angle_motion, rotation_speed)
