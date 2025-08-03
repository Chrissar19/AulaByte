extends Control

#==============================================================================
#  Selector de personaje para un jugador (preparado para multijugador futuro)
#==============================================================================

#-- Constantes
const RUTA_INFO: String = "res://escenas/personajes/info/" # Carpeta con archivos .tres

#-- Referencias a nodos UI
@onready var hbox_personajes: HBoxContainer = $VBoxContainer/hboxPersonajes
@onready var lbl_nombre: Label = $VBoxContainer/lblNombre
@onready var btn_confirmar: Button = $VBoxContainer/HBoxContainer/btnConfirmar
@onready var btn_volver: Button = $VBoxContainer/HBoxContainer/btnVolver
@onready var audio_click: AudioStreamPlayer = $AudioClick
@onready var audio_cambio: AudioStreamPlayer = $AudioCambio

#-- Variables internas
var lista_info: Array[personajeInfo] = []
var indice_seleccionado: int = -1


#==============================================================================
#  Ciclo de vida
#==============================================================================

func _ready() -> void:
	_aplicar_estilo_boton(btn_confirmar)
	_aplicar_estilo_boton(btn_volver)
	_cargar_personajes()
	_crear_botones()
	_conectar_botones()
	_actualizar_ui()


#==============================================================================
#  Carga de personajes y creación de botones
#==============================================================================

func _cargar_personajes() -> void:
	for file in DirAccess.get_files_at(RUTA_INFO):
		if file.ends_with(".tres"):
			var recurso := load("%s/%s" % [RUTA_INFO, file])
			if recurso is personajeInfo:
				lista_info.append(recurso)

func _crear_botones() -> void:
	for info in lista_info:
		var btn := TextureButton.new()
		btn.texture_normal = info.sprite
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.name = str(info.id)
		hbox_personajes.add_child(btn)


#==============================================================================
#  Conexión de botones
#==============================================================================

func _conectar_botones() -> void:
	for btn in hbox_personajes.get_children():
		btn.pressed.connect(_on_personaje_seleccionado.bind(btn.name.to_int()))
	btn_confirmar.pressed.connect(_on_confirmar)
	btn_volver.pressed.connect(_on_volver)


#==============================================================================
#  UI: actualización y selección
#==============================================================================

func _on_personaje_seleccionado(id: int) -> void:
	await _reproducir_sonido(audio_cambio)
	indice_seleccionado = id
	_actualizar_ui()

func _actualizar_ui() -> void:
	if indice_seleccionado == -1:
		lbl_nombre.text = "Elige un personaje"
		btn_confirmar.disabled = true
	else:
		var info := _get_info(indice_seleccionado)
		lbl_nombre.text = info.nombre
		btn_confirmar.disabled = false

	for btn in hbox_personajes.get_children():
		_resaltar_boton(btn, btn.name.to_int() == indice_seleccionado)

func _resaltar_boton(btn: TextureButton, activo: bool) -> void:
	btn.modulate = Color.WHITE if activo else Color(0.7, 0.7, 0.7, 1)
	btn.scale = Vector2(1.2, 1.2) if activo else Vector2.ONE

func _get_info(id: int) -> personajeInfo:
	for info in lista_info:
		if info.id == id:
			return info
	return null


#==============================================================================
#  Input por teclado
#==============================================================================

func _unhandled_input(event: InputEvent) -> void:
	if lista_info.is_empty():
		return

	if event.is_action_pressed("izquierda"):
		await _reproducir_sonido(audio_cambio)
		indice_seleccionado = (indice_seleccionado - 1 + lista_info.size()) % lista_info.size()
		_actualizar_ui()

	elif event.is_action_pressed("derecha"):
		await _reproducir_sonido(audio_cambio)
		indice_seleccionado = (indice_seleccionado + 1) % lista_info.size()
		_actualizar_ui()

	elif event.is_action_pressed("ui_accept") and indice_seleccionado != -1:
		await _reproducir_sonido(audio_click)
		_on_confirmar()

	elif event.is_action_pressed("ui_cancel"):
		await _reproducir_sonido(audio_click)
		_on_volver()


#==============================================================================
#  Confirmar selección y cambio de escena
#==============================================================================

func _on_confirmar() -> void:
	var info := _get_info(indice_seleccionado)
	JugadorSeleccionado.seleccionar(info.id)
	JugadorSeleccionado.set_info(info)
	get_tree().change_scene_to_file("res://escenas/ui/pantalla_carga.tscn")

func _on_volver() -> void:
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")


#==============================================================================
#  Utilidades
#==============================================================================

func _reproducir_sonido(audio: AudioStreamPlayer) -> void:
	audio.play()
	await get_tree().create_timer(0.2).timeout

func _aplicar_estilo_boton(boton: Button) -> void:
	boton.add_theme_color_override("font_color_hover", Color.CORNFLOWER_BLUE)
	boton.add_theme_color_override("font_color_pressed", Color.BLUE)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.2, 0.2, 0.2)
	boton.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.3, 0.3, 0.3)
	boton.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.4, 0.1, 0.1)
	boton.add_theme_stylebox_override("pressed", pressed)
