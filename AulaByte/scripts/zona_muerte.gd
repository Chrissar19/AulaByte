extends Area2D

@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte
@onready var timer: Timer = $Timer

func _ready() -> void:
	add_to_group("ZonaMortal")

func _on_body_entered(body: Node2D) -> void: #Activa la zona de muerte
	if body.is_in_group("Jugador"):
		sonido_muerte.play() # Reproduce el sonido de muerte
		print("Cayo en zona mortal")
		Engine.time_scale = 0.5 #Controla la velocidad (tiempo) en el juego siendo 1 va vel normal
		body.get_node("CollisionShape2D").queue_free() #Elimina la colision del jugador para que pueda caer al vacio
		timer.start() #Una vez activa la zona de muerte de activa el NodoTimer.

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene() #reinicia la escena
	
