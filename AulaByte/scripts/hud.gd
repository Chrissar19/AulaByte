extends CanvasLayer

@onready var lbl_puntos: Label = $HBoxPuntos/lblPuntos
@onready var lbl_tiempo: Label = $lblTiempo
@onready var lbl_vidas: Label = $HBoxVidas/lblVidas
@onready var lbl_tiempo_restante: Label = $HBoxTiempo/lblTiempoRestante
signal tiempo_terminado

var tiempo_total: float = 0.0
@export var tiempo_restante: float = 90.0 #-- Segundos

func _process(delta: float) -> void:
	#-- Actualizar el tiempo en cada frame
	tiempo_total += delta
	
	if tiempo_restante > 0:
		tiempo_restante -= delta
		tiempo_restante = max(tiempo_restante, 0)
		lbl_tiempo_restante.text = "Tiempo: " + str(tiempo_restante as int)
		
		if tiempo_restante == 0:
			emit_signal("tiempo_terminado")
	
	
func actualizar_vidas(n: int) -> void:
	# lbl_vidas.text = "Vidas: %d" % n
	for i in range(3):
		var corazon := $"HBoxVidas".get_child(i)
		corazon.visible = i < n
	
func actualizar_puntos(p: int) -> void:
	lbl_puntos.text = "Puntos: %d" % p
