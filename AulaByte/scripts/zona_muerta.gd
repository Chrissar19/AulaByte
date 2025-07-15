extends Area2D

@onready var timer: Timer = $Timer
@onready var sound_death: AudioStreamPlayer = $SoundDeath

func _on_body_entered(body: Node2D) -> void: #Activa la zona de muerte
	sound_death.play() # Reproduce el sonido de muerte
	print("Capturado")
	Engine.time_scale = 0.8 #Controla la velocidad (tiempo) en el juego siendo 1 va vel normal
	body.get_node("CollisionShape2D").queue_free() #Elimina la colision del jugador para que pueda caer al vacio
	timer.start() #Una vez activa la zona de muerte de activa el NodoTimer.

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene() #reinicia la escena
	
