extends Area2D

@onready var animacion_puerta: AnimatedSprite2D = $AnimacionPuerta

var jugador_en_puerta := false
var interactuar := true

func _ready() -> void:
	animacion_puerta.play("Cerrada")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if GameManager:
		GameManager.actividad_superada.connect(abrir_puerta)
	else:
		call_deferred("_conectar_game_manager")
	
func _process(delta: float) -> void:
	if jugador_en_puerta and Input.is_action_just_pressed("Accion") and interactuar:
		print("Presionó E en la puerta")
		if GameManager and GameManager.estado_actual == GameManager.EstadoJuego.JUGANDO:
			GameManager.solicitar_minijuego() #-- Pide el minijuego

func _conectar_game_manager() -> void:
	if GameManager:
		GameManager.actividad_superada.connect(abrir_puerta)
	else:
		push_error("GameManager no encontrado para conectar señales")
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_puerta = true
		

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_puerta = false
		
func abrir_puerta():
	interactuar = false
	animacion_puerta.play("Abriendo") 
	await animacion_puerta.animation_finished
	if GameManager:
		GameManager.siguiente_nivel()
		
func _connect_game_manager_signals() -> void:
	if GameManager:
		if GameManager.has_signal("actividad_superada"):
			GameManager.actividad_superada.connect(Callable(self, "abrir_puerta"))
		else:
			push_error("GameManager no tiene señal 'actividad_superada'")
