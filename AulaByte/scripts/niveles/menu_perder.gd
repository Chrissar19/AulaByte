extends Control

#-- Referencias de nodos de UI (Se resuelven en _ready) ---
@onready var lbl_puntos: Label = $VBoxContainer/lblPuntos
@onready var btn_reintentar: Button = $VBoxContainer/HBoxContainer/btnReintentar
@onready var btn_menu_principal: Button = $VBoxContainer/HBoxContainer/btnMenuPrincipal
@onready var lbl_causa_muerte: Label = $VBoxContainer/lblCausaMuerte

#-- Datos internos
var lista_info : Array[Resource] =[] # <- PersonaInfo
var indice_seleccionado : int = -1 # <- Ningun personaje seleccionado

func _ready() -> void:
	lbl_causa_muerte.text = " "
	if GameManager and GameManager.get_puntos() != null:
		lbl_puntos.text = "Puntos: " + str(GameManager.get_puntos())
	else:
		lbl_puntos.text = "Puntos: 0"
	
	btn_menu_principal.pressed.connect(_volver_al_menu)
	btn_reintentar.pressed.connect(_reintentar)
	
func _reintentar():
	get_tree().change_scene_to_file("res://escenas/menu/Seleccion_personaje/seleccion_personaje.tscn")
	
func _volver_al_menu():
	GameManager.reiniciar_vidas()
	GameManager.set_tiempo(0.0)
	GameManager.reiniciar_puntos()
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
