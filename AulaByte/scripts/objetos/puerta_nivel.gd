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
        if Engine.has_singleton("GameManager") or (typeof(GameManager) != TYPE_NIL and GameManager):
            if GameManager.estado_actual == GameManager.EstadoJuego.JUGANDO:
                GameManager.solicitar_minijuego()

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("Jugador"):
        print("Jugador entró en la puerta")
        jugador_en_puerta = true

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("Jugador"):
        jugador_en_puerta = false

func abrir_puerta() -> void:
    animacion_puerta.play("Abriendo")
    # esperar a que termine la animación
    await animacion_puerta.animation_finished

func _connect_game_manager_signals() -> void:
    if GameManager and GameManager.has_signal("actividad_superada"):
        GameManager.connect("actividad_superada", Callable(self, "abrir_puerta"))
    else:
        push_error("GameManager no tiene señal 'actividad_superada'")
