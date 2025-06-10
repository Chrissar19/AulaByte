extends CharacterBody2D

const VEL_HORIZONTAL = 150.0
const VEL_CORRER = 300.0
const FUERZA_SALTO = -400.0
const FUERZA_EMPUJE = 800.0 # Fuerza que aplica a las cajas

@onready var animated_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var soun_jump: AudioStreamPlayer = $SounJump
@onready var empuje_ray: RayCast2D = $EmpujeRay

# Detectar si esta empujando
var esta_empujando: bool = false
var estaba_empujando: bool = false

func _ready():
	# Configurar el raycast inicialmente
	empuje_ray.enabled = true
	empuje_ray.target_position = Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	# guardar estado anterior de empuje
	estaba_empujando = esta_empujando
	
	#Reiniciar estado de empuje
	esta_empujando = false
	
	# Añadir gravedad
	if not is_on_floor(): # Si el player no esta tocando suelo
		velocity += get_gravity() * delta # Se le suma la velocidad a la gravedad

	# Accion de salto
	if Input.is_action_just_pressed("saltar") and is_on_floor(): # Si se presiona la barra espacio y se esta tocando el suelo
		velocity.y = FUERZA_SALTO
		soun_jump.play() # Reproduce el sonido de salto

	var direction := Input.get_axis("izquierda", "derecha") # Recibe el dato entre izq o deer que envia el jugador
	
	# ==============================================================================
	# ACTUALIZACIÓN DE DIRECCIÓN DEL PERSONAJE Y RAYCAST
	# ==============================================================================
	
	# Actualizar dirección del sprite primero
	if direction > 0:
		if direction > 0:
			animated_sprite_player.flip_h = false
	elif direction < 0:
		animated_sprite_player.flip_h = true
		
	# Actualizar direccion del raycast basado en la orientacion del jugador
	if animated_sprite_player.flip_h: # Si esta mirando a la izqueirda
		empuje_ray.target_position = Vector2(-20, 0)
	else: # Si esta mirando hacia la derecha
		empuje_ray.target_position = Vector2(20, 0)
		
	# ==========================================================================
	# DETECCION DE EMPUJE CON RAYCAST
	# ==========================================================================
	
	#Forzar actualizacion de raycast
	empuje_ray.force_raycast_update()
		
	if empuje_ray.is_colliding():
		var collider = empuje_ray.get_collider()
		
		# Verificar si es una caja
		if collider != null and collider.is_in_group("Cajas"):
			# calcula direccion de empuje basada en la orientacion del player
			var push_direction = Vector2.RIGHT if !animated_sprite_player.flip_h else Vector2.LEFT
			
			# Aplicar fuerza solo si el jugador esta empujando
			collider.recibir_empuje(push_direction * FUERZA_EMPUJE)
			
			# Afirma que esta empujando
			esta_empujando = true
	
# ==============================================================================
# SECIÓN DE ANIMACIONES
# ==============================================================================
	if is_on_floor():
		if esta_empujando or (estaba_empujando and direction != 0):# Prioridad a la animacion
			if animated_sprite_player.animation != "jojoaPushNo":
				animated_sprite_player.play("JojoaPushNo")
		elif direction == 0: 
			animated_sprite_player.play("JojoaIdleNo")
		else:
			animated_sprite_player.play("JojoaWalkNo")
	elif velocity.y < 0:
		animated_sprite_player.play("JojoaUpNo")
	else:
		animated_sprite_player.play("JojoaDownNo")
		
# ==================================================================

	# Movimiento Horizontal
	if direction:
		if esta_empujando:
			velocity.x = direction * (VEL_HORIZONTAL * 0.5)
		else:
			velocity.x = direction * (VEL_CORRER if Input.is_action_pressed("Correr") else VEL_HORIZONTAL)
	else:
		velocity.x = move_toward(velocity.x, 0, VEL_HORIZONTAL)

	move_and_slide() #Aplica la velocidad y movimiento
