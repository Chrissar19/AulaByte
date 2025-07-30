extends CharacterBody2D

const RETROCESO_X := 300.0
const RRETROCESO_Y := -200.0
const VEL_HORIZONTAL := 150.0
const FUERZA_SALTO := -420.0
const FUERZA_EMPUJE := 500.0 # Fuerza que aplica a las cajas
const TIEMPO_DE_EMPUJE := 0.15 #-- Tiempo que se mantiene en el estado de empujar
var tiempo_empujando := 0.0 
var hud: CanvasLayer = null
var vidas: int = 3
var puntos: int = 0
var intocable: bool = false
var esta_en_retroceso := false
var tiempo_retroceso := 0.2
var contador_retroceso := 0.0
var dir_retroceso := 0.0

@onready var camara: Camera2D = $Camara

@export var nombre = ""
const acciones: Array[String] = [
	"Idle", #[0]
	"Walk", #[1]
	"Push", #[2]
	"Up", #[3]
	"Down" #[4]
	]
var equipo = "No"
@onready var timer_intocable: Timer = $TimerIntocable
@onready var animated_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var empuje_ray: RayCast2D = $EmpujeRay
@onready var sonido_salto: AudioStreamPlayer = $SonidoSalto

# Detectar si esta empujando
var esta_empujando: bool = false
var estaba_empujando: bool = false

#--Define los estados posibles
enum Estado {
	IDLE,
	CAMINANDO,
	SALTANDO,
	CAYENDO,
	EMPUJANDO
	}
var estado_actual: Estado = Estado.IDLE

func _ready():
	add_to_group("Jugador")
	# Configurar el raycast inicialmente
	empuje_ray.enabled = true
	empuje_ray.target_position = Vector2.ZERO
	empuje_ray.position.y = 15
	#--Asegurar que las vidas inicien correctamente
	JugadorSeleccionado.reiniciar_vidas()
	
	#-- Busca el HUD en la escena
	if hud == null:
		hud = get_tree().get_root().get_node("NivelTuto/HUD")
		if hud:
			hud.connect("tiempo_terminado", Callable(self, "_cuando_se_acabe_tiempo"))
			hud.actualizar_vidas()
			hud.actualizar_puntos(puntos)
	
func _physics_process(delta: float) -> void:
	#-- Manejo del retroceso
	if esta_en_retroceso:
		contador_retroceso -= delta
		if contador_retroceso <= 0:
			esta_en_retroceso = false
			modulate.a = 0.5 #-- Transparencia
		
		#-- Aplicar retroceso
		velocity.x = dir_retroceso * RETROCESO_X
		velocity.y = RRETROCESO_Y
	else:
	
		# guardar estado anterior de empuje
		estaba_empujando = esta_empujando
		#--Disminuir el tiempo
		tiempo_empujando = max(0, tiempo_empujando - delta)
		#Reiniciar estado de empuje
		esta_empujando = tiempo_empujando > 0
	
		# Añadir gravedad
		gravedad(delta)
		# Accion de salto
		if Input.is_action_just_pressed("saltar") and is_on_floor(): # Si se presiona la barra espacio y se esta tocando el suelo
			salto()
		var dir := Input.get_axis("izquierda", "derecha") # Recibe el dato entre izq o deer que envia el jugador
	
		#--Direccion del sprite y RayCast
		actualizar_direccion(dir)
		#--detectar caja
		detectar_empuje(delta)
		#--Actualizar estado 
		actualizar_estado(dir)
		#--Actualizar animacion
		reproducir_animacion()
		# Movimiento Horizontal
		mov_horizontal(dir)

	move_and_slide() #Aplica la velocidad y movimiento
	
func actualizar_estado(dir: float) -> void:
	if not is_on_floor():
		estado_actual = Estado.SALTANDO if velocity.y < 0 else  Estado.CAYENDO
	elif esta_empujando:
		estado_actual = Estado.EMPUJANDO
	elif dir != 0:
		estado_actual = Estado.CAMINANDO
	else:
		estado_actual = Estado.IDLE

# ==============================================================================
# SECIÓN DE ANIMACIONES
# ==============================================================================
func reproducir_animacion() -> void:
	match estado_actual:
		Estado.IDLE:
			animated_sprite_player.play(nombre_animacion(acciones[0]))
		Estado.CAMINANDO:
			animated_sprite_player.play(nombre_animacion(acciones[1]))
		Estado.SALTANDO:
			animated_sprite_player.play(nombre_animacion(acciones[3]))
		Estado.CAYENDO:
			animated_sprite_player.play(nombre_animacion(acciones[4]))
		Estado.EMPUJANDO:
			if animated_sprite_player.animation != nombre_animacion(acciones[2]) and velocity.x != 0:
				animated_sprite_player.play(nombre_animacion(acciones[2]))
				
func actualizar_direccion(dir: float) -> void:
	if dir > 0:
		animated_sprite_player.flip_h = false
	elif dir < 0:
		animated_sprite_player.flip_h = true
	empuje_ray.target_position = Vector2(-20, 0) if animated_sprite_player.flip_h else Vector2(20, 0)
		
func detectar_empuje(_delta: float) -> void:
	#Forzar actualizacion de raycast
	empuje_ray.force_raycast_update()
		
	if empuje_ray.is_colliding():
		var c = empuje_ray.get_collider()
		
		# Verificar que el collider no sea null,
		if c != null and c.is_in_group("Cajas") and c.has_method("recibir_empuje"):
			# calcula direccion de empuje basada en la orientacion del player
			var dir_empuje = Vector2.RIGHT if !animated_sprite_player.flip_h else Vector2.LEFT
			# Aplicar fuerza solo si el jugador esta empujando
			c.recibir_empuje(dir_empuje * FUERZA_EMPUJE)
			#--Activa el latch (atar)
			tiempo_empujando = TIEMPO_DE_EMPUJE
			# Afirma que esta empujando
			esta_empujando = true
			
func mov_horizontal(dir: float) -> void:
	if dir:
		if esta_empujando:
			velocity.x = dir * (VEL_HORIZONTAL * 0.4)
		else:
			velocity.x = dir *  VEL_HORIZONTAL
	else:
		velocity.x = move_toward(velocity.x, 0, VEL_HORIZONTAL)

func gravedad(delta: float) -> void:
	if not is_on_floor(): # Si el player no esta tocando suelo
		velocity.y += get_gravity().y * delta  # Se le suma la velocidad a la gravedad
		
func salto():
	velocity.y = FUERZA_SALTO
	sonido_salto.play() # Reproduce el sonido de salto

#--Helper para generar nombres para la animacion
func nombre_animacion(accion: String) -> String:
	#--nombre es el prefijo del personaje
	return nombre + accion + equipo
	
#---------------------------------------------------------------------------------------------------
#-- CONEXION ON EL HUD Y LAS VIDAS
#---------------------------------------------------------------------------------------------------
func set_hud(h: Node) -> void:
	hud = h
	hud.connect("tiempo_terminado", Callable(self, "_cuando_se_acabe_tiempo"))
	hud.actualizar_vidas()
	hud.actualizar_puntos(puntos)
		
#-- ganar puntos
func ganar_puntos(cantidad: int) -> void:
	JugadorSeleccionado.agregar_puntos(cantidad)
	if hud:
		hud.actualizar_puntos(JugadorSeleccionado.get_puntos())
		
func _cuando_se_acabe_tiempo() -> void:
	JugadorSeleccionado.morir()
	
func recibir_dmg(dir: float = 0.0) -> void:
	if intocable:
		return
	JugadorSeleccionado.perder_vida()
	hud.actualizar_vidas() #-- referencia a HUD
	
	iniciar_retroceso(dir)
	intocable = true
	modulate.a = 0.5
	timer_intocable.start()
		
func ganar_vidas() -> void:
	JugadorSeleccionado.ganar_vida()
	hud.actualizar_vidas()
	
func _on_timer_intocable_timeout() -> void:
	intocable = false
	modulate.a = 1.0
	modulate = Color(1, 1, 1)
#---------------------------------------------------------------------------------------------------
#-- CONFIGURACION DE CAMARA
#---------------------------------------------------------------------------------------------------
func establecer_limites_camara(arr: int, izq: int, der: int, aba: int) -> void:
	if camara:
		camara.limit_top = arr
		camara.limit_left = izq
		camara.limit_right = der
		camara.limit_bottom = aba
		
#----------------------------------------------------------------------------------------------------
#-- RETROCESO AL RECIBIR DAÑO
#--------------------------------------------------------------------------------------------------
func iniciar_retroceso(direccion: float) -> void:
	esta_en_retroceso = true
	contador_retroceso = tiempo_retroceso
	dir_retroceso = direccion
	estaba_empujando = false
	
	#-- Efectos visuales
	modulate = Color(1, 0.5, 0.5)
