extends Control
class_name MenuPerder

@onready var lbl_puntos: Label = $VBoxContainer/lblPuntos
@onready var lbl_causa_muerte: Label = $VBoxContainer/lblCausaMuerte
@onready var btn_reintentar: Button = $VBoxContainer/HBoxContainer/btnReintentar
@onready var btn_menu_principal: Button = $VBoxContainer/HBoxContainer/BtnMenuPrincipal

func _ready() -> void:
	# Por si acaso venimos de un estado pausado
	get_tree().paused = false

	# Mostrar puntos y causa de muerte desde el GameManager
	if GameManager:
		lbl_puntos.text = "Puntos: " + str(GameManager.get_puntos())

		if GameManager.has_method("get_causa_muerte"):
			var causa := GameManager.get_causa_muerte()
			# Evitar texto vacío raro
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
		# Este método ya:
		# - prepara el nivel
		# - reinicia vidas
		# - hace change_scene al nivel actual
		# - cambia estado a JUGANDO

func _on_btn_menu_principal_pressed() -> void:
	if GameManager:
		# Reset general y volver al menú principal usando SOLO el GameManager
		GameManager.reiniciar_puntos()
		GameManager.reiniciar_vidas()
		GameManager.preparar_nivel()
		GameManager.ir_a_menu_principal()
