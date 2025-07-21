extends Node2D

@onready var contenedor: Node2D = self

func _ready() -> void:
	var id := JugadorSeleccionado.obtener_id()
	var ruta := _obtener_ruta_personaje(id)
	
	if ruta != "":
		var escena_personaje := load(ruta)
		var jugador: Node2D = escena_personaje.instantiate()
		jugador.position = Vector2(3, 0) #--Posicion de inicio
		contenedor.add_child(jugador)
	else:
		print("No se cargo el personaje")
	
func _obtener_ruta_personaje(id: int) -> String:
	match id:
		0: return "res://escenas/personajes/Delgado/Delgado.tscn"
		1: return "res://escenas/personajes/Insuasty/Insuasty.tscn"
		2: return "res://escenas/personajes/Jojoa/Jojoa.tscn"
		3: return "res://escenas/personajes/Romo/Romo.tscn"
		_: return ""
