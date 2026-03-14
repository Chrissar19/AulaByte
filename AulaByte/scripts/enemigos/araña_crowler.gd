extends EnemigoBase
class_name ArañaCrowler

# ============================================================================
# ESTADOS DE IA
# ============================================================================
enum Estado { TECHO, CAER, SUELO, PERSEGUIR, CARGAR, ATACAR, REPOSO, SUBIR, IDLE }
var estado_actual = Estado.TECHO
var mascara_original: int = 1 # Para guardar la máscara física de mundo
var capa_original: int = 1 # Para guardar la posición en las capas de físicas

# ============================================================================
# NODOS ESPECÍFICOS DE LA ARAÑA
# ============================================================================
@onready var ray_techo: RayCast2D = $RayTecho if has_node("RayTecho") else null
@onready var ray_deteccion_jugador: RayCast2D = $RayDeteccionJugador if has_node("RayDeteccionJugador") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

# Timers de IA
@onready var timer_suelo: Timer = $TimerSuelo if has_node("TimerSuelo") else null
@onready var timer_carga: Timer = $TimerCarga if has_node("TimerCarga") else null
@onready var timer_reposo: Timer = $TimerReposo if has_node("TimerReposo") else null
@onready var area_vision: Area2D = $AreaVision if has_node("AreaVision") else null
@onready var marker_disparo: Marker2D = $PuntoDisparo if has_node("PuntoDisparo") else null

# Efectos Visuales Especiales y Armas
var linea_neon: Line2D = null
var punto_anclaje_techo: Vector2 = Vector2.ZERO
@export var proyectil_laser: PackedScene

# ============================================================================
# INICIALIZACIÓN
# ============================================================================
func _inicializar_enemigo() -> void:
	# Como empieza en el techo, su sprite debe estar boca abajo (invertido verticalmente)
	if sprite:
		sprite.flip_v = true
		# Forzamos que la animación de descarga no sea un loop para que se quede estática al acabar
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("araña_descarga"):
			sprite.sprite_frames.set_animation_loop("araña_descarga", false)
	
	# Aseguramos que el RaySuelo que usamos en EnemigoBase apunte HACA ARRIBA para detectar "techo"
	# Lo estiramos a 50.0 para que no falle flotaciones e irrites
	if ray_suelo:
		ray_suelo.target_position = Vector2(distancia_deteccion_borde * direccion, -50.0)
		
	# Y el RayPared apunte normalmente hacia el frente, un poco más lejos
	if ray_pared:
		ray_pared.target_position = Vector2(30 * direccion, 0.0)
		
	# Configuramos un RayCast largo hacia arriba para buscar escapes al techo (Fase 4)
	if ray_techo:
		ray_techo.target_position = Vector2(0, -350.0)

# ============================================================================
# MODIFICANDO PATRONES DE ENEMIGO BASE
# ============================================================================

func _aplicar_gravedad(delta: float) -> void:
	if estado_actual == Estado.TECHO:
		# GRAVEDAD INVERTIDA: Atraído hacia arriba (techo)
		if not is_on_ceiling():
			velocity.y -= gravedad * delta
		else:
			velocity.y = 0
	else:
		# Gravedad Normal
		super._aplicar_gravedad(delta)

func _verificar_colisiones() -> void:
	if not puede_girar: return
	
	if estado_actual == Estado.TECHO:
		var cambio_direccion = false
		
		# Detectar obstáculos delante
		if ray_pared:
			ray_pared.force_raycast_update()
			if ray_pared.is_colliding():
				cambio_direccion = true
		
		if is_on_wall():
			cambio_direccion = true
		
		# Detectar "precipicios invertidos" (techo que se acaba)
		if ray_suelo:
			ray_suelo.force_raycast_update()
			if is_on_ceiling() and not cambio_direccion and not ray_suelo.is_colliding():
				cambio_direccion = true

		if cambio_direccion:
			_girar()
	elif estado_actual in [Estado.SUELO, Estado.PERSEGUIR]:
		var cambio_direccion = false
		
		if ray_pared:
			ray_pared.force_raycast_update()
			if ray_pared.is_colliding():
				cambio_direccion = true
		
		if is_on_wall():
			cambio_direccion = true
		
		if ray_suelo:
			ray_suelo.force_raycast_update()
			if is_on_floor() and not cambio_direccion and not ray_suelo.is_colliding():
				cambio_direccion = true

		if cambio_direccion:
			if estado_actual == Estado.PERSEGUIR:
				estado_actual = Estado.IDLE
				_girar()
				await get_tree().create_timer(2.0).timeout
				if not esta_muerto and estado_actual == Estado.IDLE:
					estado_actual = Estado.SUELO # Volvemos a patrullar
			else:
				_girar()
	else:
		# Comportamiento normal en el suelo
		super._verificar_colisiones()

func _actualizar_raycast() -> void:
	super._actualizar_raycast()
	if ray_suelo:
		if estado_actual == Estado.TECHO:
			# Sobreescribimos la dirección vertical que la clase Base forzó a positiva
			ray_suelo.target_position = Vector2(distancia_deteccion_borde * direccion, -50.0)
		else:
			ray_suelo.target_position = Vector2(distancia_deteccion_borde * direccion, 50.0)
			
	# Girar visión y punto de disparo con la araña
	if area_vision:
		area_vision.scale.x = direccion
	if marker_disparo:
		marker_disparo.position.x = abs(marker_disparo.position.x) * direccion

var jugador_objetivo: Node2D = null

# ============================================================================
# LECTURA DE JUGADOR (PRÓXIMA FASE)
# ============================================================================
func _iniciar_caida(objetivo: Node2D) -> void:
	estado_actual = Estado.CAER
	if objetivo:
		jugador_objetivo = objetivo
	# Girar sprite a posición normal
	if sprite:
		sprite.flip_v = false
	
	# Guardar colisiones actuales del cuerpo rígido para ser "intangibles" físicamente
	# y no empujar al jugador a través del suelo al caerle velozmente encima.
	mascara_original = collision_mask
	capa_original = collision_layer
	
	collision_mask = 1 # Que ella solo choque con la capa 1 (Mundo/Suelo)
	collision_layer = 0 # Que absolutamente nadie choque con ella como pared
	
	_iniciar_telarana()
		
	# === LÓGICA DE DETECCIÓN ===
	if estado_actual == Estado.TECHO and ray_deteccion_jugador:
		ray_deteccion_jugador.force_raycast_update()
		if ray_deteccion_jugador.is_colliding():
			var obj = ray_deteccion_jugador.get_collider()
			if obj and obj.is_in_group("Jugador"):
				_iniciar_caida(obj)
				
	# === LÓGICA DE ATERRIZAJE ===
	elif estado_actual == Estado.CAER:
		# Bloqueo horizontal al caer
		velocity.x = 0
		if is_on_floor():
			# Aterrizamos.
			_borrar_telarana()
			collision_mask = mascara_original
			collision_layer = capa_original
			estado_actual = Estado.PERSEGUIR
			
			# Orientar inmediatamente la araña hacia donde está el jugador registrado
			if jugador_objetivo:
				var dir_hacia_jugador = sign(jugador_objetivo.global_position.x - global_position.x)
				if dir_hacia_jugador != 0 and dir_hacia_jugador != direccion:
					_girar()
					
			if timer_suelo:
				timer_suelo.start(15.0) # 15 Segundos de paciencia intentando matar
# ============================================================================
# LÓGICA TERRESTRE Y COMBATE
# ============================================================================

func _manejar_movimiento() -> void:
	match estado_actual:
		Estado.TECHO, Estado.SUELO:
			velocity.x = direccion * velocidad
			
		Estado.PERSEGUIR:
			# Extra: Si el jugador objetivo se guardó pero se perdió, aseguramos que gire dinámicamente
			if jugador_objetivo:
				var dir_hacia_jugador = sign(jugador_objetivo.global_position.x - global_position.x)
				if dir_hacia_jugador != 0 and dir_hacia_jugador != direccion:
					_girar()
					
			velocity.x = direccion * (velocidad * 1.5) # Un poco más rápida al perseguir
			
		Estado.CARGAR, Estado.ATACAR, Estado.REPOSO, Estado.SUBIR, Estado.IDLE:
			velocity.x = move_toward(velocity.x, 0, 10.0) # Frenado

# LÓGICA DE EVENTOS EXTERNOS (SEÑALES)
# Asume que tendrás un AreaVision conectada a estas funciones (igual que el Monitor)
func _on_area_vision_body_entered(body: Node2D) -> void:
	if esta_muerto: return
	if body.is_in_group("Jugador"):
		jugador_objetivo = body # Guardamos quién es para el láser
		if estado_actual in [Estado.SUELO, Estado.PERSEGUIR, Estado.IDLE]:
			estado_actual = Estado.CARGAR
		velocity.x = 0
		if timer_carga:
			timer_carga.start(1.0) # Toma 1 segundo preparar el láser
			
func _on_area_vision_body_exited(body: Node2D) -> void:
	if esta_muerto: return
	
	if body == jugador_objetivo:
		jugador_objetivo = null # Lo perdió de vista

	# ELIMINADO: La araña ya no cancela su láser si el jugador escapa.
	# Una vez iniciada la CARGA, el ataque es definitivo e ininterrumpible.

func _on_timer_carga_timeout() -> void:
	if esta_muerto or estado_actual != Estado.CARGAR: return
	
	estado_actual = Estado.ATACAR
	_disparar_laser()
	
	# Le damos un instante al ataque antes de sobrecalentarse
	await get_tree().create_timer(0.5).timeout
	if esta_muerto: return
	
	estado_actual = Estado.REPOSO
	if timer_reposo:
		timer_reposo.start(2.0) # "sobrecalentada" 2 segundos
		
func _disparar_laser() -> void:
	if not proyectil_laser:
		push_warning("Araña intentó disparar pero proyectil_laser no está asignado en Inspector")
		return
		
	# Instanciar el rayo láser
	var instancia = proyectil_laser.instantiate()
	
	# Usar pos de disparo, o la global si Mark2D no existe
	if marker_disparo:
		instancia.global_position = marker_disparo.global_position
	else:
		instancia.global_position = global_position
		
	# Establecer dirección
	var dir_recta = Vector2(direccion, 0)
	instancia.set("direccion", dir_recta)
	
	# Si la araña está en el techo (gravedad inversa), el láser puede verse raro, ajustamos rotación
	instancia.rotation = dir_recta.angle()
	if estado_actual == Estado.TECHO:
		instancia.rotation_degrees += 180
	
	# Añadir el láser a la escena
	get_tree().current_scene.add_child(instancia)
	
func _on_timer_reposo_timeout() -> void:
	if esta_muerto or estado_actual != Estado.REPOSO: return
	
	# Verificamos si, tras el reposo, el jugador sigue en la mira. Si sí, volvemos a atacar en bucle.
	if jugador_objetivo != null:
		estado_actual = Estado.CARGAR
		velocity.x = 0
		if timer_carga:
			timer_carga.start(1.0) # Vuelve a preparar otro láser
	else:
		estado_actual = Estado.PERSEGUIR

func _on_timer_suelo_timeout() -> void:
	if esta_muerto or estado_actual in [Estado.REPOSO, Estado.CARGAR, Estado.ATACAR]: 
		# No intenta subir si está muerta o en medio de un ataque
		if timer_suelo: timer_suelo.start(3.0) # Lo intenta de nuevo en 3 segs
		return
		
	# Escaneamos si realmente hay techo arriba antes de intentar subir
	if ray_techo:
		ray_techo.force_raycast_update()
		if not ray_techo.is_colliding():
			# No hay techo disponible en su rango, se queda patrullando en el suelo
			if timer_suelo: timer_suelo.start(15.0) 
			return
		else:
			# Registramos el punto exacto del techo para anclar la telaraña
			punto_anclaje_techo = ray_techo.get_collision_point()
			
	# Si hay techo, inicia el ascenso y estira el hilo hacia arriba
	estado_actual = Estado.SUBIR
	_iniciar_telarana(punto_anclaje_techo)
	
# ============================================================================
# ANIMACIONES Y VISUALES (EFECTO CIBERNÉTICO)
# ============================================================================
func _process(_delta: float) -> void:
	_actualizar_animaciones()
	if linea_neon and is_instance_valid(linea_neon):
		# El punto 0 es fijo en el mundo (techo)
		# El punto 1 sigue en tiempo real a la araña, 6 píxeles más arriba para centrarse mejor visualmente
		var punto_sigue = global_position
		punto_sigue.y -= 6.0
		linea_neon.set_point_position(1, linea_neon.to_local(punto_sigue))

func _iniciar_telarana(anclaje_personalizado: Vector2 = Vector2.ZERO) -> void:
	if linea_neon: _borrar_telarana()
		
	linea_neon = Line2D.new()
	linea_neon.width = 2.0
	linea_neon.default_color = Color(0.0, 1.0, 1.0, 0.8) # Cyan Neón transparente
	
	# Registramos el punto inicial al techo en coordenadas globales
	if anclaje_personalizado != Vector2.ZERO:
		punto_anclaje_techo = anclaje_personalizado
	else:
		punto_anclaje_techo = global_position
		
	# Lo adjuntamos a la raíz del nivel para que no siga a la araña como padre local
	get_tree().current_scene.call_deferred("add_child", linea_neon)
	
	linea_neon.add_point(linea_neon.to_local(punto_anclaje_techo)) # P0 (Techo fijo)
	
	var punto_inicio = global_position
	punto_inicio.y -= 6.0
	linea_neon.add_point(linea_neon.to_local(punto_inicio))   # P1 (Sigue a la araña)

func _borrar_telarana() -> void:
	if linea_neon and is_instance_valid(linea_neon):
		linea_neon.queue_free()
		linea_neon = null

func _actualizar_animaciones() -> void:
	if esta_muerto or not sprite or not sprite.sprite_frames: return
	
	match estado_actual:
		Estado.TECHO, Estado.SUELO, Estado.PERSEGUIR, Estado.SUBIR:
			if velocity.x != 0 or velocity.y != 0:
				sprite.play("araña_caminando")
			else:
				sprite.play("araña-reposo")
		Estado.CAER:
			sprite.play("araña_caida")
		Estado.IDLE:
			sprite.play("araña-reposo")
		Estado.CARGAR:
			sprite.play("araña_carga")
		Estado.ATACAR:
			sprite.play("araña_ataque")
		Estado.REPOSO:
			if sprite.animation != "araña_descarga":
				sprite.play("araña_descarga")

func _morir(jugador: Node2D) -> void:
	_borrar_telarana()
	super._morir(jugador)
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("araña_destruida"):
		sprite.play("araña_destruida")
		
# ============================================================================
# LÓGICA DE DETENER SUBIDA DE FASE 4 (Borrado de telaraña)
# ============================================================================
func _physics_process(delta: float) -> void:
	if estado_actual == Estado.SUBIR:
		# Ignoramos rutina base. Subimos en Y ignorando gravedad
		velocity.x = 0
		velocity.y = - (velocidad * 1.5)
		if sprite: sprite.flip_v = true
		move_and_slide()
		if is_on_ceiling():
			estado_actual = Estado.TECHO
			_borrar_telarana() # Corta la telaraña
		return

	# Ejecuta la rutina base
	super._physics_process(delta)
	
	if esta_muerto: return
	
	# Recicla la IA original de física
	if estado_actual == Estado.TECHO and ray_deteccion_jugador:
		ray_deteccion_jugador.force_raycast_update()
		if ray_deteccion_jugador.is_colliding():
			var obj = ray_deteccion_jugador.get_collider()
			if obj and obj.is_in_group("Jugador"):
				_iniciar_caida(obj)
				
	# === LÓGICA DE ATERRIZAJE ===
	elif estado_actual == Estado.CAER:
		# Bloqueo horizontal al caer
		velocity.x = 0
		if is_on_floor():
			# Aterrizamos.
			_borrar_telarana()
			collision_mask = mascara_original
			estado_actual = Estado.PERSEGUIR
			
			# Orientar inmediatamente la araña hacia donde está el jugador registrado
			if jugador_objetivo:
				var dir_hacia_jugador = sign(jugador_objetivo.global_position.x - global_position.x)
				if dir_hacia_jugador != 0 and dir_hacia_jugador != direccion:
					_girar()
					
			if timer_suelo:
				timer_suelo.start(15.0) # 15 Segundos de paciencia intentando matar
