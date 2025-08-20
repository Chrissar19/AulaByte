extends CharacterBody2D

@export var dmg: int = 2
@export var tam := 1.0

@onready var area_2d: Area2D = $AnimatedSprite2D/Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("Enemigos")
	area_2d.add_to_group("DMG")
	animated_sprite_2d.scale = Vector2(tam, tam)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		body.recibir_dmg(dmg)
