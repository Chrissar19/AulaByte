extends Node2D

@onready var contenedor: Node2D = self
@onready var puntos_inicio: Marker2D = $PuntosInicio/InicioPrincipal

func _ready() -> void:
	var id := JugadorSeleccionado.obtener_id()
	var ruta := _obtener_ruta_personaje(id)
	
	if ruta != "":
		var escena_personaje := load(ruta)
		var jugador: Node2D = escena_personaje.instantiate()
		jugador.global_position = puntos_inicio.global_position #--Posicion de inicio
		contenedor.add_child(jugador)
	
		#-- Instanciar y cargar HUD
		var hud_escena = load("res://escenas/ui/hud.tscn")
		var hud = hud_escena.instantiate()
		add_child(hud)
		
		#-- Pasar el HUD al jugador
		if jugador.has_method("set_hud"):
			jugador.set_hud(hud)
	
	else:
		print("No se cargo el personaje")
	
func _obtener_ruta_personaje(id: int) -> String:
	match id:
		0: return "res://escenas/personajes/Delgado/Delgado.tscn"
		1: return "res://escenas/personajes/Insuasty/Insuasty.tscn"
		2: return "res://escenas/personajes/Jojoa/Jojoa.tscn"
		3: return "res://escenas/personajes/Romo/Romo.tscn"
		_: return ""
