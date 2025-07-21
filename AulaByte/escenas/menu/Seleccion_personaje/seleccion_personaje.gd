extends Control

#-- Selecciona a un personaje a partir de los recursos de "personaInfo"
#-- Preparado para ampliarse a un multijugador

#-- RUTA DONDE SE GUARDO LOS .tres ---
const RUTA_INFO := "res://escenas/personajes/info/"

#-- Referencias de nodos de UI (Se resuelven en _ready) ---
@onready var hbox_personajes: HBoxContainer = $VBoxContainer/hboxPersonajes
@onready var lbl_nombre: Label = $VBoxContainer/lblNombre
@onready var btn_confirmar: Button = $VBoxContainer/HBoxContainer/btnConfirmar
@onready var btn_volver: Button = $VBoxContainer/HBoxContainer/btnVolver
@onready var audio_click: AudioStreamPlayer = $AudioClick
@onready var audio_cambio: AudioStreamPlayer = $AudioCambio

#-- Datos internos
var lista_info : Array[Resource] =[] # <- PersonaInfo
var indice_seleccionado : int = -1 # <- Ningun personaje seleccionado

func _ready() -> void:
	estilo_botones(btn_confirmar)
	estilo_botones(btn_volver)
	_cargar_personajes()
	_crear_botones()
	_conectar_botones()
	_actualizar_ui()
	
#---------------------------------------------------------------------------------------------------
#Cargar toidos los .tres dentro de la ruta dada
#---------------------------------------------------------------------------------------------------
func _cargar_personajes() -> void:
	for file in DirAccess.get_files_at(RUTA_INFO): #-- Devuelve un Array con los nombres de los archivos en la ruta
		if file.ends_with(".tres"):
			var recurso := load("%s/%s" % [RUTA_INFO, file])
			if recurso is personajeInfo:
				lista_info.append(recurso)
				
#---------------------------------------------------------------------------------------------------
#--Boton por personaje
#---------------------------------------------------------------------------------------------------
func _crear_botones() -> void:
	for info in lista_info:
		var btn := TextureButton.new()
		btn.texture_normal = info.sprite
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.name = str(info.id) #-- Se usa el id para identificar
		hbox_personajes.add_child(btn)
		
#---------------------------------------------------------------------------------------------------
#-- Conectar las señales de clic de cada botón + las teclas
#---------------------------------------------------------------------------------------------------
func _conectar_botones() -> void:
	for btn in hbox_personajes.get_children():
		btn.pressed.connect(_on_boton_personaje.bind(btn.name.to_int())) #-- Conecta cada boton a la miusma funcion, segun su id
	btn_confirmar.pressed.connect(_on_confirmar)
	btn_volver.pressed.connect(_on_volver)
	
#---------------------------------------------------------------------------------------------------
#-- Cuando se selecciona un personale
#---------------------------------------------------------------------------------------------------
func _on_boton_personaje(id_personaje: int) -> void:
	audio_cambio.play() #-- Sonido
	await get_tree().create_timer(0.2).timeout #-- Pequeña pausa para que suene
	indice_seleccionado = id_personaje
	_actualizar_ui()
	
#---------------------------------------------------------------------------------------------------
#-- Actualizar texto, resaltado y estado de boton confirmar
#---------------------------------------------------------------------------------------------------
func _actualizar_ui() -> void:
	#-- Mostrar nombre o mensaje por defecto
	if indice_seleccionado == -1:
		lbl_nombre.text = "Elige un personaje"
		btn_confirmar.disabled = true
	else:
		var info := _get_info(indice_seleccionado)
		lbl_nombre.text = info.nombre
		btn_confirmar.disabled = false
		
	#-- resaltar al personaje seleccionado
	for btn in hbox_personajes.get_children():
		btn_modulate(btn, btn.name.to_int() == indice_seleccionado)
		
#-- Pintar el boton seleccionado
func btn_modulate(btn: TextureButton, activo: bool) -> void:
	btn.modulate = Color.WHITE if activo else Color(0.7,0.7,0.7,1)
	btn.scale = Vector2(1.2, 1.2) if activo else Vector2(1, 1)
	
#--Devuelve el personajeInfo por id
func _get_info(id: int) -> personajeInfo:
	for info in lista_info:
		if info.id == id:
			return info
	return null

#-------------------------------------------------------------------------------
#-- Movimiento por teclado
#-------------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if lista_info.is_empty():
		return
		
	if event.is_action_pressed("izquierda"):
		audio_cambio.play() #-- Sonido
		await get_tree().create_timer(0.2).timeout #-- Pequeña pausa para que suene
		indice_seleccionado = (indice_seleccionado - 1 + lista_info.size()) % lista_info.size()
		_actualizar_ui()
	elif event.is_action_pressed("derecha"):
		audio_cambio.play() #-- Sonido
		await get_tree().create_timer(0.2).timeout #-- Pequeña pausa para que suene
		indice_seleccionado = (indice_seleccionado + 1) % lista_info.size()
		_actualizar_ui()
	elif event.is_action_pressed("ui_accept") and indice_seleccionado != -1:
		audio_click.play() #-- Sonido
		await get_tree().create_timer(0.2).timeout #-- Pequeña pausa para que suene
		_on_confirmar()
	elif event.is_action_pressed("ui_cancel"):
		audio_click.play() #-- Sonido
		await get_tree().create_timer(0.2).timeout #-- Pequeña pausa para que suene
		_on_volver()
	
#---------------------------------------------------------------------------------------------------
#-- Confirmar >> guarda la seleccion y pasa al primer nivel
#---------------------------------------------------------------------------------------------------
func _on_confirmar() -> void:
	audio_click.play() #-- Sonido
	await get_tree().create_timer(0.2).timeout #-- Pequeña pausa para que suene
	var info := _get_info(indice_seleccionado)
	JugadorSeleccionado.seleccionar(info.id)
	JugadorSeleccionado.set_info(info)
	get_tree().change_scene_to_file("res://escenas/ui/pantalla_carga.tscn")
	
#---------------------------------------------------------------------------------------------------
#-- Volver al menu principal
#---------------------------------------------------------------------------------------------------
func _on_volver() -> void:
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")

#--------------------------------------------------------------------------------------------------
#-- estilo de Botones confirmar y volver
#--------------------------------------------------------------------------------------------------
func estilo_botones(boton: Button) -> void:
	#-- Carmbiar colores del texto
	boton.add_theme_color_override("font_color_hover", Color.CORNFLOWER_BLUE)
	boton.add_theme_color_override("font_color_pressed", Color.BLUE)
	
	#-- Estado normal
	var fondo_normal := StyleBoxFlat.new()
	fondo_normal.bg_color = Color(0.2, 0.2, 0.2)
	boton.add_theme_stylebox_override("normal", fondo_normal)
	
	#-- Estado hover
	var fondo_hover := StyleBoxFlat.new()
	fondo_hover.bg_color = Color(0.3, 0.3, 0.3)
	boton.add_theme_stylebox_override("hover", fondo_hover)
	
	#-- estado pressed
	var fondo_pressed := StyleBoxFlat.new()
	fondo_pressed.bg_color = Color(0.4, 0.1, 0.1)
	boton.add_theme_stylebox_override("pressed", fondo_pressed)
