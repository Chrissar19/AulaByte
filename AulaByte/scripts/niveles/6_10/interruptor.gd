extends Area2D
class_name Interruptor

signal activado(id: String, ref: Node)
signal desactivado(id: String)

@export_group("Configuración")
@export var id: String = "A" 
@export_enum("azul", "amarilla", "roja", "morada", "verde", "rosa", "naranja") var color_inter: String = "verde"
@export var activo: bool = false
@export var tiempo_limite: float = 5.0

@export_group("Visual Indicador")
@export var velocidad_pulso: float = 4.0
@export var escala_min: float = 0.9
@export var escala_max: float = 1.1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var t_feedback: Timer = $Timer
@onready var lbl_indicador_interaccion: Label = $LblIndicadorInteraccion

var jugador_en_rango: bool = false
var fijado: bool = false
var _t_pulso := 0.0

func _ready() -> void:
	add_to_group("Interruptores")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	asignar_color()
	
	if anim.sprite_frames.has_animation("desactivado"):
		anim.play("desactivado")
	
	# Configuración inicial del indicador
	if lbl_indicador_interaccion:
		lbl_indicador_interaccion.visible = false
		lbl_indicador_interaccion.pivot_offset = lbl_indicador_interaccion.size / 2
	
	t_feedback.one_shot = true
	t_feedback.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_rango = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_rango = false

func _process(delta: float) -> void:
	# ==========================
	# LÓGICA DE INTERACCIÓN
	# ==========================
	if not activo and not fijado and jugador_en_rango and Input.is_action_just_pressed("Accion"):
		activar_con_tiempo()

	# ==========================
	# VISIBILIDAD Y PULSO DEL INDICADOR
	# ==========================
	if lbl_indicador_interaccion:
		# Solo visible si está el jugador cerca Y el interruptor no está activo ni fijado
		var debe_mostrarse = jugador_en_rango and not activo and not fijado
		lbl_indicador_interaccion.visible = debe_mostrarse
		
		if debe_mostrarse:
			# Efecto de pulso igual que la puerta
			_t_pulso += delta * velocidad_pulso
			var t := (sin(_t_pulso) + 1.0) * 0.5
			var factor: float = lerp(escala_min, escala_max, t)
			lbl_indicador_interaccion.scale = Vector2.ONE * factor

func activar_con_tiempo() -> void:
	activo = true
	if anim.sprite_frames.has_animation("activado"):
		anim.play("activado")
	
	# Oculta el indicador inmediatamente al activar
	if lbl_indicador_interaccion:
		lbl_indicador_interaccion.visible = false
		
	emit_signal("activado", id, self)
	t_feedback.start(tiempo_limite)

func _on_timer_timeout() -> void:
	if not fijado:
		desactivar_visual()

func fijar_activado() -> void:
	fijado = true
	activo = true
	t_feedback.stop()
	
	# Ocultar indicador permanentemente
	if lbl_indicador_interaccion:
		lbl_indicador_interaccion.visible = false
	
	# Brillo de éxito
	self.modulate = self.modulate * 1.8 
	
	if anim.sprite_frames.has_animation("activado"):
		anim.play("activado")

func desactivar_visual() -> void:
	if anim.sprite_frames.has_animation("desactivado"):
		anim.play("desactivado")
	activo = false
	emit_signal("desactivado", id)

func asignar_color() -> void:
	var color_final : Color
	
	match color_inter:
		"azul":     color_final = Color(0.0, 0.663, 1.0, 1.0)
		"amarilla": color_final = Color(1, 1, 0)
		"morada":   color_final = Color(0.5, 0, 0.5)
		"roja":     color_final = Color(0.89, 0.0, 0.0, 1.0)
		"verde":    color_final = Color(0.5, 1, 0.5)
		"rosa":     color_final = Color(1.0, 0.0, 0.49, 1.0)
		"naranja":  color_final = Color(1.0, 0.647, 0.0, 1.0)
	
	# Aplicar el color del interruptor a la letra
	anim.modulate = color_final
	
	if lbl_indicador_interaccion:
		lbl_indicador_interaccion.modulate = color_final
