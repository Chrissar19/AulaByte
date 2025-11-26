extends Control
class_name DropCatcher

@export var actividad: NodePath  # asigna el nodo que tiene resultado_drop()

var _act: Node = null
var _carpetas: Array = []
var _carpeta_hover: Node = null

func _ready() -> void:
    # Este nodo debe capturar el mouse para recibir DnD SIEMPRE
    mouse_filter = Control.MOUSE_FILTER_STOP

    # Resolver actividad
    if actividad != NodePath():
        _act = get_node(actividad)
    else:
        _act = _buscar_actividad_en_ancestros()

    # Cachear carpetas del grupo
    _refrescar_carpetas()

func _buscar_actividad_en_ancestros() -> Node:
    var n := get_parent()
    while n:
        if n.has_method("resultado_drop"):
            return n
        n = n.get_parent()
    return null

func _refrescar_carpetas() -> void:
    _carpetas = []
    var nodes := get_tree().get_nodes_in_group("CarpetaDestino")
    for c in nodes:
        # Solo las visibles y con Rect válido
        if c is Control and c.is_visible_in_tree():
            _carpetas.append(c)

func _carpeta_bajo_cursor(p: Vector2) -> Node:
    # Busca la carpeta cuya rect global contiene el punto del cursor (de adelante hacia atrás)
    # Si tus carpetas pueden solaparse, opcionalmente ordena por Z/orden en árbol.
    for i in range(_carpetas.size() - 1, -1, -1):
        var c: Control = _carpetas[i]
        if not c.is_visible_in_tree():
            continue
        var r := c.get_global_rect()
        if r.has_point(p):
            return c
    return null

func can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    var dic := (data as Dictionary) if data is Dictionary else {}
    var ok := dic.size() > 0 and dic.has("tipo") and dic.has("item")
    if not ok:
        _mostrar_hover(null, false)
        return false

    # Determinar carpeta bajo cursor
    var mp := get_global_mouse_position()
    var carpeta := _carpeta_bajo_cursor(mp)
    if carpeta == null:
        _mostrar_hover(null, false)
        return true  # Permitimos el drop en catcher (pero no hará nada si no hay carpeta)
    
    var coincide := false
    if carpeta.has_method("get_tipo_objetivo"):
        var t := String(dic.get("tipo", ""))
        var objetivo := String(carpeta.get_tipo_objetivo())
        coincide = (t == objetivo)

    _mostrar_hover(carpeta, coincide)
    return true

func drop_data(_pos: Vector2, data: Variant) -> void:
    # Recalcular por si el mouse se movió
    var dic := (data as Dictionary) if data is Dictionary else {}
    var item: Control = dic.get("item", null) as Control
    var tipo := String(dic.get("tipo", ""))

    var mp := get_global_mouse_position()
    var carpeta := _carpeta_bajo_cursor(mp)

    # Limpiar hover visual
    _mostrar_hover(null, false)

    if carpeta == null or _act == null or not _act.has_method("resultado_drop"):
        # Sin carpeta: item vuelve al origen o usa su feedback incorrecto
        if item and item.has_method("procesar_incorrecto"):
            item.procesar_incorrecto()
        elif item and item.has_method("volver_al_origen"):
            item.volver_al_origen()
        return

    var coincide := false
    if carpeta.has_method("get_tipo_objetivo"):
        var objetivo := String(carpeta.get_tipo_objetivo())
        coincide = (tipo == objetivo)

    _act.resultado_drop(item, coincide, carpeta)

func _mostrar_hover(carpeta: Node, coincide: bool) -> void:
    # Apaga hover anterior
    if _carpeta_hover and _carpeta_hover.is_inside_tree() and _carpeta_hover.has_method("mostrar_carpeta"):
        _carpeta_hover.mostrar_carpeta(false, false)
    _carpeta_hover = carpeta

    # Enciende hover actual
    if carpeta and carpeta.has_method("mostrar_carpeta"):
        carpeta.mostrar_carpeta(true, coincide)
