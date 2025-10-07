extends ActividadBase
class_name Minijuego4

@onready var zona_cartas: Control = $Fondo/ZonaCartas
@onready var btn_aceptar: Button = $UI/BtnAceptar

var _seleccion: CartaVolteable = null
var _cartas: Array[CartaVolteable] = []

func _ready() -> void:
    super._ready()
    _reunir_cartas()

    btn_aceptar.disabled = true
    if not btn_aceptar.pressed.is_connected(_on_btn_aceptar_pressed):
        btn_aceptar.pressed.connect(_on_btn_aceptar_pressed)


func _reunir_cartas() -> void:
    _cartas.clear()
    for n in zona_cartas.get_children():
        if n is CartaVolteable:
            var c := n as CartaVolteable
            _cartas.append(c)
            if not c.carta_volteada.is_connected(_on_carta_volteada):
                c.carta_volteada.connect(_on_carta_volteada)
            if not c.carta_seleccionada.is_connected(_on_carta_seleccionada):
                c.carta_seleccionada.connect(_on_carta_seleccionada)


func _on_carta_volteada(carta: CartaVolteable) -> void:
    # Cierra las demás
    for c in _cartas:
        if c != carta:
            c.forzar_cierre()

func _on_carta_seleccionada(carta: CartaVolteable) -> void:
    # Solo una seleccionada
    for c in _cartas:
        if c != carta:
            c.deseleccionar_y_cerrar()
    _seleccion = carta
    btn_aceptar.disabled = false

func _on_btn_aceptar_pressed() -> void:
    if _seleccion == null: return
    if _seleccion.es_correcta:
        finalizar_exito()
    else:
        finalizar_fracaso()
