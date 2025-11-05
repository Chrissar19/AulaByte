extends Area2D

signal on_cuy_liberado

@onready var timer_cuy_liberado: Timer = $TimerCuyLiberado
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D/AnimatedSprite2D
@onready var animated_sprite_2d_cuy: AnimatedSprite2D = $AnimatedSprite2D/AnimatedSprite2DCuy

var jugador_en_jaula := false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	call_deferred("_connect_game_manager_signals")

	if animated_sprite_2d_cuy:
		animated_sprite_2d_cuy.play("0")

	if timer_cuy_liberado:
		timer_cuy_liberado.connect("timeout", Callable(self, "_on_timer_cuy_liberado_timeout"))
		
func _process(delta: float) -> void:
	if jugador_en_jaula and Input.is_action_just_pressed("Accion"):
		print("Presionó E en la jaula")
		if Engine.has_singleton("GameManager") or (typeof(GameManager) != TYPE_NIL and GameManager):
			if GameManager.estado_actual == GameManager.EstadoJuego.JUGANDO:
				if animated_sprite_2d:
					animated_sprite_2d.visible = false
					
					if animated_sprite_2d_cuy:
						animated_sprite_2d_cuy.play("1")
			
				timer_cuy_liberado.start(1)
				
func _on_timer_cuy_liberado_timeout() -> void:
	emit_signal("on_cuy_liberado")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_jaula = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_jaula = false
