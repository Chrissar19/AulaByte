extends Node2D

# =============================================================================
# BOLA COLGANTE - Cae hasta detectar suelo y crea cadenas entre el punto inicial y el suelo
# =============================================================================

# ============================================================================
# PARÁMETROS EXPORTADOS
# ============================================================================
@export var distancia_cadena := 0         # Longitud fija (opcional)
@export var tamano_bola := 1.0  # Escala del sprite
@export var dmg: int = 2        

# ============================================================================
# VARIABLES INTERNAS
# ============================================================================
var suelo_detectado := false
var tiempo_espera := false
const TAM_GANCHO := 13
const VALOR_INICIAL_RAYCAST := 56

# ============================================================================
# NODOS HIJO
# ============================================================================
@onready var ray_cast_suelo: RayCast2D = $RayCastDeteccionSuelo
@onready var bola: Sprite2D = $Bola
@onready var timer_espera: Timer = $TimerTilePintado
@onready var anim_bola: AnimationPlayer = $RotacionBola

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	add_to_group("DMG")
	add_to_group("Enemigos")
	ray_cast_suelo.target_position.y = VALOR_INICIAL_RAYCAST * tamano_bola
	bola.scale *= tamano_bola

# ============================================================================
# PROCESS - Verifica caída hasta suelo
# ============================================================================
func _process(delta: float) -> void:
	if not suelo_detectado || tiempo_espera:
		ray_cast_suelo.target_position.y += 6
		if ray_cast_suelo.is_colliding():
			suelo_detectado = true
			ray_cast_suelo.target_position.y -= 6
			longitud_cadena()
			

# ============================================================================
# CREACIÓN DE CADENAS
# ============================================================================
func longitud_cadena():
	var cantidad_cadena = int(ray_cast_suelo.target_position.y - VALOR_INICIAL_RAYCAST) / int(6 * tamano_bola)
	if distancia_cadena != 0:
		cantidad_cadena = int(distancia_cadena / 6)
	bola.position.y += (cantidad_cadena * 6) - TAM_GANCHO
	for i in range(cantidad_cadena):
		var cadenas = preload("res://escenas/personajes/enemigos/cadena.tscn").instantiate()
		if i == 0:
			cadenas.position = Vector2(0, TAM_GANCHO)
		cadenas.position += Vector2(0, (6*(i+1)))
		self.add_child(cadenas)
	anim_bola.play("movimiento_bola")

# ============================================================================
# TIMER - Activa tiempo de espera
# ============================================================================
func _on_timer_tile_pintado_timeout() -> void:
	tiempo_espera = true

# ============================================================================
# COLISIÓN - Invierte rotación
# ============================================================================
func _on_area_colision_body_entered(body: Node2D) -> void:
	anim_bola.speed_scale *= -1
	
# ============================================================================
# DETECTOR DE COLISIÓN (DAÑO AL JUGADOR)
# ============================================================================
func _on_detector_jugador_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		body.recibir_dmg(dmg)
		
