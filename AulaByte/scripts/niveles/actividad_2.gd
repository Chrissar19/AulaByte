# Nivel2Actividad.gd
extends ActividadBase

@export var intentos_max := 5  # 5 intentos permitidos; pierdes al 6.º fallo

@onready var descripcion: Label = $descripcion
@onready var lbl_intentos: Label = $LblIntentos
@onready var lbl_feedback: Label = $LblFeedback
@onready var btn_salir: Button = $BtnSalir
@onready var objetos: Control = $objetos

var fallos := 0
var total_items := 0
var clasificados := 0

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED

    # Cuenta los ítems arrastrables
    total_items = 0
    if objetos:
        for child in objetos.get_children():
            if child.is_in_group("ItemArrastrable"):
                total_items += 1

    # Botón salir
    if btn_salir:
        btn_salir.pressed.connect(_on_btn_salir_pressed)

    _actualizar_ui()
    _set_feedback("Arrastra cada objeto a la carpeta correcta")
        
func _on_btn_salir_pressed() -> void:
    emit_signal("resuelto", false)

# <<<--- ESTE ES EL MÉTODO QUE LLAMAN LAS CARPETAS --->>>
func resultado_drop(item: Control, correcto: bool, carpeta: Control) -> void:
    if correcto:
        clasificados += 1
        _set_feedback("¡Bien hecho!")
        # Evita que el NOTIFICATION_DRAG_END lo haga volver
        if "Arrastre_exitoso" in item:
            item.Arrastre_exitoso = true
        _anim_consumir_item(item, carpeta)
    else:
        fallos += 1
        _actualizar_ui()
        _set_feedback("Incorrecto. Intenta de nuevo.")
        if item.has_method("procesar_incorrecto"):
            item.procesar_incorrecto()
        elif item.has_method("volver_al_origen"):
            item.volver_al_origen()

    # Fin por éxito
    if clasificados >= total_items and total_items > 0:
        _set_feedback("¡Base de datos clasificada! Abriendo puerta…")
        await get_tree().create_timer(1.0).timeout
        emit_signal("resuelto", true)
        queue_free()
        return

    # Fin por derrota (pierde al 6.º fallo)
    if fallos > intentos_max:
        _set_feedback("Sin intentos. Inténtalo de nuevo.")
        await get_tree().create_timer(1.0).timeout
        emit_signal("resuelto", false)
        queue_free()

func _anim_consumir_item(item: Control, carpeta: Control) -> void:
    # Se acerca a la carpeta y se reduce
    var destino := carpeta.global_position
    var tw := create_tween()
    tw.tween_property(item, "global_position", destino, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tw.parallel().tween_property(item, "scale", Vector2(0.8, 0.8), 0.18)
    await tw.finished
    if is_instance_valid(item):
        item.queue_free()

func _actualizar_ui() -> void:
    # Muestra intentos restantes visuales (llegan a 0, pero aún queda 1 fallo más “oculto”)
    var restantes: int = max(0, intentos_max - fallos)
    if lbl_intentos:
        lbl_intentos.text = "Intentos: %d" % restantes

func _set_feedback(msg: String) -> void:
    if lbl_feedback:
        lbl_feedback.text = msg
