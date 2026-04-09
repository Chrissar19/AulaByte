# ====================================================================
# INTERFAZ: MENÚ DE PAUSA
# ====================================================================
## Gestiona la navegación y el flujo del juego cuando el usuario detiene la partida.
extends CanvasLayer
class_name MenuPausa

# ====================================================================
# CONSTANTES Y RUTAS
# ====================================================================
const RUTA_MENU_PRINCIPAL := "res://escenas/menu/menu_principal.tscn"
const RUTA_OPCIONES := "res://escenas/menu/opciones_menu.tscn"

# ====================================================================
# NODOS DE INTERFAZ
# ====================================================================
@onready var btn_continuar: Button = $Panel/VBoxContainer/BtnContinuar
@onready var btn_opciones: Button = $Panel/VBoxContainer/BtnOpciones
@onready var btn_menu: Button = $Panel/VBoxContainer/BtnMenu
@onready var btn_salir: Button = $Panel/VBoxContainer/BtnSalir

# ====================================================================
# INICIALIZACIÓN Y CONFIGURACIÓN
# ====================================================================
func _ready() -> void:
	# Asegura que el menú responda incluso con el juego pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_conectar_seniales()
	if btn_continuar:
		btn_continuar.grab_focus()

func _conectar_seniales() -> void:
	if btn_continuar:
		btn_continuar.pressed.connect(_on_continuar_pressed)
	if btn_opciones:
		btn_opciones.pressed.connect(_on_opciones_pressed)
	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)
	if btn_salir:
		btn_salir.pressed.connect(_on_salir_pressed)

# ====================================================================
# MANEJO DE SEÑALES
# ====================================================================
func _on_continuar_pressed() -> void:
	GameManager.reanudar_juego()
	queue_free()

func _on_opciones_pressed() -> void:
	GameManager.volver_a_nivel_desde_opciones = true
	GameManager.reanudar_juego()
	get_tree().change_scene_to_file(RUTA_OPCIONES)
	queue_free()

func _on_menu_pressed() -> void:
	GameManager.reanudar_juego()
	GameManager.ir_a_menu_principal()
	queue_free()

func _on_salir_pressed() -> void:
	# Evita que el motor se quede pausado al cerrar
	get_tree().paused = false
	get_tree().quit()
