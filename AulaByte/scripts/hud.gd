extends CanvasLayer

signal tiempo_terminado

@onready var lbl_puntos: Label = $HBoxPuntos/lblPuntos
@onready var lbl_tiempo: Label = $lblTiempo
@onready var lbl_vidas: Label = $HBoxVidas/lblVidas
@onready var lbl_tiempo_restante: Label = $HBoxTiempo/lblTiempoRestante
@onready var contenedor_corazones: HBoxContainer = $HBoxVidas

var tiempo_restante: float = 90.0 #-- Segundos
var tiempo_total: float = 0.0

const CORAZON_TEX := preload("res://recursos/imagenes/ui/Corazon.png")

func _ready() -> void:
	actualizar_vidas()
	actualizar_puntos(JugadorSeleccionado.get_puntos())
	JugadorSeleccionado.connect("vida_perdida", actualizar_vidas)
	JugadorSeleccionado.connect("vida_ganada", actualizar_vidas)

func _process(delta: float) -> void:
	tiempo_total += delta
	
	if tiempo_restante > 0:
		tiempo_restante -= delta
		tiempo_restante = max(tiempo_restante, 0)
		lbl_tiempo_restante.text = "Tiempo: " + str(tiempo_restante as int)
		
		if tiempo_restante == 0:
			emit_signal("tiempo_terminado")

func actualizar_vidas() -> void:
	var vidas := JugadorSeleccionado.get_vidas()

	#-- Eliminar corazones anteriores
	for hijo in contenedor_corazones.get_children():
		contenedor_corazones.remove_child(hijo)
		hijo.queue_free()
		
	#-- Añadir corazones nuevos
	for i in range(vidas):
		var corazon := TextureRect.new() #-- Crear un nuevo corazon
		corazon.texture = CORAZON_TEX
		corazon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		corazon.custom_minimum_size = Vector2(17, 17)
		contenedor_corazones.add_child(corazon)

func actualizar_puntos(p: int) -> void:
	lbl_puntos.text = "Puntos: %d" % p
