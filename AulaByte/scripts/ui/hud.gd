extends CanvasLayer

# ============================================================================
# SEÑALES
# ============================================================================
signal tiempo_terminado

# ============================================================================
# NODOS
# ============================================================================
@onready var lbl_puntos: Label = $MarginContainer/HBoxContainer/HBoxPuntos/lblPuntos
@onready var lbl_tiempo_restante: Label = $MarginContainer/HBoxContainer/HBoxTiempo/lblTiempoRestante
@onready var contenedor_corazones: HBoxContainer = $MarginContainer/HBoxContainer/HBoxVidas
@onready var lbl_nivel: Label = $MarginContainer/HBoxContainer/LblNivel

# ============================================================================
# VARIABLES
# ============================================================================
var tiempo_restante: float = 180.0
const CORAZON_TEX := preload("res://recursos/imagenes/ui/Corazon.png")

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	#-- Busca al jugador inicial
	if not GameManager.is_connected("vida_actualizada", Callable(self, "actualizar_vidas")):
		GameManager.connect("vida_actualizada", Callable(self, "actualizar_vidas"))
	if not GameManager.is_connected("jugador_gana_puntos", Callable(self, "actualizar_puntos")):
		GameManager.connect("jugador_gana_puntos", Callable(self, "actualizar_puntos"))
	if not GameManager.is_connected("tiempo_actualizado", Callable(self, "_on_tiempo_actualizado")):
		GameManager.connect("tiempo_actualizado", Callable(self, "_on_tiempo_actualizado"))
	if not GameManager.is_connected("tiempo_terminado", Callable(self, "_on_tiempo_terminado")):
		GameManager.connect("tiempo_terminado", Callable(self, "_on_tiempo_terminado"))
	if not GameManager.is_connected("jugador_muerto", Callable(self, "_on_jugador_muerto")):
		GameManager.connect("jugador_muerto", Callable(self, "_on_jugador_muerto"))
		
	# Estado inicial
	actualizar_vidas(GameManager.vidas)
	actualizar_puntos(GameManager.puntos)
	_on_tiempo_actualizado(int(GameManager.tiempo_restante))
	_actualizar_nivel()

# ============================================================================
# CALLBACK DE LAS SEÑALES DEL JUGADOR
# ============================================================================
func actualizar_vidas(vidas: int) -> void:
	# Limpiar corazones anteriores
	for hijo in contenedor_corazones.get_children():
		hijo.queue_free()
	# Añadir corazones nuevos
	for i in range(vidas):
		var corazon := TextureRect.new()
		corazon.texture = CORAZON_TEX
		corazon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		corazon.custom_minimum_size = Vector2(17, 17)
		contenedor_corazones.add_child(corazon)

func actualizar_puntos(puntos: int) -> void:
	lbl_puntos.text = str(puntos)
	
# ============================================================================	
# TIEMPO
# ============================================================================	
func _on_tiempo_actualizado(segundos: int) -> void:
	lbl_tiempo_restante.text = "T: %s" % _mm_ss(segundos)

func _on_tiempo_terminado() -> void:
	emit_signal("tiempo_terminado")
	
func _mm_ss(seg: int) -> String:
	var m := seg / 60
	var s := seg % 60
	return "%02d:%02d" % [m, s]
	
func _actualizar_nivel() -> void:
	var nivel_base := get_parent()
	var numero_nivel := 0

	if nivel_base is NivelBase:
		var nb := nivel_base as NivelBase
		numero_nivel = nb.id_nivel
	else:
		numero_nivel = GameManager.nivel_actual

	if numero_nivel <= 0:
		lbl_nivel.text = "NV: 0"
	else:
		lbl_nivel.text = "NV: %d" % numero_nivel
