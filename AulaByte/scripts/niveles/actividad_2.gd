extends ActividadBase

@export var intentos_max := 3

@onready var btn_salir: Button = $pantalla/BtnSalir
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var lbl_feedback: Label = $UI/LblFeedback
@onready var descripcion: Label = $UI/descripcion
@onready var cont_items: Control = $pantalla/objetos

var intentos := 0
var total_items := 0
var clasificados := 0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    intentos = intentos_max
    _actualizar_ui()
    
    if btn_salir:
        btn_salir.pressed.connect(Callable(self, "_on_btn_salir_pressed"))
    total_items = 0
    if cont_items:
        for child in cont_items.get_children():
            if child.is_in_group("ItemArrastrable"):
                total_items += 1
    _set_feedback("Arrastra cada objeto a la carpeta correcta")
        
func _on_btn_salir_pressed() -> void:
    emit_signal("resuelto", false)
    

func resultado_drop(item: Control, correcto: bool, carpeta: Control) -> void:
    if correcto:
        clasificados += 1
        _set_feedback("¡Bien hecho!")
        _anim_consumir_item(item, carpeta)
    else:
        intentos -= 1
        _actualizar_ui()
        _set_feedback("Incorrecto. Intenta de nuevo.")
        if item.has_method("volver_al_origen"):
            item.volver_al_origen()

    # fin por éxito
    if clasificados >= total_items and total_items > 0:
        _set_feedback("¡Base de datos clasificada! Abriendo puerta…")
        await get_tree().create_timer(1.0).timeout
        emit_signal("resuelto", true)
        queue_free()
        return

    # fin por derrota
    if intentos <= 0:
        _set_feedback("Sin intentos. Inténtalo de nuevo.")
        await get_tree().create_timer(1.0).timeout
        emit_signal("resuelto", false)
        queue_free()

func _anim_consumir_item(item: Control, carpeta: Control) -> void:
    var destino := carpeta.global_position
    var tw := create_tween()
    tw.tween_property(item, "global_position", destino, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tw.parallel().tween_property(item, "scale", Vector2(0.8, 0.8), 0.18)
    await tw.finished
    if is_instance_valid(item):
        item.queue_free()

func _actualizar_ui() -> void:
    if lbl_intentos:
        lbl_intentos.text = "Intentos: %d" % intentos

func _set_feedback(msg: String) -> void:
    if lbl_feedback:
        lbl_feedback.text = msg
