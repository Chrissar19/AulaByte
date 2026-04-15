extends CanvasLayer

func _ready() -> void:
	var es_movil = DisplayServer.is_touchscreen_available()
	
	#if es_movil:
	#	show()
	#else:
	#	hide()
	if not es_movil:
		queue_free()
		return
	GameManager.estado_cambiado.connect(_on_estado_juego_cambiado)
	
	_actualizar_visibilidad(GameManager.estado_actual)
	
func _on_estado_juego_cambiado(nombre_estado: String) -> void:
	if nombre_estado == "JUGANDO":
		show()
	else:
		hide()
		
func _actualizar_visibilidad(estado_id: int) -> void:
	if estado_id == GameManager.EstadoJuego.JUGANDO:
		show()
	else:
		hide()
