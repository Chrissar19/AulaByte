extends Node2D

const velocidad = 30

var direcion = 1

@onready var ray_cast_derecha: RayCast2D = $RayCastDerecha
@onready var ray_cast_izquierda: RayCast2D = $RayCastIzquierda
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void: #Se actualiza en cada frame
	if ray_cast_derecha.is_colliding():
		direcion = -1
		animated_sprite_2d.flip_h = true
	if ray_cast_izquierda.is_colliding():
		direcion = 1
		animated_sprite_2d.flip_h = false
	position.x += direcion * velocidad * delta
