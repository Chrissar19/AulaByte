extends Panel
class_name CarpetaDestino

@export_enum("hardware", "otros") var tipo_objetivo: String = "hardware"
@export var imagen: TextureRect
@export var img_abierta: Texture2D
@export var img_cerrada: Texture2D
@export var actividad: NodePath

var _act: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	if imagen:
		imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		imagen.texture = img_cerrada
		imagen.pivot_offset = imagen.size / 2.0
		imagen.scale = Vector2.ONE

	# <<< SIN TERNARIOS >>>
	if actividad != NodePath():
		_act = get_node(actividad)
	else:
		_act = _buscar_actividad_en_ancestros()

func _buscar_actividad_en_ancestros() -> Node:
	var n := get_parent()
	while n:
		if n.has_method("resultado_drop"):
			return n
		n = n.get_parent()
	return null

func can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var dic := (data as Dictionary) if data is Dictionary else {}
	var ok := dic.size() > 0 and dic.has("tipo") and dic.has("item")
	if not ok:
		_mostrar_carpeta(false, false)
		return false

	var coincide := String(dic.get("tipo", "")) == tipo_objetivo
	_mostrar_carpeta(true, coincide)
	return true

func drop_data(_pos: Vector2, data: Variant) -> void:
	_cerrar_carpeta_luego()

	var dic := (data as Dictionary) if data is Dictionary else {}
	if dic.size() == 0 or not dic.has("item") or not dic.has("tipo"):
		return

	var item: Control = dic.get("item", null) as Control
	var coincide := String(dic.get("tipo", "")) == tipo_objetivo

	if _act == null:
		_act = _buscar_actividad_en_ancestros()

	if _act and _act.has_method("resultado_drop"):
		_act.resultado_drop(item, coincide, self)
	else:
		if item and item.has_method("procesar_incorrecto"):
			item.procesar_incorrecto()

func _mostrar_carpeta(hover: bool, coincide: bool) -> void:
	if imagen:
		if hover:
			imagen.texture = img_abierta
		else:
			imagen.texture = img_cerrada

	var col := Color(1, 1, 1, 1)
	if hover:
		if coincide:
			col = Color(0.85, 1.0, 0.85)
		else:
			col = Color(1.0, 0.85, 0.85)
	self.modulate = col

	if imagen:
		var objetivo := Vector2(1, 1)
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
