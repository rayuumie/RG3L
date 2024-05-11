extends CharacterBody3D


@export_category(&"Character Atributes")
@export var speed: float = 5.4
@export var numberOfJumps: int = 2
@export var jumpVelocity: float = 4.5
@export var gravity: float = 9.8
@export var rotationSpeed: float = 0.1

@onready var _jumpCounter: int = numberOfJumps
@onready var _model: Node3D = $RogueCharacter
@onready var _springArm: SpringArm3D = $SpringArm

const HalfPI: float = PI / 2


func _ready() -> void:
	_springArm.add_excluded_object(get_rid())


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

		# The (-) and HalfPI are used to offset the rotation of the model where
		# front is Godot Z+, Blender Y-
		var angleMotion: float = atan2(-input_dir.y, input_dir.x) + HalfPI
		_model.rotation.y =  lerp_angle(_model.rotation.y, angleMotion, rotationSpeed)

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if _jumpCounter < numberOfJumps and is_on_floor():
		_jumpCounter = numberOfJumps
