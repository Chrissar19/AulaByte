#-- Jugador
extends CharacterBody2D

#-------------------------------------------------------------------------------------
#-- SEÑALES
#---------------------------------------------------------------------------------------
signal jugador_pierde_vida(dmg: int)
signal jugador_gana_vida(vidas: int)
signal jugador_gana_puntos(puntos: int)

# ============================================================================
# CONSTANTES Y VARIABLES
# ============================================================================
const RETROCESO_X := 200.0
const RETROCESO_Y := -350.0
const VEL_HORIZONTAL := 150.0
const FUERZA_SALTO := -420.0
const FUERZA_EMPUJE := 500.0
const TIEMPO_DE_EMPUJE := 0.15
const COYOTE_TIME := 0.15

@export var nombre: String = ""
@export var punto_reaparicion: Vector2

var equipo := "No"
var intocable := false
var ha_saltado := false

# Retroceso (daño)
var esta_en_retroceso := false
var contador_retroceso := 0.0
var tiempo_retroceso := 0.2
var dir_retroceso := 0.0
var ultima_dir := 1.0

# Empuje
var esta_empujando := false
var estaba_empujando := false
var tiempo_empujando := 0.0

#-- Habilidades
var boost_activo: bool = false
var tiempo_boost_restante: float = 0.0
var multiplicador_velocidad: float = 1.0

var boost_salto_activo: bool = false
var tiempo_boost_salto: float = 0.0
var multiplicador_salto: float = 1.0
var tiempo_coyote: float = 0.0

# ============================================================================
# NODOS HIJO
# ============================================================================
@onready var camara: Camera2D = $Camara
@onready var timer_intocable: Timer = $TimerIntocable
@onready var animated_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var empuje_ray: RayCast2D = $EmpujeRay
@onready var sonido_salto: AudioStreamPlayer = $SonidoSalto
@onready var area_daño: Area2D = $AreaDaño

const StateClasses := {
	"idle": preload("res://scripts/jugador/estados/idle.gd"),
	"caminar": preload("res://scripts/jugador/estados/caminar.gd"),
	"saltar": preload("res://scripts/jugador/estados/saltar.gd"),
	"caer": preload("res://scripts/jugador/estados/caer.gd"),
	"empujar": preload("res://scripts/jugador/estados/empujar.gd"),
}

var states := {}
var current_state = null
var input_dir: float = 0.0

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	add_to_group("Jugador")
	z_index = ZCapas.JUGADOR
	punto_reaparicion = global_position
	GameManager.set_jugador(self)
	
	if camara:
		camara.position = Vector2.ZERO
		camara.offset = Vector2.ZERO
		camara.make_current()
	
	# Configurar raycast de empuje
	empuje_ray.enabled = true
	empuje_ray.target_position = Vector2.ZERO
	empuje_ray.position.y = 15
	
	# Instanciar clases de estado
	for name in StateClasses.keys():
		var s = StateClasses[name].new()
		add_child(s)
		s.name = name
		states[name] = s
		
	cambiar_estado("idle")

# ============================================================================
# PHYSICS PROCESS
# ============================================================================
func _physics_process(delta: float) -> void:
	# --- COYOTE TIME: gestionar ventana después de salir del suelo ---
	if is_on_floor():
		# Siempre que toca suelo, reseteamos ventana de coyote
		tiempo_coyote = COYOTE_TIME
		ha_saltado = false
	else:
		# Si está en el aire, el tiempo de coyote se va agotando
		tiempo_coyote = max(tiempo_coyote - delta, 0.0)
	
	# -- HABILIDADES
	if boost_activo:
		tiempo_boost_restante -= delta
		if tiempo_boost_restante <= 0.0:
			boost_activo = false
			tiempo_boost_restante = 0.0
			multiplicador_velocidad = 1.0
			animated_sprite_player.modulate = Color(1, 1, 1)
	
	if boost_salto_activo:
		tiempo_boost_salto -= delta
		if tiempo_boost_salto <= 0.0:
			boost_salto_activo = false
			tiempo_boost_salto = 0.0
			multiplicador_salto = 1.0

	# --- Retroceso (cuando recibe daño) ---
	if esta_en_retroceso:
		contador_retroceso -= delta
		if contador_retroceso <= 0:
			esta_en_retroceso = false
			modulate.a = 0.5
		move_and_slide()
		return

	# Movimiento normal
	estaba_empujando = esta_empujando
	tiempo_empujando = max(0, tiempo_empujando - delta)
	esta_empujando = tiempo_empujando > 0

	gravedad(delta)

	if Input.is_action_just_pressed("saltar") and saltar_ahora():
		cambiar_estado("saltar")

	input_dir = Input.get_axis("izquierda", "derecha")
	actualizar_direccion(input_dir)
	detectar_empuje()

	if current_state:
		current_state.actualizar_fisicas(delta)
	
	if not is_on_floor():
		if velocity.y < 0 and current_state.name == "caer":
			cambiar_estado("saltar")
		elif velocity.y > 0 and current_state.name == "saltar":
			cambiar_estado("caer")

	reproducir_animacion()
	move_and_slide()

	# Detectar transición de salto a idle/caminar
	if is_on_floor() and current_state and current_state.name == "saltar":
		if abs(velocity.x) > 0.1:
			cambiar_estado("caminar")
		else:
			cambiar_estado("idle")


# ============================================================================
# MOVIMIENTO Y SALTO
# ============================================================================
func mov_horizontal(dir: float) -> void:
	# --- HABILIDAD VELOCIDAD: calcular velocidad base con boost ---
	var velocidad_base: float = VEL_HORIZONTAL
	velocidad_base *= multiplicador_velocidad
	if esta_empujando:
		velocidad_base *= 0.4
	# --------------------------------------------------------------
	
	if dir != 0.0:
		velocity.x = dir * velocidad_base
	else:
		# Suavizar hasta detener usando la misma escala
		velocity.x = move_toward(velocity.x, 0, velocidad_base)

func gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

func salto() -> void:
	var fuerza_salto := FUERZA_SALTO * multiplicador_salto
	velocity.y = fuerza_salto
	sonido_salto.play()

func saltar_ahora() -> bool:
	# Evitar saltos dobles mientras dure el mismo salto
	if ha_saltado:
		return false

	if is_on_floor():
		ha_saltado = true
		return true

	if tiempo_coyote > 0.0:
		ha_saltado = true
		tiempo_coyote = 0.0
		return true

	return false

# ============================================================================
# DIRECCIÓN Y EMPUJE
# ============================================================================
func actualizar_direccion(dir: float) -> void:
	if dir != 0:
		animated_sprite_player.flip_h = dir < 0
		ultima_dir = dir #-- Guardamos la dirección
	empuje_ray.target_position = Vector2(-20, 0) if animated_sprite_player.flip_h else Vector2(20, 0)

func detectar_empuje() -> void:
	empuje_ray.force_raycast_update()
	if empuje_ray.is_colliding():
		var obj = empuje_ray.get_collider()
		if obj and obj.is_in_group("Cajas") and obj.has_method("recibir_empuje"):
			var dir_empuje := Vector2.RIGHT if not animated_sprite_player.flip_h else Vector2.LEFT
			obj.recibir_empuje(dir_empuje * FUERZA_EMPUJE)
			tiempo_empujando = TIEMPO_DE_EMPUJE
			esta_empujando = true

# ============================================================================
# ESTADOS Y ANIMACIÓN
# ============================================================================
func cambiar_estado(nom_estado: String) -> void:
	if current_state and current_state.name == nom_estado:
		return
	if current_state:
		current_state.exit()
	current_state = states.get(nom_estado, null)
	if current_state:
		current_state.enter(self)

func reproducir_animacion() -> void:
	if not current_state:
		return
		
	#--Nombre del estado actual
	var estado = current_state.name
	
	#-- Mapeo de animacion
	match estado:
		"idle":
			animated_sprite_player.play(nombre_animacion("Idle"))
		"caminar":
			animated_sprite_player.play(nombre_animacion("Walk"))
		"saltar":
			animated_sprite_player.play(nombre_animacion("Up"))
		"caer":
			animated_sprite_player.play(nombre_animacion("Down"))
		"empujar":
			if velocity.x != 0:
				animated_sprite_player.play(nombre_animacion("Push"))

func nombre_animacion(accion: String) -> String:
	return nombre + accion + equipo

# ============================================================================
# DAÑO
# ============================================================================
func recibir_golpe_desde(origen: Vector2, dmg: int = 1) -> void:
	if intocable:
		return

	#-- vida
	emit_signal("jugador_pierde_vida", dmg)

	#-- dirección del empuje (hacia atrás y un poco hacia arriba)
	var dx := global_position.x - origen.x
	var dirx := float(sign(dx))
	if dirx == 0.0:
		dirx = 1.0 if ultima_dir >= 0.0 else -1.0

	#-- retroceso (≈45°): usa tus mismas constantes
	esta_en_retroceso = true
	contador_retroceso = tiempo_retroceso
	velocity = Vector2(dirx * RETROCESO_X, RETROCESO_Y)

	#-- invulnerable + feedback visual
	intocable = true
	modulate = Color(1, 1, 1, 0.5)
	timer_intocable.start()

func recibir_dmg(dmg: int) -> void:
	if intocable:
		return
	var origen := global_position - Vector2(ultima_dir * 8.0, 0.0)
	recibir_golpe_desde(origen, dmg)
	
func caer_al_vacio() -> void:
	if intocable:
		return
	recibir_dmg(1)
	reaparecer()
	
func _on_area_daño_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if intocable:
		return
	if area.is_in_group("DMG"):
		recibir_golpe_desde(area.global_position, 1)

func _on_timer_intocable_timeout() -> void:
	intocable = false
	modulate = Color(1, 1, 1)
	
# ============================================================================
# VIDAS Y PUNTOS
# ============================================================================

func ganar_puntos(cantidad: int) -> void:
	emit_signal("jugador_gana_puntos", cantidad)

func ganar_vidas(cantidad: int) -> void:
	emit_signal("jugador_gana_vida", cantidad)
	
	
# ============================================================================
# HABILIDADES / POWER-UPS
# ============================================================================
func activar_habilidad_velocidad(duracion: float, factor: float) -> void:
	if duracion <= 0.0:
		return
	
	boost_activo = true
	tiempo_boost_restante = duracion
	multiplicador_velocidad = factor
	animated_sprite_player.modulate = Color(1.2, 1.2, 1.2)
	
	print("Habilidad de velocidad activada: duracion =", duracion, " factor =", factor)

func activar_habilidad_salto(duracion: float, factor: float) -> void:
	if duracion <= 0.0:
		return

	boost_salto_activo = true
	tiempo_boost_salto = duracion
	multiplicador_salto = factor
	
	print("Habilidad de SALTO activada: duracion =", duracion, " factor =", factor)


# ============================================================================
# REAPARICION
# ============================================================================
func reaparecer() -> void:
	global_position = punto_reaparicion
	velocity = Vector2.ZERO
	modulate = Color(1, 1, 1)
	intocable = true
	timer_intocable.start()
	
	var colision = get_node_or_null("CollisionShape2D")
	if colision:
		colision.disabled = false
	
	_resetear_camara()
	
# ============================================================================
# CÁMARA Y RETROCESO
# ============================================================================
func establecer_limites_camara(arr: int, izq: int, der: int, aba: int) -> void:
	if camara:
		camara.limit_top = arr
		camara.limit_left = izq
		camara.limit_right = der
		camara.limit_bottom = aba
		
func _resetear_camara() -> void:
	if camara:
		camara.position = Vector2.ZERO
		camara.offset = Vector2.ZERO
		camara.make_current()


func iniciar_retroceso(direccion: float) -> void:
	esta_en_retroceso = true
	contador_retroceso = tiempo_retroceso
	dir_retroceso = - ultima_dir
	velocity = Vector2(dir_retroceso * RETROCESO_X, RETROCESO_Y)
	estaba_empujando = false
