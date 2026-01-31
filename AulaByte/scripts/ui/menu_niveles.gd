extends Control
class_name MenuNiveles

@onready var aud_click: AudioStreamPlayer = $AudClick

func _on_button_pressed() -> void:
	GameManager.cambiar_estado(GameManager.EstadoJuego.SELECCION_PERSONAJE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		await _reproducir_sonido(aud_click)
		_on_button_pressed()
		
func _reproducir_sonido(audio: AudioStreamPlayer) -> void:
	if audio == null:
		return
	audio.play()
	await get_tree().create_timer(0.2).timeout
