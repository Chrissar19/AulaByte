extends Node2D

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	if AudioManager:
		AudioManager.pausar_musica()
	
	video_player.expand = true
	video_player.size = get_viewport_rect().size 
	
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
	# Reanuda el AudioManager al regresar al menú
	if AudioManager:
		AudioManager.reanudar_musica()
		
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
