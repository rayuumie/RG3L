extends Area3D


func _ready() -> void:
	body_entered.connect(on_character_body_entered)


func on_character_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		# Do something here
		print("Have fun with game dev... you can do it. ❤(^_^)")
