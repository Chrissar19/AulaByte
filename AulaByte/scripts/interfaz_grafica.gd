extends CanvasLayer

@onready var lb_bits: Label = $lbBits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	var game_manager = get_node("%GameManager")
	game_manager.puntuacion_actualizada.connect(_on_puntuacion_actualizada)

func _on_puntuacion_actualizada(puntuacion_actual: int) -> void:
	lb_bits.text = str(puntuacion_actual)
