extends ActividadBase
class_name Minijuego6

@onready var sombra_cohete: TextureRect = $SombraChohete
@onready var zona_piezas: Node2D = $ZonaPiezas

var _total_piezas := 0
var _colocadas := 0

func _ready() -> void:
    super._ready()
    _total_piezas = 0
    # Conectar señales de todas las piezas dentro de ZonaPiezas
    for hijo in zona_piezas.get_children():
        if hijo is PiezaTangram:
            _total_piezas += 1
            hijo.pieza_puesta.connect(_on_pieza_puesta)
            hijo.pieza_retirada.connect(_on_pieza_retirada)

func _on_pieza_puesta(nombre_pieza: String) -> void:
    _colocadas += 1
    # print("Colocadas:", _colocadas, "/", _total_piezas)
    if _colocadas >= _total_piezas and _total_piezas > 0:
        # opcional: mostrar Cohete completo antes de finalizar
        # sombra_cohete.texture = load("res://Cohete.png")
        await get_tree().create_timer(0.5).timeout
        finalizar_exito()
        
func _on_pieza_retirada(nombre_pieza: String) -> void:
    _colocadas = max(0, _colocadas - 1)
    # print("Retirada:", nombre_pieza, " => colocadas:", _colocadas)
