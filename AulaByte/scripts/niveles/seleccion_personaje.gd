#-- SelectorPersonaje
extends Control

#==============================================================================
#  Selector de personaje para un jugador (preparado para multijugador futuro)
#==============================================================================

const RUTA_INFO: String = "res://datos/info/" # Carpeta con archivos .tres

#-- Referencias a nodos UI
@onready var hbox_personajes: HBoxContainer = $VBoxContainer/hboxPersonajes
@onready var lbl_nombre: Label = $VBoxContainer/lblNombre
@onready var btn_confirmar: Button = $VBoxContainer/HBoxContainer/btnConfirmar
@onready var btn_volver: Button = $VBoxContainer/HBoxContainer/btnVolver
@onready var audio_click: AudioStreamPlayer = $AudioClick
@onready var audio_cambio: AudioStreamPlayer = $AudioCambio
@onready var btn_delgado: TextureButton = $VBoxContainer/hboxPersonajes/btnDelgado
@onready var btn_romo: TextureButton = $VBoxContainer/hboxPersonajes/btnRomo
@onready var btn_insuasty: TextureButton = $VBoxContainer/hboxPersonajes/btnInsuasty
@onready var btn_jojoa: TextureButton = $VBoxContainer/hboxPersonajes/btnJojoa

@export var info_delgado: personajeInfo
@export var info_romo: personajeInfo
@export var info_insuasty: personajeInfo
@export var info_jojoa: personajeInfo

#-- Variables internas
var lista_info: Array[personajeInfo] = []
var indice_seleccionado: int = -1


#==============================================================================
#  Ciclo de vida
#==============================================================================

func _ready() -> void:

	_aplicar_estilo_boton(btn_confirmar)
	_aplicar_estilo_boton(btn_volver)

	# Opcional: enviar sonidos al bus "Efectos"
	if audio_click:
		audio_click.bus = "Efectos"
	if audio_cambio:
		audio_cambio.bus = "Efectos"
		
	_configurar_botones_personajes()

	# Si hay personajes, seleccionar el primero por defecto
	if lista_info.size() > 0:
		indice_seleccionado = 0

	_actualizar_ui()

	# Conexiones de botones
	btn_confirmar.pressed.connect(_on_confirmar)
	btn_volver.pressed.connect(_on_volver)


#----------------------------------------------------------------------
# Configurar botones
#----------------------------------------------------------------------
func _configurar_botones_personajes() -> void:
	lista_info.clear()

	_registrar_personaje(btn_delgado, info_delgado)
	_registrar_personaje(btn_romo, info_romo)
	_registrar_personaje(btn_insuasty, info_insuasty)
	_registrar_personaje(btn_jojoa, info_jojoa)


func _registrar_personaje(boton: TextureButton, info: personajeInfo) -> void:
	if boton == null:
		return

	if info == null:
		# Si no asignaste info para este botón, lo ocultamos
		boton.visible = false
		return

	var index := lista_info.size()
	lista_info.append(info)

	# Configurar botón
	boton.texture_normal = info.sprite
	boton.focus_mode = Control.FOCUS_NONE
	boton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton.visible = true

	# Conectar señal
	boton.pressed.connect(_on_personaje_seleccionado.bind(index))


#==============================================================================
#  UI: actualización y selección
#==============================================================================

func _on_personaje_seleccionado(indice: int) -> void:
	if indice < 0 or indice >= lista_info.size():
		return

	indice_seleccionado = indice
	await _reproducir_sonido(audio_cambio)
	_actualizar_ui()


func _actualizar_ui() -> void:
	if lista_info.is_empty():
		lbl_nombre.text = "No hay personajes disponibles"
		btn_confirmar.disabled = true
		return

	if indice_seleccionado < 0 or indice_seleccionado >= lista_info.size():
		lbl_nombre.text = "Elige un personaje"
		btn_confirmar.disabled = true
	else:
		var info: personajeInfo = lista_info[indice_seleccionado]
		lbl_nombre.text = info.nombre
		btn_confirmar.disabled = false

	# Resaltar botón seleccionado
	var child_count := hbox_personajes.get_child_count()
	for i in range(child_count):
		var child := hbox_personajes.get_child(i)
		if child is TextureButton:
			_resaltar_boton(child, i == indice_seleccionado)


func _resaltar_boton(btn: TextureButton, activo: bool) -> void:
	if activo:
		btn.modulate = Color(1, 1, 1, 1)
		btn.scale = Vector2(1.2, 1.2)
	else:
		btn.modulate = Color(0.7, 0.7, 0.7, 1.0)
		btn.scale = Vector2.ONE


func _get_info_actual() -> personajeInfo:
	if indice_seleccionado >= 0 and indice_seleccionado < lista_info.size():
		return lista_info[indice_seleccionado]
	return null


#==============================================================================
#  Input por teclado
#==============================================================================
func _accion_presionada(event: InputEvent, nombres: Array[String]) -> bool:
	for nombre in nombres:
		if InputMap.has_action(nombre) and event.is_action_pressed(nombre):
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if lista_info.is_empty():
		return

	# Soportar varias acciones posibles para izquierda/derecha
	var izquierda_presionada := event.is_action_pressed("ui_left") \
		or event.is_action_pressed("izquierda")

	var derecha_presionada := event.is_action_pressed("ui_right") \
		or event.is_action_pressed("derecha")

	if izquierda_presionada:
		await _reproducir_sonido(audio_cambio)
		if indice_seleccionado == -1:
			indice_seleccionado = 0
		else:
			indice_seleccionado -= 1
			if indice_seleccionado < 0:
				indice_seleccionado = lista_info.size() - 1
		_actualizar_ui()

	elif derecha_presionada:
		await _reproducir_sonido(audio_cambio)
		if indice_seleccionado == -1:
			indice_seleccionado = 0
		else:
			indice_seleccionado += 1
			if indice_seleccionado >= lista_info.size():
				indice_seleccionado = 0
		_actualizar_ui()

	elif event.is_action_pressed("ui_accept"):
		_on_confirmar()

	elif event.is_action_pressed("ui_cancel"):
		_on_volver()


#==============================================================================
#  Confirmar selección y cambio de escena
#==============================================================================

func _on_confirmar() -> void:
	var info := _get_info_actual()
	if info == null:
		return

	await _reproducir_sonido(audio_click)

	# Guardar personaje elegido en el GameManager
	GameManager.seleccionar_personaje(info.id, info)

	# Reiniciar estado de juego para una nueva partida
	GameManager.reiniciar_puntos()
	GameManager.reiniciar_vidas()
	GameManager.nivel_actual = 0
	GameManager.codigo_generado = false
	GameManager.codigo_actividad_actual.clear()

	# Pasar al estado de carga (pantalla_de_carga la maneja el GameManager)
	GameManager.cambiar_estado(GameManager.EstadoJuego.CARGANDO)


func _on_volver() -> void:
	await _reproducir_sonido(audio_click)
	GameManager.ir_a_menu_principal()


#==============================================================================
#  Utilidades
#==============================================================================

func _reproducir_sonido(audio: AudioStreamPlayer) -> void:
	if audio == null:
		return

	audio.play()
	await get_tree().create_timer(0.2).timeout


func _aplicar_estilo_boton(boton: Button) -> void:
	if boton == null:
		return

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
