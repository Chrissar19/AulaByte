extends Node2D

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	# Pausamos la música a través del AudioManager global
	if AudioManager:
		AudioManager.pausar_musica()
	
	# Aseguramos que ocupe la pantalla, por si el editor lo desconfiguró
	video_player.expand = true
	video_player.size = get_viewport_rect().size 
	
	# Conectamos la señal en código por si se desconectó en el editor
	if not video_player.finished.is_connected(_on_video_stream_player_finished):
		video_player.finished.connect(_on_video_stream_player_finished)
	
	# Comenzar el video
	video_player.play()

func _input(event: InputEvent) -> void:
	# Permitir saltar los créditos
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_terminar_creditos()

func _on_video_stream_player_finished() -> void:
	_terminar_creditos()

func _terminar_creditos() -> void:
	# Reanudamos el AudioManager al regresar al menú
	if AudioManager:
		AudioManager.reanudar_musica()
		
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
