extends Area2D

@onready var animacion_puerta: AnimatedSprite2D = $AnimacionPuerta

var jugador_en_puerta := false

func _ready() -> void:
	animacion_puerta.play("Cerrada")
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	call_deferred("_connect_game_manager_signals")
	
func _process(delta: float) -> void:
	if jugador_en_puerta and Input.is_action_just_pressed("Accion"):
		print("Presionó E en la puerta")
		if GameManager:
			GameManager.solicitar_minijuego() #-- Pide el minijuego
		
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		print("Jugador entró en la puerta")
		jugador_en_puerta = true
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_puerta = false
		
		
func abrir_puerta():
	animacion_puerta.play("Abriendo") 
	await get_tree().create_timer(1.5).timeout
	if GameManager:
		GameManager.siguiente_nivel()
		GameManager.pantalla_de_carga()
		
func _connect_game_manager_signals() -> void:
	if GameManager:
		if GameManager.has_signal("actividad_superada"):
			GameManager.actividad_superada.connect(Callable(self, "abrir_puerta"))
		else:
			push_error("GameManager no tiene señal 'actividad_superada'")
