extends AnimatableBody2D

func _ready() -> void:
	z_index = ZCapas.PLATAFORMAS
	add_to_group("Z_PLATAFORMAS")

func _process(delta: float) -> void:
	var nodo_padre := get_parent()
	if nodo_padre is Node2D:
		global_position = nodo_padre.global_position
