extends Control
class_name MenuPerder

@onready var lbl_puntos: Label = $VBoxContainer/lblPuntos
@onready var lbl_causa_muerte: Label = $VBoxContainer/lblCausaMuerte
@onready var btn_reintentar: Button = $VBoxContainer/HBoxContainer/btnReintentar
@onready var btn_menu_principal: Button = $VBoxContainer/HBoxContainer/BtnMenuPrincipal

func _ready() -> void:
	get_tree().paused = false

	if GameManager:
		lbl_puntos.text = "Puntos: " + str(GameManager.get_puntos())

		if GameManager.has_method("get_causa_muerte"):
			var causa := GameManager.get_causa_muerte()
			if causa == "":
				causa = "Has perdido la partida"
			lbl_causa_muerte.text = causa
		else:
			lbl_causa_muerte.text = "Has perdido la partida"
	else:
		lbl_puntos.text = "Puntos: 0"
		lbl_causa_muerte.text = "Has perdido la partida"

	btn_reintentar.pressed.connect(_on_btn_reintentar_pressed)
	btn_menu_principal.pressed.connect(_on_btn_menu_principal_pressed)

func _on_btn_reintentar_pressed() -> void:
	if GameManager:
		GameManager.reintentar_nivel_actual()

func _on_btn_menu_principal_pressed() -> void:
	if GameManager:
		GameManager.reiniciar_puntos()
		GameManager.reiniciar_vidas()
		GameManager.preparar_nivel()
		GameManager.ir_a_menu_principal()
