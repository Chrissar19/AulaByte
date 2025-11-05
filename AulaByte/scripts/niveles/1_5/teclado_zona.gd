extends Control
class_name TecladoZona

signal soltar_item(correcto: bool)

@export var mascara_textura: Texture2D
@export var teclado_textura: Texture2D

# Ajusta a los colores reales de tu máscara
@export var color_letras: Color   = Color(0.016, 0.973, 0.459, 1.0)  # verde
@export var color_numeros: Color  = Color(1.0,   0.725, 0.078, 1.0)  # naranja
@export var color_simbolos: Color = Color(0.031, 0.329, 0.941, 1.0)  # azul

var _mascara_imagen: Image
var _teclado: TextureRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

	if mascara_textura:
		_mascara_imagen = mascara_textura.get_image()

	if teclado_textura:
		_teclado = TextureRect.new()
		_teclado.texture = teclado_textura
		_teclado.stretch_mode = TextureRect.STRETCH_SCALE
		_teclado.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_teclado.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(_teclado)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return (data is Dictionary) \
		and data.has("type") and data["type"] == "draggable_obj" \
		and data.has("from") and data.has("categoria_correcta")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var obj: Node = data["from"] as Node
	var cat: String = _categoria_en_pos(at_position)
	var correcto: bool = (cat != "" and data["categoria_correcta"] == cat)

	if correcto:
		obj.queue_free()
	else:
		if obj.has_method("volver_a_empezar"):
			obj.volver_a_empezar()

	soltar_item.emit(correcto)

# ---- Utilidades ----
func _categoria_en_pos(local_pos: Vector2) -> String:
	if _mascara_imagen == null:
		return ""

	var w := float(_mascara_imagen.get_width())
	var h := float(_mascara_imagen.get_height())
	if size.x <= 0.0 or size.y <= 0.0:
		return ""

	var uv := Vector2(
		clamp(local_pos.x / size.x, 0.0, 1.0),
		clamp(local_pos.y / size.y, 0.0, 1.0)
	)
	var px := int(uv.x * (w - 1.0))
	var py := int(uv.y * (h - 1.0))
	var c := _mascara_imagen.get_pixel(px, py)

	if _color_casi_igual(c, color_letras):   return "letras"
	if _color_casi_igual(c, color_numeros):  return "numeros"
	if _color_casi_igual(c, color_simbolos): return "simbolos"
	return ""

func _color_casi_igual(a: Color, b: Color) -> bool:
	return abs(a.r - b.r) < 0.08 and abs(a.g - b.g) < 0.08 and abs(a.b - b.b) < 0.08
