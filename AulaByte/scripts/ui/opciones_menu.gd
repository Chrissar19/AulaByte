extends Control
class_name OpcionesMenu

const RUTA_MENU := "res://escenas/menu/menu_principal.tscn"
const CFG_PATH := "user://ajustes.cfg"

# Buses
const BUS_MASTER := "Master"
const BUS_MUSICA := "Musica"
const BUS_EFECTOS := "Efectos"
const BUS_NARRACIONES := "Narraciones"

@onready var sld_master: HSlider = $MarginContainer/VBoxContainer/GridContainer/SldGeneral
@onready var sld_musica: HSlider = $MarginContainer/VBoxContainer/GridContainer/SldMusica
@onready var sld_efectos: HSlider = $MarginContainer/VBoxContainer/GridContainer/SldEfectos
@onready var sld_narraciones: HSlider = $MarginContainer/VBoxContainer/GridContainer/SldNarraciones
@onready var cb_fullscreen: CheckButton = $MarginContainer/VBoxContainer/ChkFull
@onready var btn_reset: Button = $MarginContainer/VBoxContainer/HBoxContainer/BtnRestablecer
@onready var btn_volver: Button = $MarginContainer/VBoxContainer/HBoxContainer/BtnVolver

func _ready() -> void:
	_configurar_sliders()
	_cargar_y_aplicar_config()
	_conectar_senales()
	set_process_unhandled_key_input(true)

func _configurar_sliders() -> void:
	for s in [sld_master, sld_musica, sld_efectos, sld_narraciones]:
		if s:
			s.min_value = -40.0
			s.max_value = 0.0
			s.step = 0.5

func _conectar_senales() -> void:
	if sld_master: sld_master.value_changed.connect(func(v): _set_bus_db(BUS_MASTER, v))
	if sld_musica: sld_musica.value_changed.connect(func(v): _set_bus_db(BUS_MUSICA, v))
	if sld_efectos: sld_efectos.value_changed.connect(func(v): _set_bus_db(BUS_EFECTOS, v))
	if sld_narraciones: sld_narraciones.value_changed.connect(func(v): _set_bus_db(BUS_NARRACIONES, v))
	if cb_fullscreen: cb_fullscreen.toggled.connect(_on_fullscreen_toggled)
	if btn_volver: btn_volver.pressed.connect(_on_volver)
	if btn_reset: btn_reset.pressed.connect(_on_reset)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_volver()

func _set_bus_db(bus_name: String, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, db)
		AudioServer.set_bus_mute(idx, db <= -39.5)

# --- Manejadores ---
func _on_fullscreen_toggled(is_pressed: bool) -> void:
	if is_pressed:
		# "Exclusive" suele ser más compatible para juegos
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_reset() -> void:
	if sld_master: sld_master.value = 0.0
	if sld_musica: sld_musica.value = -6.0
	if sld_efectos: sld_efectos.value = -6.0
	if sld_narraciones: sld_narraciones.value = -6.0
	if cb_fullscreen: cb_fullscreen.button_pressed = false
	_guardar_config()

func _on_volver() -> void:
	_guardar_config()
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if "volver_a_nivel_desde_opciones" in gm and gm.volver_a_nivel_desde_opciones:
			gm.volver_a_nivel_desde_opciones = false
			gm.reintentar_nivel_actual()
			return
		gm.cambiar_estado(gm.EstadoJuego.MENU_PRINCIPAL)
	get_tree().change_scene_to_file(RUTA_MENU)

# --- Persistencia ---
func _cargar_y_aplicar_config() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CFG_PATH)
	
	# Aquí corregimos la advertencia (UNUSED_VARIABLE)
	if err != OK:
		push_warning("Archivo de config no encontrado o corrupto. Cargando defaults.")

	var master_v = cfg.get_value("audio", "master_db", 0.0)
	var musica_v = cfg.get_value("audio", "musica_db", -6.0)
	var efectos_v = cfg.get_value("audio", "efectos_db", -6.0)
	var narr_v = cfg.get_value("audio", "narraciones_db", -6.0)
	var is_full = cfg.get_value("video", "fullscreen", false)

	if sld_master: sld_master.value = master_v
	if sld_musica: sld_musica.value = musica_v
	if sld_efectos: sld_efectos.value = efectos_v
	if sld_narraciones: sld_narraciones.value = narr_v
	if cb_fullscreen: cb_fullscreen.button_pressed = is_full

	_set_bus_db(BUS_MASTER, master_v)
	_set_bus_db(BUS_MUSICA, musica_v)
	_set_bus_db(BUS_EFECTOS, efectos_v)
	_set_bus_db(BUS_NARRACIONES, narr_v)
	
	# Aplicamos el estado de la pantalla
	_on_fullscreen_toggled(is_full)

func _guardar_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_db", sld_master.value if sld_master else 0.0)
	cfg.set_value("audio", "musica_db", sld_musica.value if sld_musica else -6.0)
	cfg.set_value("audio", "efectos_db", sld_efectos.value if sld_efectos else -6.0)
	cfg.set_value("audio", "narraciones_db", sld_narraciones.value if sld_narraciones else -6.0)
	cfg.set_value("video", "fullscreen", cb_fullscreen.button_pressed if cb_fullscreen else false)
	cfg.save(CFG_PATH)
