extends Control

# ===========================
# Ajustes
# ===========================
signal resuelto(exito: bool)

const DIRECCIONES := [
	{"dir": "abajo", "icon": preload("res://recursos/imagenes/objetos/Flecha abajo.png")},
	{"dir": "arriba", "icon": preload("res://recursos/imagenes/objetos/Flecha arriba.png")},
	{"dir": "izquierda", "icon": preload("res://recursos/imagenes/objetos/Flecha izq.png")},
	{"dir": "derecha", "icon": preload("res://recursos/imagenes/objetos/Flecha dere.png")},
]

@onready var nodo_flechas := [
	$HBoxContainer/Flecha1,
	$HBoxContainer/Flecha2,
	$HBoxContainer/Flecha3,
	$HBoxContainer/Flecha4,
]

var clave_correcta: Array[String] = []
var clave_ingresada: Array[String] = [] #-- Lo que ingresa el jugador

func generar_clave() -> void:
	clave_correcta.clear()
	var random = DIRECCIONES.duplicate()
	random.shuffle()
	
	for i in range(4):
		nodo_flechas[i].texture = random[i]["icon"]
		clave_correcta.append(random[i]["dir"])
		

func _on_boton_direccion_pressed(direccion: String) -> void:
	clave_ingresada.append(direccion)
	if clave_ingresada.size() > 4:
		clave_ingresada.clear()
		

func _on_btn_confirmar_pressed() -> void:
	var exito = (clave_ingresada == clave_correcta)
	print("Clave correcta: ", clave_correcta)
	print("Clave ingresada: ", clave_ingresada)
	emit_signal("resuelto", exito)
	queue_free()


func _on_btn_arriba_pressed() -> void:
	_on_boton_direccion_pressed("arriba")


func _on_btn_izquierda_pressed() -> void:
	_on_boton_direccion_pressed("izquierda")


func _on_btn_abajo_pressed() -> void:
	_on_boton_direccion_pressed("abajo")


func _on_btn_derecha_pressed() -> void:
	_on_boton_direccion_pressed("derecha")
