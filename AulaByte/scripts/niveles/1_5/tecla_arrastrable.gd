extends TextureRect
class_name TeclaArrastrable

@export_enum("letras", "numeros", "simbolos") var categoria_correcta: String = "letras"
@onready var lbl_caracter: Label = $Caracter
@export var img_letras: Texture2D
@export var img_numeros: Texture2D
@export var img_simbolos: Texture2D

@export var conjunto_simbolos: PackedStringArray = [
	"!", "¡", "?", "¿", "\"", "'", "#", "$", "%", "&",
	"/", "(", ")", "=", "+", "-", "_", "*", "[", "]",
	"{", "}", ";", ":", ",", ".", "<", ">", "\\", "|",
	"^", "~", "`", "°"
]

signal retornar
var _posicion_inicial: Vector2
var _car_ramdon := RandomNumberGenerator.new()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_posicion_inicial = position
	_car_ramdon.randomize()
	
	asignar_caracter()  
	color_tecla() 

func asignar_caracter() -> void:
	match categoria_correcta:
		"numeros":
			_set_caracter(str(_car_ramdon.randi_range(0, 9)))
		"letras":
			_set_caracter(_letras_ramdon())
		"simbolos":
			if conjunto_simbolos.is_empty():
				_set_caracter("?")
			else:
				_set_caracter(conjunto_simbolos[_car_ramdon.randi_range(0, conjunto_simbolos.size() - 1)])
	
func _letras_ramdon() -> String:
	var letras: PackedStringArray = [
		"A","B","C","D","E","F","G","H","I","J","K","L","M",
		"N", "Ñ","O","P","Q","R","S","T","U","V","W","X","Y","Z"
	] 
	return letras[_car_ramdon.randi_range(0, letras.size() -1)] 

func _set_caracter(txt: String) -> void:
	if lbl_caracter:
		lbl_caracter.text = (txt.to_upper() if categoria_correcta == "letras" else txt)


func color_tecla() -> void:
	match categoria_correcta:
		"letras":
			texture = img_letras if img_letras else texture
		"numeros":
			texture = img_numeros if img_numeros else texture
		"simbolos":
			texture = img_simbolos if img_simbolos else texture
	
func _get_drag_data(at_position: Vector2) -> Variant:
	var data := {
		"type": "draggable_obj",
		"from": self,
		"categoria_correcta": categoria_correcta
	}
	var vista := duplicate() as TextureRect
	vista.modulate.a = 0.6
	set_drag_preview(vista)
	visible = false
	return data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not is_queued_for_deletion():
			volver_a_empezar()

func volver_a_empezar() -> void:
	visible = true
	position = _posicion_inicial
	emit_signal("retornar")
