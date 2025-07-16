extends Control

#-- Selecciona a un personaje a partir de los recursos de "personaInfo"
#-- Preparado para ampliarse a un multijugador

#-- RUTA DONDE SE GUARDO LOS .tres ---
const RUTA_INFO := "res://personajes/info"

#-- Referencias de nodos de UI (Se resuelven en _ready) ---
@onready var hbox_personajes: HBoxContainer = $VBoxContainer/hboxPersonajes
@onready var lbl_nombre: Label = $VBoxContainer/lblNombre
@onready var btn_confirmar: Button = $VBoxContainer/HBoxContainer/btnConfirmar
@onready var btn_volver: Button = $VBoxContainer/HBoxContainer/btnVolver

#-- Datos internos
var lista_info : Array[Resource] =[] # <- PersonaInfo
var indice_seleccionado : int = -1 # <- Ningun personaje seleccionado

func _ready() -> void:
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
	
#--Devuelve el personajeInfo por id
func _get_info(id: int) -> personajeInfo:
	for info in lista_info:
		if info.id == id:
			return info
	return null
	
#---------------------------------------------------------------------------------------------------
#-- Confirmar >> guarda la seleccion y pasa al primer nivel
#---------------------------------------------------------------------------------------------------
func _on_confirmar() -> void:
	var info := _get_info(indice_seleccionado)
	JugadorSeleccionado.seleccionar(info.id)
	get_tree().change_scene_to_file("res://escenas/niveles/nivel_tuto.tscn")
	
func _on_volver() -> void:
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
