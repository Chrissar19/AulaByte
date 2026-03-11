extends Node2D
class_name Creditos

# Configuración
@export var main_menu_path: String = "res://escenas/menu/menu_principal.tscn"
@export var skip_hold_time: float = 1.5 

# Nodos
@onready var anim_player = $AnimationPlayer
@onready var camera = $Camera2D
@onready var pantalla: CanvasLayer = $Pantalla
@onready var technical_credits: RichTextLabel = $Pantalla/TechnicalCredits
@onready var skip_ui: Control = $Pantalla/SkipUI
@onready var progress_bar: ProgressBar = $Pantalla/SkipUI/ProgressBar

var current_hold = 0.0
var is_finishing = false

func _ready():
	# Configuración inicial de la UI
	skip_ui.modulate.a = 0
	progress_bar.value = 0
	
	# Empezamos la función de los cuadros
	anim_player.play("show_credits")
	anim_player.animation_finished.connect(_on_animation_finished)

func _process(delta):
	# Solo nos encargamos de detectar si el usuario quiere saltar
	handle_skip_logic(delta)

func handle_skip_logic(delta):
	if Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_ESCAPE):
		current_hold += delta
		skip_ui.modulate.a = lerp(skip_ui.modulate.a, 1.0, 0.1)
		progress_bar.value = (current_hold / skip_hold_time) * 100
		
		if current_hold >= skip_hold_time and not is_finishing:
			finish_credits()
	else:
		current_hold = 0.0
		progress_bar.value = 0
		skip_ui.modulate.a = lerp(skip_ui.modulate.a, 0.0, 0.1)

func _on_animation_finished(anim_name: String):
	if anim_name == "show_credits":
		# Ahora esta animación ya contiene el movimiento de la posición Y del texto
		anim_player.play("technical_scroll")
	elif anim_name == "technical_scroll":
		finish_credits()

func finish_credits():
	if is_finishing: return
	is_finishing = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func(): get_tree().change_scene_to_file(main_menu_path))
