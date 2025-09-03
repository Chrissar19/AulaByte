extends CharacterBody2D

func _process(delta: float) -> void:
	var nodo_padre := get_parent()
	if nodo_padre is Node2D:
		global_position = nodo_padre.global_position
