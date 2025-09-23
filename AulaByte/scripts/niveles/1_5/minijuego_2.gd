extends Control

# Señal que espera el GameManager.solicitar_minijuego()
signal resuelto(exito: bool)

# Opcionales (si quieres usarlas en otras partes)
signal actividad_superada
signal actividad_fallida

@onready var attempts_label: Label = $UI/AttemptsLabel
@onready var win_label: Label = $UI/WinLabel
@onready var objects_container: Control = $Objects
@onready var folders_root: Node = $Folders

@export var intentos: int = 5

var _objects_total: int = 0
var _objects_correct: int = 0

func _ready() -> void:
    win_label.visible = false
    _connect_folders()
    _count_objects()
    _update_attempts()

    # Este minijuego corre en modo pausado (GameManager lo activa así)
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _connect_folders() -> void:
    for c in folders_root.get_children():
        if c is Folder:
            c.item_dropped.connect(_on_item_dropped)

func _count_objects() -> void:
    _objects_total = 0
    for c in objects_container.get_children():
        if c is DraggableObject:
            _objects_total += 1

func _update_attempts() -> void:
    attempts_label.text = "Intentos: %d" % intentos

func _on_item_dropped(correct: bool) -> void:
    if correct:
        _objects_correct += 1
        if _objects_correct >= _objects_total:
            _on_win()
    else:
        intentos -= 1
        _update_attempts()
        if intentos <= 0:
            _on_fail()

func _on_win() -> void:
    win_label.text = "¡Bien hecho! "
    win_label.visible = true

    # Señales opcionales locales
    actividad_superada.emit()

    # Señal que consume GameManager
    resuelto.emit(true)

    # (Opcional) bloquear más arrastres
    _disable_remaining_draggables()

func _on_fail() -> void:
    win_label.text = "Sin intentos."
    win_label.visible = true

    # Señales opcionales locales
    actividad_fallida.emit()

    # Señal que consume GameManager -> él resta vida y decide si vuelve a JUGANDO o GAME_OVER
    resuelto.emit(false)
    _disable_remaining_draggables()

func _disable_remaining_draggables() -> void:
    for c in objects_container.get_children():
        if c is DraggableObject and is_instance_valid(c):
            c.mouse_filter = Control.MOUSE_FILTER_IGNORE
