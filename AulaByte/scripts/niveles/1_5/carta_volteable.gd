extends TextureRect
class_name CartaVolteable

signal carta_volteada(carta: CartaVolteable)
signal carta_seleccionada(carta: CartaVolteable)

@export var textura_frente: Texture2D
@export var textura_reverso: Texture2D
@export var es_correcta: bool = false
@export var boca_arriba: bool = false
@export var duracion_mitad: float = 0.15  # tiempo de cada mitad del flip
@export var tiempo_cerrar_auto: float = 1.5

var _animando := false
var _seleccionado := false
var _timer_cerrar: SceneTreeTimer

func _ready() -> void:
    # Config UI
    mouse_filter = Control.MOUSE_FILTER_STOP
    stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    await get_tree().process_frame
    pivot_offset = size * 0.5
    _aplicar_textura_inicial()
    scale = Vector2.ONE
    _resaltar(false)
    

func _aplicar_textura_inicial() -> void:
    texture = (textura_frente if boca_arriba else textura_reverso)

func _gui_input(event: InputEvent) -> void:
    if _animando: return
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if not boca_arriba:
            _flip()
        else:
            _carta_seleccion()

func _flip() -> void:
    if _animando: return
    _animando = true
    var t := create_tween()
    t.tween_property(self, "scale:x", 0.0, duracion_mitad).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    t.tween_callback(func ():
        boca_arriba = !boca_arriba
        texture = (textura_frente if boca_arriba else textura_reverso)
    )
    t.tween_property(self, "scale:x", 1.0, duracion_mitad).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    t.tween_callback(func ():
        _animando = false
        emit_signal("carta_volteada", self)
        if boca_arriba and !_seleccionado:
            _autocerrar()
    )

func _autocerrar() -> void:
    if _timer_cerrar:
        _timer_cerrar = null
    _timer_cerrar = get_tree().create_timer(tiempo_cerrar_auto)
    _timer_cerrar.timeout.connect(func ():
        if boca_arriba and not _seleccionado:
            _cerrar()
            )
            
func _carta_seleccion() -> void:
    _seleccionado = not _seleccionado
    _resaltar(_seleccionado)
    if _seleccionado:
        emit_signal("carta_seleccionada", self)
    else:
        _autocerrar()
        
        
func _resaltar(activo: bool) -> void:
    modulate = (Color(0.7, 1.0, 0.7) if activo else Color(1, 1, 1))
    
    
func _cerrar() -> void:
    if not boca_arriba: return
    _seleccionado = false
    _resaltar(false)
    _flip()
    
    
func deseleccionar_y_cerrar() -> void:
    _seleccionado = false
    _resaltar(false)
    _cerrar()
    
    
func forzar_cierre() -> void:
    _seleccionado = false
    _resaltar(false)
    if boca_arriba:
        _flip()
