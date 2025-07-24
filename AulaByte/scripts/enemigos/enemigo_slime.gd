extends Node2D

@export var velocidad: float = 30.0
@export var dmg: int = 1 #-- DMG = el daño que realiza el enemigo damage

var direccion := 1

@onready var ray_cast_derecha: RayCast2D = $RayCastDerecha
@onready var ray_cast_izquierda: RayCast2D = $RayCastIzquierda
@onready var sensor_dano: Area2D = $SensorDaño
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("Enemigos") #--Grupo para los enemigos
	sensor_dano.body_entered.connect(_on_sensor_dmg)
	
func _process(delta: float) -> void:
	#-- cambia la direccion si choca con el RaiCast
	if ray_cast_derecha.is_colliding():
		direccion = -1
		animated_sprite_2d.flip_h = true
	elif ray_cast_izquierda.is_colliding():
		direccion = 1
		animated_sprite_2d.flip_h = false
		
	#-- Movimiento simple
	position.x += direccion * velocidad * delta

func _on_sensor_dmg(nodo: Node2D) -> void:
	if nodo.is_in_group("Jugador"):
		nodo.recibir_dmg() #-- En el script del jugador se procesara el daño
