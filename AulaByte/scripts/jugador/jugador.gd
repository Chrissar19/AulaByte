extends CharacterBody2D

# ============================================================================
# CONSTANTES
# ============================================================================
const RETROCESO_X := 200.0
const RETROCESO_Y := -200.0
const VEL_HORIZONTAL := 150.0
const FUERZA_SALTO := -420.0
const FUERZA_EMPUJE := 500.0
const TIEMPO_DE_EMPUJE := 0.15
const VIDAS_INICIALES := 3

# ============================================================================
# NODOS HIJO Y VARIABLES
# ============================================================================
@export var nombre: String = ""
@onready var camara: Camera2D = $Camara
@onready var timer_intocable: Timer = $TimerIntocable
@onready var animated_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var empuje_ray: RayCast2D = $EmpujeRay
@onready var sonido_salto: AudioStreamPlayer = $SonidoSalto
@onready var timer_coyote_time: Timer = $TimerCoyoteTime
@onready var area_daño: Area2D = $AreaDaño

var equipo := "No"
var hud: CanvasLayer = null
var vidas := VIDAS_INICIALES
var puntos := 0
var intocable := false
var estado_actual: Estado = Estado.IDLE
var tocando_suelo := false
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

const acciones := ["Idle", "Walk" ,"Up", "Down", "Push"]

# ============================================================================
# ENUMERACIONES
# ============================================================================
enum Estado {
	IDLE, #-- 0
	CAMINANDO, #-- 1
	SALTANDO, #-- 2
	CAYENDO, #-- 3
	EMPUJANDO # -- 4
}

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	add_to_group("Jugador")
	JugadorSeleccionado.reiniciar_vidas()
	asignar_hud()

	empuje_ray.enabled = true
	empuje_ray.target_position = Vector2.ZERO
	empuje_ray.position.y = 15

# ============================================================================
# PHYSICS PROCESS
# ============================================================================
func _physics_process(delta: float) -> void:
	if is_on_floor():
		tocando_suelo = false
		ha_saltado = false
		
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
		
	if not is_on_floor() and not tocando_suelo:
		timer_coyote_time.start()
		tocando_suelo = true
	gravedad(delta)

	if Input.is_action_just_pressed("saltar") and sartar_ahora():
		salto()

	var dir := Input.get_axis("izquierda", "derecha")
	actualizar_direccion(dir)
	detectar_empuje()
	actualizar_estado(dir)
	reproducir_animacion()
	mov_horizontal(dir)

	move_and_slide()

# ============================================================================
# MOVIMIENTO Y SALTO
# ============================================================================
func mov_horizontal(dir: float) -> void:
	var velocidad_base: float = VEL_HORIZONTAL * (0.4 if esta_empujando else 1)
	velocity.x = dir * velocidad_base if dir else move_toward(velocity.x, 0, VEL_HORIZONTAL)

func gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

func salto() -> void:
	velocity.y = FUERZA_SALTO
	sonido_salto.play()
	
func sartar_ahora():
	if is_on_floor():
		if ha_saltado: return false
		ha_saltado = true
		return true
	elif not timer_coyote_time.is_stopped():
		ha_saltado = true
		return true
func _on_timer_coyote_time_timeout() -> void:
	pass

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
func actualizar_estado(dir: float) -> void:
	if not is_on_floor():
		estado_actual = Estado.SALTANDO if velocity.y < 0 else Estado.CAYENDO
	elif esta_empujando:
		estado_actual = Estado.EMPUJANDO
	elif dir != 0:
		estado_actual = Estado.CAMINANDO
	else:
		estado_actual = Estado.IDLE

func reproducir_animacion() -> void:
	var accion: String = acciones[estado_actual]
	if estado_actual != Estado.EMPUJANDO or velocity.x != 0:
		animated_sprite_player.play(nombre_animacion(accion))

func nombre_animacion(accion: String) -> String:
	return nombre + accion + equipo

# ============================================================================
# VIDAS, PUNTOS Y HUD
# ============================================================================
func recibir_dmg(dmg) -> void:
	var dir: float = 0.0
	if intocable:
		return

	if not hud:
		asignar_hud()
	JugadorSeleccionado.perder_vida()
	if hud:
		hud.actualizar_vidas()

	iniciar_retroceso(dir)
	intocable = true
	modulate.a = 0.5
	timer_intocable.start()
	
func _on_area_daño_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("DMG") and not intocable:
		recibir_dmg(1)

func _on_timer_intocable_timeout() -> void:
	intocable = false
	modulate = Color(1, 1, 1)

func ganar_puntos(cantidad: int) -> void:
	JugadorSeleccionado.agregar_puntos(cantidad)
	if hud:
		hud.actualizar_puntos(JugadorSeleccionado.get_puntos())

func ganar_vidas() -> void:
	JugadorSeleccionado.ganar_vida()
	hud.actualizar_vidas()

func _cuando_se_acabe_tiempo() -> void:
	JugadorSeleccionado.morir()

func set_hud(h: Node) -> void:
	hud = h
	hud.connect("tiempo_terminado", Callable(self, "_cuando_se_acabe_tiempo"))
	hud.actualizar_vidas()
	hud.actualizar_puntos(puntos)
	
func asignar_hud():
	#-- Busca automaticamente el nodo HUD desde la escena actual
	if not hud == null:
		var actualizar_hud = get_tree().get_current_scene().get_node_or_null("HUD")
		if actualizar_hud:
			hud = actualizar_hud
			hud.connect("tiempo_terminado", Callable(self, "_cuando_se_acabe_tiempo"))
			hud.actualizar_vidas()
			hud.actualizar_puntos(puntos)

# ============================================================================
# CÁMARA Y RETROCESO
# ============================================================================
func establecer_limites_camara(arr: int, izq: int, der: int, aba: int) -> void:
	if camara:
		camara.limit_top = arr
		camara.limit_left = izq
		camara.limit_right = der
		camara.limit_bottom = aba

func iniciar_retroceso(direccion: float) -> void:
	esta_en_retroceso = true
	contador_retroceso = tiempo_retroceso
	dir_retroceso = - ultima_dir
	velocity = Vector2(dir_retroceso * RETROCESO_X, RETROCESO_Y)
	estaba_empujando = false
	modulate = Color(1, 0.5, 0.5)
