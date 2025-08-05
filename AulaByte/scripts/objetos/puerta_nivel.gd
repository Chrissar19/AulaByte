extends Area2D

@onready var animacion_puerta: AnimatedSprite2D = $AnimacionPuerta

@export var siguiente_escena: String = "res://escenas/Niveles/nivel_2.tscn"

var jugador_en_puerta := false

func _ready() -> void:
	animacion_puerta.frame = 0
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		print("Jugador entró en la puerta")
		jugador_en_puerta = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_puerta = false
		
func _process(delta: float) -> void:
	if jugador_en_puerta and Input.is_action_just_pressed("Accion"):
		print("Presionó E en la puerta")
		siguiente_nivel()
		
func siguiente_nivel():
	animacion_puerta.play("Abriendo") 
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file(siguiente_escena)
