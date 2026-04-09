# ====================================================================
# OBJETO INTERACTUABLE: CAJA EMPUJABLE
# ====================================================================
## Representa un objeto físico que reacciona a fuerzas externas y gravedad.
extends CharacterBody2D

# ====================================================================
# PARÁMETROS CONFIGURABLES
# ====================================================================
@export var gravedad: int = 2000
@export var friccion: float = 0.1
@export var masa: float = 50 #Para calcular el empuje
@export var umbral_empuje: float = 50.0 # Fuerza para mover la caja

# ====================================================================
# VARIABLES DE ESTADO
# ====================================================================
var fuerza_externa: Vector2 = Vector2.ZERO
var posicion_inicial: Vector2

# ====================================================================
# INICIALIZACIÓN Y CONFIGURACIÓN
# ====================================================================
func _ready() -> void:
	z_index = ZCapas.CAJAS
	posicion_inicial = global_position

func _physics_process(delta):
	aplicar_gravedad(delta)
	aplicar_friccion()
	manejar_empuje()
	move_and_slide()
	
# ====================================================================
# LÓGICA DE MOVIMIENTO
# ====================================================================
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
	
# ====================================================================
# INTERACCIÓN Y CONTROL
# ====================================================================
## Recibe un vector de fuerza desde el jugador para iniciar el movimiento.
func recibir_empuje(fuerza: Vector2):
	if abs(fuerza.x) > umbral_empuje:
		fuerza_externa = fuerza

## Restablece el objeto a su estado original (útil al reiniciar puzzles).
func retornar_a_posicion_inicial() -> void:
	velocity = Vector2.ZERO
	fuerza_externa = Vector2.ZERO
	global_position = posicion_inicial
