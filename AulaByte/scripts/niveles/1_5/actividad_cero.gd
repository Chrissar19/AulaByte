extends ActividadBase
class_name ActividadTuto

@onready var btn_salir: Button = $BtnSalir
@onready var btn_confirmar: Button = $BtnConfirmar
@onready var salida_texto: Label = $SalidaTexto

func _ready() -> void:
	# conectar botones
	if btn_salir:
		btn_salir.pressed.connect(Callable(self, "_on_btn_salir_pressed"))
	if btn_confirmar:
		btn_confirmar.pressed.connect(Callable(self, "_on_btn_confirmar_pressed"))

func _on_btn_salir_pressed() -> void:
	emit_signal("resuelto", false)

func _on_btn_confirmar_pressed() -> void:
	salida_texto.text = "Abriendo puerta"
	await get_tree().create_timer(1.0).timeout
	emit_signal("resuelto", true)
	
