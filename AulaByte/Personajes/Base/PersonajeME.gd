extends CharacterBody2D
class_name PersonajeME

#-- Constantes de movimiento ---
const VEL_HORIZONTAL = 150.0
const FUERZA_SALTO = -400.0
const FUERZA_EMPUJE = 500.0 # Fuerza que aplica a las cajas
const TIEMPO_DE_EMPUJE := 0.15 #-- Tiempo que se mantiene en el estado de empujar

#--Define los estados posibles
enum Estado {
	IDLE,
	CAMINANDO,
	SALTANDO,
	CAYENDO,
	EMPUJANDO
	}
var estado_actual: Estado = Estado.IDLE

#-- VARIABLES DE INSTANCIA DEL PERSONAJE --
var nombre = "Base"
#-- ACCIONES --
const acciones: Array[String] = [
	"Idle", #[0]
	"Walk", #[1]
	"Push", #[2]
	"Up", #[3]
	"Down" #[4]
	]
var equipo = "No"

@onready var animated_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var empuje_ray: RayCast2D = $EmpujeRay
@onready var sonido_salto: AudioStreamPlayer = $SonidoSalto


# Detectar si esta empujando
var esta_empujando: bool = false
var estaba_empujando: bool = false
var tiempo_empujando := 0.0 

#--Contador coyote-time --
var tiempo_coyote := 0.15
var contador_coyote := 0.0

func _ready():
	# Configurar el raycast inicialmente
	empuje_ray.enabled = true
	empuje_ray.target_position = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	# guardar estado anterior de empuje
	estaba_empujando = esta_empujando
	#--Disminuir el tiempo
	tiempo_empujando = max(0, tiempo_empujando - delta)
	#Reiniciar estado de empuje
	esta_empujando = tiempo_empujando > 0
	var dir := Input.get_axis("izquierda", "derecha") # Recibe el dato entre izq o deer que envia el jugador
	#-- Coyote-time--
	coyote_time(delta)
	# Añadir gravedad
	gravedad(delta)
	# Accion de salto
	if Input.is_action_just_pressed("saltar") and contador_coyote > 0: # Si se presiona la barra espacio y se esta tocando el suelo
		salto()
	
	#--Direccion del sprite y RayCast
	actualizar_direccion(dir)
	#--detectar caja
	detectar_empuje(delta)
	#--Actualizar estado 
	actualizar_estado(dir)
	#--Actualizar animacion
	reproducir_animacion()
	# Movimiento Horizontal
	mover_horizontal(dir)

	move_and_slide() #Aplica la velocidad y movimiento
#---------------------------------------------------------------------------------------------------
#-- MODULARIZACION --
#---------------------------------------------------------------------------------------------------
	
func actualizar_estado(dir: float) -> void:
	if not is_on_floor():
		estado_actual = Estado.SALTANDO if velocity.y < 0 else  Estado.CAYENDO
	elif esta_empujando:
		estado_actual = Estado.EMPUJANDO
	elif dir != 0:
		estado_actual = Estado.CAMINANDO
	else:
		estado_actual = Estado.IDLE

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
			if animated_sprite_player.animation != nombre_animacion(acciones[2]):
				animated_sprite_player.play(nombre_animacion(acciones[2]))
				
func actualizar_direccion(dir: float) -> void:
	if dir > 0:
		animated_sprite_player.flip_h = false
	elif dir < 0:
		animated_sprite_player.flip_h = true
	empuje_ray.target_position = Vector2(-20, 0) if animated_sprite_player.flip_h else Vector2(20, 0)
		
func detectar_empuje(delta: float) -> void:
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
			
func mover_horizontal(dir: float) -> void:
	if dir:
		if esta_empujando:
			velocity.x = dir * (VEL_HORIZONTAL * 0.4)
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
	
func coyote_time(delta):
	if is_on_floor():
		contador_coyote = tiempo_coyote
	else:
		contador_coyote -= delta
