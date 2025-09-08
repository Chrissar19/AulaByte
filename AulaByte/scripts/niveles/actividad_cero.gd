extends ActividadBase

@onready var btn_salir: Button = $BtnSalir
@onready var btn_confirmar: Button = $BtnConfirmar
@onready var salida_texto: Label = $SalidaTexto


func _ready() -> void:
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	btn_confirmar.pressed.connect(_on_btn_confirmar_pressed)


func _on_btn_salir_pressed() -> void:
	emit_signal("resuelto", false)
	queue_free()


func _on_btn_confirmar_pressed() -> void:
	salida_texto.text = "Abriendo puerta"
	await get_tree().create_timer(1.0).timeout
	emit_signal("resuelto", true)
	queue_free()
