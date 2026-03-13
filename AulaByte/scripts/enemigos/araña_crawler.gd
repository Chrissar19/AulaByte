extends CharacterBody2D
class_name ArañaCrawler

# ============================================================================
# EXPORTS
# ============================================================================
@export var monedas: int = 5
@export var velocidad_techo: float = 60.0
@export var velocidad_suelo: float = 80.0
@export var gravedad: float = 900.0
@export var fuerza_succion: float = -500.0 
@export var mega_laser_escena: PackedScene = preload("res://escenas/personajes/enemigos/laser.tscn")
@export var max_rondas_suelo: int = 3 # Cuántas veces patrulla antes de subir
@export var giros_realizados: int = 2

enum Estado { TECHO, CAYENDO, SUELO, CARGANDO, ATACANDO, REPOSO, MUERTO, VIGILANDO }
var estado_actual = Estado.TECHO
var direccion: int = 1
var vida: int = 3
var rondas_completadas: int = 0

# ============================================================================
# NODOS
# ============================================================================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_jugador: RayCast2D = $DeteccionSuelo # Detecta abajo desde el techo
@onready var ray_muro: RayCast2D = $RayMuro          # Detecta paredes de frente
@onready var ray_borde: RayCast2D = $RayBorde        # Detecta vacíos al caminar
@onready var ray_techo_up: RayCast2D = $DeteccionTecho # Detecta techo hacia ARRIBA
@onready var line_telaraña: Line2D = $LineTelaraña
@onready var timer_carga: Timer = $TimerCarga
@onready var marker_disparo: Marker2D = $MarkerDisparo
@onready var area_araña: CollisionShape2D = $AreaAraña
@onready var daño_araña: Area2D = $DañoAraña
@onready var cabeza_araña: Area2D = $CabezaAraña

# ============================================================================
# PROCESO PRINCIPAL
# ============================================================================
func _ready() -> void:

	ray_techo_up.collision_mask = 33 
	
	line_telaraña.z_index = -1
	
func _physics_process(delta: float) -> void:
	match estado_actual:
		Estado.TECHO:
			_logica_techo(delta)
		Estado.CAYENDO:
			_logica_caida(delta)
		Estado.SUELO, Estado.CARGANDO, Estado.ATACANDO, Estado.REPOSO, Estado.VIGILANDO:
			_aplicar_gravedad_suelo(delta)
			if estado_actual == Estado.SUELO:
				_logica_suelo(delta)
			else:
				# Frenado en seco para estados estáticos (Vigilar, Cargar, Ataque)
				velocity.x = move_toward(velocity.x, 0, 20)
	
	move_and_slide()

func _aplicar_gravedad_suelo(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	elif velocity.y > 0:
		velocity.y = 0

# ============================================================================
# LÓGICAS DE MOVIMIENTO
# ============================================================================

func _logica_techo(_delta: float) -> void:
	sprite.play("araña_techo")
	
	velocity.y = fuerza_succion 
	velocity.x = direccion * velocidad_techo
	sprite.flip_h = direccion < 0
	
	# Sensores
	ray_muro.target_position.x = 25 * direccion
	ray_borde.target_position = Vector2(25 * direccion, -35) 
	
	# DETECCIÓN CON FILTRO ANTI-BUG
	if is_on_wall() or ray_muro.is_colliding() or not ray_borde.is_colliding():
		direccion *= -1
		
		# --- EL FIX: Empujón de seguridad ---
		# Movemos a la araña un par de píxeles en la nueva dirección 
		# para que el RayCast no detecte el mismo borde otra vez.
		global_position.x += direccion * 2
		
		# Forzamos actualización para que el siguiente frame lea bien
		ray_muro.force_raycast_update()
		ray_borde.force_raycast_update()
	
	# Si por alguna razón se despega del techo (y no está cayendo)
	if not is_on_ceiling() and estado_actual == Estado.TECHO:
		# Si pierde contacto con el techo, que caiga de pie
		_preparar_caida()

	if ray_jugador.is_colliding():
		var colision = ray_jugador.get_collider()
		if colision.is_in_group("Jugador"):
			_preparar_caida()

func _logica_suelo(_delta: float) -> void:
	velocity.x = direccion * velocidad_suelo
	sprite.play("araña_walk")
	sprite.flip_h = direccion < 0
	
	# Actualizar sensores frontales
	ray_muro.target_position.x = 30 * direccion
	ray_borde.target_position = Vector2(25 * direccion, 35)
	
	# DETECCIÓN DE OBSTÁCULO (Pared o Borde)
	if is_on_wall() or ray_muro.is_colliding() or not ray_borde.is_colliding():
		_iniciar_vigilancia()
	
	# DETECCIÓN DE ATAQUE (Solo si está en el suelo y no vigilando)
	if _jugador_en_rango_ataque():
		_iniciar_carga_laser()

func _cambiar_direccion_suelo() -> void:
	direccion *= -1
	giros_realizados += 1
	if giros_realizados >= max_rondas_suelo:
		_intentar_regreso_al_techo()

func _preparar_caida() -> void:
	estado_actual = Estado.CAYENDO
	velocity.x = 0
	sprite.flip_v = true 
	sprite.play("araña_caer")

func _logica_caida(delta: float) -> void:
	velocity.y += gravedad * delta
	if is_on_floor():
		estado_actual = Estado.SUELO
		sprite.flip_v = false
		giros_realizados = 0
		
func _iniciar_vigilancia() -> void:
	estado_actual = Estado.VIGILANDO
	velocity.x = 0
	sprite.play("araña_idle")
	print("DEBUG: Crawler en modo guardia...")
	
	# Se queda quieta 2 segundos "vigilando" el borde/pared
	await get_tree().create_timer(2.0).timeout
	
	if estado_actual == Estado.VIGILANDO:
		_finalizar_vigilancia()

func _finalizar_vigilancia() -> void:
	rondas_completadas += 1
	direccion *= -1 # Ahora sí gira
	
	if rondas_completadas >= max_rondas_suelo:
		_intentar_regreso_al_techo()
	else:
		estado_actual = Estado.SUELO
# ============================================================================
# INTELIGENCIA DE RETORNO (SUBIR AL TECHO)
# ============================================================================

func _intentar_regreso_al_techo() -> void:
	# Forzamos al rayo a mirar todas las superficies sólidas
	ray_techo_up.force_raycast_update()
	
	if ray_techo_up.is_colliding():
		var objeto_tocado = ray_techo_up.get_collider()
		
		# Verificamos si lo que tocamos es un suelo o plataforma válida
		if objeto_tocado.is_in_group("Z_PISOS") or objeto_tocado is TileMap:
			var punto_techo = ray_techo_up.get_collision_point()
			_iniciar_ascenso(punto_techo)
	else:
		# Si no hay nada sólido arriba, sigue patrullando
		giros_realizados = 0 
		estado_actual = Estado.SUELO

func _iniciar_ascenso(destino: Vector2) -> void:
	estado_actual = Estado.REPOSO
	velocity = Vector2.ZERO
	
	line_telaraña.clear_points()
	line_telaraña.add_point(Vector2.ZERO)
	line_telaraña.add_point(to_local(destino))
	
	# Aseguramos que la línea sea visible al inicio
	line_telaraña.modulate.a = 1.0
	
	var tween = create_tween()
	# 1. Subir la araña
	tween.tween_property(self, "global_position", destino, 1.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 2. Desvanecer la línea (al mismo tiempo o justo después)
	tween.parallel().tween_property(line_telaraña, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	line_telaraña.clear_points()
	estado_actual = Estado.TECHO

# ============================================================================
# COMBATE Y DAÑO (Tu lógica optimizada)
# ============================================================================

func _jugador_en_rango_ataque() -> bool:
	if GameManager.jugador_ref and is_instance_valid(GameManager.jugador_ref):
		var distancia = global_position.distance_to(GameManager.jugador_ref.global_position)
		var diff_y = abs(global_position.y - GameManager.jugador_ref.global_position.y)
		
		# Solo detecta si el jugador está a su frente (signo de X coincide con dirección)
		var dir_hacia_jugador = sign(GameManager.jugador_ref.global_position.x - global_position.x)
		
		if distancia < 250 and diff_y < 60 and dir_hacia_jugador == direccion:
			return true
	return false

func _iniciar_carga_laser() -> void:
	estado_actual = Estado.CARGANDO
	velocity.x = 0 
	sprite.play("araña_cargando")
	timer_carga.start(1.5)

func _on_timer_carga_timeout() -> void:
	# El ataque es un proceso pesado: una vez cargado, se dispara SÍ O SÍ
	if estado_actual == Estado.CARGANDO:
		_disparar_mega_laser()

func _disparar_mega_laser() -> void:
	estado_actual = Estado.ATACANDO
	sprite.play("araña_ataque")
	
	var laser = mega_laser_escena.instantiate()
	laser.global_position = marker_disparo.global_position
	var dir_disparo = Vector2(direccion, 0)
	laser.direccion = dir_disparo
	laser.rotation = dir_disparo.angle()
	get_tree().current_scene.add_child(laser)
	
	velocity.x = -direccion * 200.0 
	velocity.y = -150.0 
	
	await get_tree().create_timer(0.6).timeout
	_entrar_en_reposo()

func _entrar_en_reposo() -> void:
	estado_actual = Estado.REPOSO
	sprite.play("araña_descarga")
	await get_tree().create_timer(2.0).timeout
	if estado_actual != Estado.MUERTO:
		estado_actual = Estado.SUELO

func morir(jugador: Node2D) -> void:
	estado_actual = Estado.MUERTO
	velocity = Vector2.ZERO
	cabeza_araña.set_deferred("monitoring", false)
	daño_araña.set_deferred("monitoring", false)
	area_araña.set_deferred("disabled", true) 
	sprite.play("araña_dead")
	if jugador.has_method("ganar_puntos"):
		jugador.ganar_puntos(monedas)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_daño_araña_body_entered(body: Node2D) -> void:
	if estado_actual == Estado.MUERTO or estado_actual == Estado.REPOSO: return
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_golpe_desde"):
			body.recibir_golpe_desde(global_position, 1)
			if estado_actual == Estado.CAYENDO:
				velocity.y = -250.0
				estado_actual = Estado.SUELO
				sprite.flip_v = false

func _on_cabeza_araña_body_entered(body: Node2D) -> void:
	if estado_actual == Estado.MUERTO: return
	if body.is_in_group("Jugador"):
		body.velocity.y = -400.0 
		vida -= 1
		if vida <= 0: morir(body)
		else:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color(10, 10, 10), 0.1)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)
