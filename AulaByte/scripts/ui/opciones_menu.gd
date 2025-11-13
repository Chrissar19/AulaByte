extends Control
class_name OpcionesMenu

@onready var sld_master: HSlider = $MarginContainer/VBoxContainer/GridContainer/SldGeneral
@onready var sld_musica: HSlider = $MarginContainer/VBoxContainer/GridContainer/SldMusica
@onready var btn_restablecer: Button = $MarginContainer/VBoxContainer/HBoxContainer/BtnRestablecer
@onready var btn_volver: Button = $MarginContainer/VBoxContainer/HBoxContainer/BtnVolver

const RUTA_MENU := "res://escenas/menu/menu_principal.tscn"
const BUS_MASTER := "Master"
const BUS_MUSICA := "Musica" 
const BUS_EFECTOS := "Efectos"
const BUS_NARRACIONES := "Narraciones" 

func _ready() -> void:
	# Inicial
	sld_master.min_value = -40.0; sld_master.max_value = 0.0
	sld_musica.min_value = -40.0; sld_musica.max_value = 0.0

	sld_master.value = _get_db(BUS_MASTER)
	sld_musica.value = _get_db(BUS_MUSICA)

	sld_master.value_changed.connect(_on_master_changed)
	sld_musica.value_changed.connect(_on_musica_changed)
	btn_volver.pressed.connect(_on_volver)
	btn_restablecer.pressed.connect(_on_reset)

func _get_db(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_db(idx)

func _set_db(bus_name: String, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(idx, db)

func _on_master_changed(v: float) -> void:
	_set_db(BUS_MASTER, v)

func _on_musica_changed(v: float) -> void:
	_set_db(BUS_MUSICA, v)

func _on_reset() -> void:
	sld_master.value = 0.0
	sld_musica.value = -6.0

func _on_volver() -> void:
	get_tree().change_scene_to_file(RUTA_MENU)
