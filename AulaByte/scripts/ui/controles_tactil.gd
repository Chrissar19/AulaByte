extends CanvasLayer

func _ready() -> void:
	# Solo mostrar en dispositivos moviles
	visible = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")
	
	$Base/Sistema/BtnPausa.pressed.connect(_on_pausa_pressed)
	$Base/Sistema/BtnReset.pressed.connect(_on_reset_pressed)

func _process(_delta: float) -> void:
	# Ocultar controles si no estamos en el estado JUGANDO
	if GameManager.estado_actual != GameManager.EstadoJuego.JUGANDO:
		self.hide()
	else:
		self.show()

func _on_pausa_pressed() -> void:
	GameManager.pausar_juego()

func _on_reset_pressed() -> void:
	GameManager.reintentar_nivel_actual()
