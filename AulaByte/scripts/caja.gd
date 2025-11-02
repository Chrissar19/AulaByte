extends CharacterBody2D

# Parametros ajustables
@export var gravedad: int = 2000
@export var friccion: float = 0.1
@export var masa: float = 50 #Para calcular el empuje
@export var umbral_empuje: float = 50.0 # Fuerza para mover la caja

var fuerza_externa: Vector2 = Vector2.ZERO
var posicion_inicial: Vector2

func _ready() -> void:
	posicion_inicial = global_position

func _physics_process(delta):
	aplicar_gravedad(delta)
	aplicar_friccion()
	manejar_empuje()
	move_and_slide()
	
func aplicar_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		
func aplicar_friccion():
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, friccion)

func manejar_empuje():
	# Aplica la fuerza del jugador
	velocity += fuerza_externa / masa
	fuerza_externa = Vector2.ZERO
	
# Llamado por el jugador al empujar
func recibir_empuje(fuerza: Vector2):
	if abs(fuerza.x) > umbral_empuje:
		fuerza_externa = fuerza

func retornar_a_posicion_inicial() -> void:
	velocity = Vector2.ZERO
	fuerza_externa = Vector2.ZERO
	global_position = posicion_inicial
