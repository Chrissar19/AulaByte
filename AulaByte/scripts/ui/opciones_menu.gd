#-- res://scripts/ui/opciones_menu.gd
extends Control
class_name OpcionesMenu

# Rutas
const RUTA_MENU := "res://escenas/menu/menu_principal.tscn"

# Buses de audio
const BUS_MASTER := "Master"
const BUS_MUSICA := "Musica"
const BUS_EFECTOS := "Efectos"
const BUS_NARRACIONES := "Narraciones"

# Config local
const CFG_PATH := "user://ajustes.cfg"
const CFG_AUDIO := "audio"
const CFG_VIDEO := "video"

#-- Nodos 
@onready var sld_master: HSlider = $MarginContainer/HBoxContainer/GridContainer/SldMaster
@onready var sld_musica: HSlider = $MarginContainer/HBoxContainer/GridContainer/SldMusica
@onready var sld_efectos: HSlider = $MarginContainer/HBoxContainer/GridContainer/SldEfectos
@onready var sld_narraciones: HSlider = $MarginContainer/HBoxContainer/GridContainer/SldVoces
@onready var cb_fullscreen: CheckButton = $MarginContainer/HBoxContainer/VBoxContainer3/Chk_Fullscreen
@onready var btn_volver: Button = $MarginContainer/HBoxContainer/HBoxContainer/BtnVolver
@onready var btn_reset: Button = $MarginContainer/HBoxContainer/HBoxContainer/BtnRestaurar


func _ready() -> void:
    # Rango dB típico
    for s in [sld_master, sld_musica, sld_efectos, sld_narraciones]:
        if s:
            s.min_value = -40.0
            s.max_value = 0.0
            s.step = 0.5

    _cargar_y_aplicar_config()

    if not FileAccess.file_exists(CFG_PATH):
        # Inicial por sistema si no hay config previa
        if sld_master:      sld_master.value = _get_bus_db(BUS_MASTER, 0.0)
        if sld_musica:      sld_musica.value = _get_bus_db(BUS_MUSICA, -6.0)
        if sld_efectos:     sld_efectos.value = _get_bus_db(BUS_EFECTOS, -6.0)
        if sld_narraciones: sld_narraciones.value = _get_bus_db(BUS_NARRACIONES, -6.0)
        if cb_fullscreen:
            cb_fullscreen.button_pressed = (get_window().mode == Window.MODE_FULLSCREEN)

    # Conexiones
    if sld_master:      sld_master.value_changed.connect(_on_master_changed)
    if sld_musica:      sld_musica.value_changed.connect(_on_musica_changed)
    if sld_efectos:     sld_efectos.value_changed.connect(_on_efectos_changed)
    if sld_narraciones: sld_narraciones.value_changed.connect(_on_narraciones_changed)
    if cb_fullscreen:   cb_fullscreen.toggled.connect(_on_fullscreen_toggled)
    if btn_volver:      btn_volver.pressed.connect(_on_volver)
    if btn_reset:       btn_reset.pressed.connect(_on_reset)

    set_process_unhandled_key_input(true)

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        _on_volver()

# ───────────── helpers de audio ─────────────
func _get_bus_index(bus_name: String) -> int:
    return AudioServer.get_bus_index(bus_name)

func _get_bus_db(bus_name: String, default_db: float) -> float:
    var idx := _get_bus_index(bus_name)
    if idx == -1:
        push_warning("Bus no encontrado: %s" % bus_name)
        return default_db
    return AudioServer.get_bus_volume_db(idx)

func _set_bus_db(bus_name: String, db: float) -> void:
    var idx := _get_bus_index(bus_name)
    if idx == -1:
        push_warning("Bus no encontrado: %s" % bus_name)
        return
    AudioServer.set_bus_volume_db(idx, db)

# ───────────── handlers ─────────────
func _on_master_changed(v: float) -> void:
    _set_bus_db(BUS_MASTER, v)

func _on_musica_changed(v: float) -> void:
    _set_bus_db(BUS_MUSICA, v)

func _on_efectos_changed(v: float) -> void:
    _set_bus_db(BUS_EFECTOS, v)

func _on_narraciones_changed(v: float) -> void:
    _set_bus_db(BUS_NARRACIONES, v)

func _on_fullscreen_toggled(pressed: bool) -> void:
    if pressed:
        get_window().mode = Window.MODE_FULLSCREEN
    else:
        get_window().mode = Window.MODE_WINDOWED

func _on_reset() -> void:
    if sld_master:      sld_master.value = 0.0
    if sld_musica:      sld_musica.value = -6.0
    if sld_efectos:     sld_efectos.value = -6.0
    if sld_narraciones: sld_narraciones.value = -6.0
    if cb_fullscreen:   cb_fullscreen.button_pressed = false
    _aplicar_actual_y_guardar()

func _on_volver() -> void:
    _guardar_config()
    # Notifica al GameManager (autoload) si quieres trackear estado
    if has_node("/root/GameManager"):
        get_node("/root/GameManager").call("cambiar_estado", get_node("/root/GameManager").EstadoJuego.MENU_PRINCIPAL)
    get_tree().change_scene_to_file(RUTA_MENU)

# ───────────── config ─────────────
func _cargar_y_aplicar_config() -> void:
    if not FileAccess.file_exists(CFG_PATH):
        return
    var cfg := ConfigFile.new()
    var err := cfg.load(CFG_PATH)
    if err != OK:
        push_warning("No se pudo cargar config: %s" % CFG_PATH)
        return

    var master_db := float(cfg.get_value(CFG_AUDIO, "master_db", 0.0))
    var musica_db := float(cfg.get_value(CFG_AUDIO, "musica_db", -6.0))
    var efectos_db := float(cfg.get_value(CFG_AUDIO, "efectos_db", -6.0))
    var narr_db := float(cfg.get_value(CFG_AUDIO, "narraciones_db", -6.0))
    var full := bool(cfg.get_value(CFG_VIDEO, "fullscreen", false))

    if sld_master:      sld_master.value = master_db
    if sld_musica:      sld_musica.value = musica_db
    if sld_efectos:     sld_efectos.value = efectos_db
    if sld_narraciones: sld_narraciones.value = narr_db
    if cb_fullscreen:   cb_fullscreen.button_pressed = full

    _set_bus_db(BUS_MASTER, master_db)
    _set_bus_db(BUS_MUSICA, musica_db)
    _set_bus_db(BUS_EFECTOS, efectos_db)
    _set_bus_db(BUS_NARRACIONES, narr_db)

    if full:
        get_window().mode = Window.MODE_FULLSCREEN
    else:
        get_window().mode = Window.MODE_WINDOWED

func _guardar_config() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value(CFG_AUDIO, "master_db",      sld_master and sld_master.value or 0.0)
    cfg.set_value(CFG_AUDIO, "musica_db",      sld_musica and sld_musica.value or -6.0)
    cfg.set_value(CFG_AUDIO, "efectos_db",     sld_efectos and sld_efectos.value or -6.0)
    cfg.set_value(CFG_AUDIO, "narraciones_db", sld_narraciones and sld_narraciones.value or -6.0)
    cfg.set_value(CFG_VIDEO, "fullscreen",     cb_fullscreen and cb_fullscreen.button_pressed or false)
    var err := cfg.save(CFG_PATH)
    if err != OK:
        push_warning("No se pudo guardar config: %s" % CFG_PATH)

func _aplicar_actual_y_guardar() -> void:
    _set_bus_db(BUS_MASTER,      sld_master and sld_master.value or 0.0)
    _set_bus_db(BUS_MUSICA,      sld_musica and sld_musica.value or -6.0)
    _set_bus_db(BUS_EFECTOS,     sld_efectos and sld_efectos.value or -6.0)
    _set_bus_db(BUS_NARRACIONES, sld_narraciones and sld_narraciones.value or -6.0)

    if cb_fullscreen and cb_fullscreen.button_pressed:
        get_window().mode = Window.MODE_FULLSCREEN
    else:
        get_window().mode = Window.MODE_WINDOWED

    _guardar_config()
