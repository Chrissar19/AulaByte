extends AnimatableBody2D
class_name PlataformaMovil

func _ready() -> void:
	z_index = ZCapas.PLATAFORMAS
	add_to_group("Z_PLATAFORMAS")
	sync_to_physics = true

func _physics_process(_delta: float) -> void:
	var nodo_padre := get_parent()
	
	if nodo_padre is Node2D:
		global_position = nodo_padre.global_position
