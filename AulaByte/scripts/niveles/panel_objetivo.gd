extends Panel
class_name CarpetaDestino

@export_enum("hardware", "otros") var tipo_objetivo: String = "hardware"
@export var imagen: TextureRect
@export var img_abierta: Texture2D
@export var img_cerrada: Texture2D

var abierta: bool = false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    if imagen:
        imagen.texture = img_cerrada
        imagen.pivot_offset = imagen.size / 2.0
        imagen.scale = Vector2.ONE

func can_drop_data(at_position: Vector2, data: Variant) -> bool:
    # ---- Tipado explícito ----
    var dic: Dictionary = {} 
    if data is Dictionary:
        dic = data

    var ok: bool = dic.size() > 0 and dic.has("tipo") and dic.has("item")
    if not ok:
        _mostrar_carpeta(false, false)
        return false

    var tipo_data: String = String(dic.get("tipo", ""))
    var coincide: bool = (tipo_data == tipo_objetivo)

    _mostrar_carpeta(true, coincide)
    return true

func drop_data(_pos: Vector2, data: Variant) -> void:
    _cerrar_carpeta_luego()

    var dic: Dictionary = {}
    if data is Dictionary:
        dic = data

    if dic.size() == 0 or not dic.has("item") or not dic.has("tipo"):
        return

    # Si tienes class_name ItemArrastrable en tu script del ítem, úsalo:
    # var item: ItemArrastrable = dic.get("item", null) as ItemArrastrable
    # Si no, usa Control/Node como base:
    var item: Control = dic.get("item", null) as Control
    var tipo_data: String = String(dic.get("tipo", ""))

    var coincide: bool = (tipo_data == tipo_objetivo)
    if coincide:
        if item and item.has_method("procesar_correcto"):
            item.procesar_correcto(self)
    else:
        if item and item.has_method("procesar_incorrecto"):
            item.procesar_incorrecto()

func _mostrar_carpeta(hover: bool, coincide: bool) -> void:
    if not imagen:
        return

    if hover:
        imagen.texture = img_abierta
    else:
        imagen.texture = img_cerrada

    var col: Color = Color(1, 1, 1, 1)
    if hover:
        if coincide:
            col = Color(0.85, 1.0, 0.85)
        else:
            col = Color(1.0, 0.85, 0.85)
    self.modulate = col

    var objetivo: Vector2 = Vector2(1.0, 1.0)
    if hover:
        objetivo = Vector2(1.05, 1.05)

    var t := create_tween()
    t.tween_property(imagen, "scale", objetivo, 0.12)

func _cerrar_carpeta_luego() -> void:
    if not imagen:
        return

    var t := create_tween()
    t.tween_interval(0.15)
    t.tween_callback(func ():
        imagen.texture = img_cerrada
        self.modulate = Color(1, 1, 1, 1)
        var t2 := create_tween()
        t2.tween_property(imagen, "scale", Vector2(1, 1), 0.1)
    )
