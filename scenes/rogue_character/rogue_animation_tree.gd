extends AnimationTree


# This is necessary so that we can use the Character velocity,
# and is_on_floor() as conditions to advance the animations
# on the connections of the AnimationTree
@export var character: CharacterBody3D = null

@onready var _state_machine: AnimationNodeStateMachinePlayback = get(&"parameters/playback")


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed(&"cheer"):
		_state_machine.travel(&"Cheer")
