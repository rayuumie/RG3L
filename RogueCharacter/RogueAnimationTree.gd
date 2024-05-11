extends AnimationTree


# This is necessary so that we can use the Character Velocity,
# and is_on_floor() as conditions to advance the animations
# on the connections of the AnimationTree
@export var character: CharacterBody3D = null
