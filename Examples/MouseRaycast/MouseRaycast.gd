extends Node3D


@onready var _spaceState = get_world_3d().direct_space_state
@onready var _camera: Camera3D = $CameraPivot/Camera
@onready var _viewport: Viewport = get_viewport()

const RayLength: float = 1000.0


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_pick"):
		var from = _camera.project_ray_origin( _viewport.get_mouse_position() )
		var to = from + _camera.project_ray_normal( _viewport.get_mouse_position() ) * RayLength

		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
		#query.exclude = [self]

		var result = _spaceState.intersect_ray(query)

		if result:
			print("%s : %v" % [result.collider.name, result.position])
