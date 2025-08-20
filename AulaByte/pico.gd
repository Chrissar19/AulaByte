extends CharacterBody2D

@export var gravedad := 400.0
@export var altura_colision := 60.0
@export var tiempo_vida := 2.0 # segundos antes de desaparecer tras caer

@onready var detector: Area2D = $Detector
@onready var colision: CollisionShape2D = $CollisionShape2D
@onready var colision_detector: CollisionShape2D = $Detector/ColisionDetector
@onready var dmg: Area2D = $DMG

var activo := false
var tiempo_restante := 0.0

func _ready() -> void:
	add_to_group("Enemigos")
	dmg.add_to_group("DMG")
	
	#-- tamaño de area de deteccion en Y
	var cuadrado: RectangleShape2D = colision_detector.shape
	var tam_inicial = cuadrado.size
	var pos_inicial = colision_detector.position
	var dif_altura = altura_colision - tam_inicial.y
	var scala_y = altura_colision / tam_inicial.y
	colision_detector.scale.y = scala_y
	colision_detector.position.y += dif_altura / 2.0
	
	velocity = Vector2.ZERO
	detector.body_entered.connect(_on_sensor_body_entered)

func _on_sensor_body_entered(body: Node) -> void:
	if body.is_in_group("Jugador") and not activo:
		activo = true
		tiempo_restante = tiempo_vida

func _physics_process(delta: float) -> void:
	if activo:
		# Aplicar gravedad
		velocity.y += gravedad * delta

		# Mover y detectar colisiones
		var col = move_and_collide(velocity * delta)
		if col:
			_on_colision(col.get_collider())

		# Contar tiempo hasta desaparecer
		if tiempo_restante > 0:
			tiempo_restante -= delta
			if tiempo_restante <= 0:
				queue_free()

func _on_colision(body: Node) -> void:
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(1)
		queue_free()
	elif body.is_in_group("Suelo") or body is TileMap:
		# Golpeó el suelo: destruir luego del tiempo_vida
		queue_free()


func _on_dmg_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		body.recibir_dmg(1)
