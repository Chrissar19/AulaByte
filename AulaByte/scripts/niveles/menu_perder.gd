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


func _reintentar() -> void:
	# Delega en el GameManager
	if GameManager:
		GameManager.reintentar_nivel_actual()


func _volver_al_menu() -> void:
	if GameManager:
		GameManager.reiniciar_vidas()
		GameManager.reiniciar_puntos()
		GameManager.preparar_nivel()
		GameManager.ir_a_menu_principal()
