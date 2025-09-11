extends ActividadBase

@onready var btn_salir: Button = $pantalla/BtnSalir
@onready var btn_reiniciar: Button = $pantalla/BtnReiniciar
@onready var btn_confirmar: Button = $BtnConfirmar

func _ready() -> void:
	if btn_salir:
		btn_salir.pressed.connect(Callable(self, "_on_btn_salir_pressed"))

func _on_btn_salir_pressed() -> void:
	emit_signal("resuelto", false)
