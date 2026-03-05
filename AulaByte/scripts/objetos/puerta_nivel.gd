extends Area2D
class_name PuertaNivel

@export var parametros_actividad: Dictionary = {}  # aquí configuras cosas por puerta (opcional)

# --- Opciones de efecto visual ---
@export var usar_efecto_pulso: bool = true
@export var escala_min: float = 0.9
@export var escala_max: float = 1.1
@export var velocidad_pulso: float = 4.0  # más alto = más rápido

@export var usar_cambio_color: bool = true
@export var color_base: Color = Color(1, 1, 1, 1)      # blanco
@export var color_resaltado: Color = Color(1, 1, 0.5)  # blanco-amarillo suave

@onready var animacion_puerta: AnimatedSprite2D = $AnimacionPuerta
@onready var lbl_indicador_interaccion: Label = $LblIndicadorInteraccion

var jugador_en_puerta := false
var _t_pulso := 0.0

func _ready() -> void:
	z_index = ZCapas.PUERTAS
	animacion_puerta.play("Cerrada")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Asegurarnos de que el indicador empiece oculto
	if lbl_indicador_interaccion:
		lbl_indicador_interaccion.visible = false
		lbl_indicador_interaccion.scale = Vector2.ONE
		lbl_indicador_interaccion.modulate = color_base

func _process(delta: float) -> void:
	# ==========================
	# EFECTO VISUAL DEL INDICADOR
	# ==========================
	if lbl_indicador_interaccion and lbl_indicador_interaccion.visible and usar_efecto_pulso:
		_t_pulso += delta * velocidad_pulso

		# t oscila entre 0 y 1 usando una sinusoide
		var t := (sin(_t_pulso) + 1.0) * 0.5

		# Escala pulsante
		var factor: float = lerp(escala_min, escala_max, t)
		lbl_indicador_interaccion.scale = Vector2.ONE * factor

		# Cambio de color opcional
		if usar_cambio_color:
			lbl_indicador_interaccion.modulate = color_base.lerp(color_resaltado, t)
	else:
		# Si no está activo o no queremos el efecto, restauramos valores
		if lbl_indicador_interaccion:
			lbl_indicador_interaccion.scale = Vector2.ONE
			lbl_indicador_interaccion.modulate = color_base

	# ==========================
	# LÓGICA DE INTERACCIÓN
	# ==========================
	if not jugador_en_puerta:
		return

	# Modificación en PuertaNivel.gd dentro de _process o donde detectes la tecla "E"

	if Input.is_action_just_pressed("Accion"):
		if GameManager.estado_actual == GameManager.EstadoJuego.JUGANDO:
			# 1. Registrar esta puerta como activa
			GameManager.puerta_actual = self
		
			# 2. SOLO llamar a establecer_parametros si la puerta TIENE datos.
			# Si 'parametros_actividad' está vacío en el Inspector, no borramos lo del Nivel.
			if not parametros_actividad.is_empty():
				GameManager.establecer_parametros_actividad(parametros_actividad)
		
			# 3. Feedback visual
			if lbl_indicador_interaccion:
				lbl_indicador_interaccion.visible = false
				
			print("PUERTA: Abriendo minijuego...")
			GameManager.solicitar_minijuego()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Jugador"):
		print("Jugador entró en la puerta")
		jugador_en_puerta = true
		GameManager.puerta_actual = self 

		# Mostrar el aviso de "Pulsa E"
		if lbl_indicador_interaccion:
			_t_pulso = 0.0  # reiniciar el ciclo de pulso
			lbl_indicador_interaccion.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_puerta = false
		if GameManager.puerta_actual == self:
			GameManager.puerta_actual = null

		if lbl_indicador_interaccion:
			lbl_indicador_interaccion.visible = false
			lbl_indicador_interaccion.scale = Vector2.ONE
			lbl_indicador_interaccion.modulate = color_base
			_t_pulso = 0.0

func abrir_puerta() -> void:
	animacion_puerta.play("Abriendo")
	await animacion_puerta.animation_finished
