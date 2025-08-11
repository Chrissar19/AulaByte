extends Area2D

@onready var sonido: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $Sprite2D

var activado := false

func _ready() -> void:
	
	add_to_group("Checkpoint")
	sprite.play("Idle")
	
func _on_body_entered(body: Node2D) -> void:
	if activado or not body.is_in_group("Jugador"):
		return
		
	activado = true
	body.punto_reaparicion = global_position
	sonido.play()
	sprite.play("Activado")
	print("CheckPoint activado")
