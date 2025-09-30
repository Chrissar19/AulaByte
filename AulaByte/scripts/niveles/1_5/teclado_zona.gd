extends Control
class_name tecladoZona

signal soltar_item(verdadero: bool)

@export var mascara_textura: Texture2D
@export var teclado_textura: Texture2D

# Colores "clave" que usas en la máscara (ajusta si tus PNG difieren)
@export var color_letras: Color = Color(0, 1, 0, 1)     # verde
@export var color_numeros: Color = Color(1, 1, 0, 1)    # amarillo
@export var color_simbolos: Color = Color(0, 0.4, 1, 1) # azul

# Tolerancia para comparar colores (por si hay compresión o anti-alias)
const EPS := 0.08

var _mascara_imagen: Image
var _teclado: TextureRect

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS

    if teclado_textura:
        _teclado = TextureRect.new()
        _teclado.texture = teclado_textura
        _teclado.stretch_mode = TextureRect.STRETCH_SCALE
        _teclado.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _teclado.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(_teclado)

    # Cargamos la imagen de la máscara (debe ser un Texture2D no-streaming)
    if mascara_textura:
        _mascara_imagen = mascara_textura.get_image()

# ---- Drag & Drop ----
func can_drop_data(at_position: Vector2, data: Variant) -> bool:
    return typeof(data) == TYPE_DICTIONARY \
        and data.has("type") and data["type"] == "draggable_obj" \
        and data.has("from") and data.has("correct_category")

func drop_data(at_position: Vector2, data: Variant) -> void:
    var obj: Node = data["from"] as Node
    var cat: String = _categoria_en_pos(at_position)
    var verdadero: bool = (cat != "" and data["correct_category"] == cat)

    if verdadero:
        # soltar definitivo: por ejemplo eliminar la tecla
        if obj and obj.is_inside_tree():
            obj.queue_free()
    else:
        # devolver a origen si el arrastrable lo implementa
        if obj and obj.has_method("return_to_start"):
            obj.call("return_to_start")

    soltar_item.emit(verdadero)

# ---- Utilidades ----
func _categoria_en_pos(local_pos: Vector2) -> String:
    # Si no hay máscara, no podemos categorizar
    if _mascara_imagen == null:
        return ""

    # Convertimos la posición local (en el Control) a coordenadas de la imagen de la máscara
    # Suponiendo que el TextureRect está a tamaño completo (FULL_RECT) y STRETCH_SCALE:
    var size: Vector2 = get_size()
    if size.x <= 0.0 or size.y <= 0.0:
        return ""

    var uv := Vector2(
        clamp(local_pos.x / size.x, 0.0, 1.0),
        clamp(local_pos.y / size.y, 0.0, 1.0)
    )

    var px := int(round(uv.x * float(_mascara_imagen.get_width() - 1)))
    var py := int(round(uv.y * float(_mascara_imagen.get_height() - 1)))
    var c: Color = _mascara_imagen.get_pixel(px, py)

    if _color_casi_igual(c, color_letras):
        return "letters"
    if _color_casi_igual(c, color_numeros):
        return "numbers"
    if _color_casi_igual(c, color_simbolos):
        return "symbols"

    return ""

func _color_casi_igual(a: Color, b: Color) -> bool:
    return abs(a.r - b.r) <= EPS and abs(a.g - b.g) <= EPS and abs(a.b - b.b) <= EPS
