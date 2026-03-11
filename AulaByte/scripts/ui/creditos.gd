extends Node2D
class_name Creditos

# ====================================================================
# Configuración
# ====================================================================
@export var main_menu_path: String = "res://escenas/menu/menu_principal.tscn"
@export var skip_hold_time: float = 1.5  # Segundos para saltar

# ====================================================================
# Nodos
# ====================================================================
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var technical_credits: RichTextLabel = $Pantalla/TechnicalCredits
@onready var skip_ui: Control = $Pantalla/SkipUI
@onready var progress_bar: ProgressBar = $Pantalla/SkipUI/ProgressBar

# ====================================================================
# Variables de Estado
# ====================================================================
var current_hold: float = 0.0
var is_finishing: bool = false

func _ready() -> void:
	# 1. Configuración inicial de la interfaz
	skip_ui.modulate.a = 0.0
	progress_bar.value = 0
	
	# 2. Iniciar la secuencia de cuadros (Galería)
	if anim_player.has_animation("show_credits"):
		anim_player.play("show_credits")
	
	# 3. Conectar la señal para saber cuándo termina cada fase
	anim_player.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	# Manejar la lógica de saltar créditos en cada frame
	handle_skip_logic(delta)

# ====================================================================
# Lógica de Interacción
# ====================================================================
func handle_skip_logic(delta: float) -> void:
	# Detectar si el usuario mantiene presionada una tecla de salto
	if Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_ESCAPE):
		current_hold += delta
		
		# Mostrar la UI de salto suavemente
		skip_ui.modulate.a = lerp(skip_ui.modulate.a, 1.0, 0.1)
		
		# Actualizar la barra de progreso
		progress_bar.value = (current_hold / skip_hold_time) * 100
		
		# Si se completó el tiempo de espera, terminar
		if current_hold >= skip_hold_time and not is_finishing:
			finish_credits()
	else:
		# Resetear si suelta la tecla
		current_hold = 0.0
		progress_bar.value = 0
		skip_ui.modulate.a = lerp(skip_ui.modulate.a, 0.0, 0.1)

# ====================================================================
# Gestión de Animaciones
# ====================================================================
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"show_credits":
			# Al terminar los cuadros, empezamos el scroll de texto largo
			if anim_player.has_animation("technical_scroll"):
				anim_player.play("technical_scroll")
			else:
				# Si no existe la animación técnica, terminar de una vez
				finish_credits()
				
		"technical_scroll":
			# Al terminar el scroll, cerramos la escena
			finish_credits()

# ====================================================================
# Cierre de Escena
# ====================================================================
func finish_credits() -> void:
	if is_finishing: return
	is_finishing = true
	
	# Desvanecimiento final suave antes de cambiar de escena
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.finished.connect(func(): 
		get_tree().change_scene_to_file(main_menu_path))
