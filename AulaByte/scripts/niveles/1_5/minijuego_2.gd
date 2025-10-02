extends Control

# Señal que espera el GameManager.solicitar_minijuego()
signal resuelto(exito: bool)

# Opcionales (si quieres usarlas en otras partes)
signal actividad_superada
signal actividad_fallida

@onready var lbl_ganar: Label = $UI/LblGanar
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var contenedor_objetos: Control = $ContenedorObjetos
@onready var contenedor_carpetas: Control = $ContenedorCarpetas

@export var intentos: int = 5

var _total_objetos: int = 0
var _objeto_correcto: int = 0

func _ready() -> void:
    lbl_ganar.visible = false
    _conectar_carpetas()
    _contar_objetos()
    _actualizar_intentos()

    # Este minijuego corre en modo pausado (GameManager lo activa así)
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _conectar_carpetas() -> void:
    for c in contenedor_carpetas.get_children():
        if c is Carpeta:
            c.soltar_item.connect(_soltar_item)

func _contar_objetos() -> void:
    _total_objetos = 0
    for c in contenedor_objetos.get_children():
        if c is ObjetoArrastrable:
            _total_objetos += 1

func _actualizar_intentos() -> void:
    lbl_intentos.text = "Intentos: %d" % intentos

func _soltar_item(correct: bool) -> void:
    if correct:
        _objeto_correcto += 1
        lbl_ganar.text = "¡Bien hecho!"
        lbl_ganar.visible = true
        if _objeto_correcto >= _total_objetos:
            _ganar()
    else:
        intentos -= 1
        lbl_ganar.text = "UPS"
        lbl_ganar.visible = true
        _actualizar_intentos()
        if intentos <= 0:
            _perder()

func _ganar() -> void:
    lbl_ganar.text = "¡Bien hecho! "
    lbl_ganar.visible = true

    # Señales opcionales locales
    actividad_superada.emit()

    # Señal que consume GameManager
    resuelto.emit(true)

    # (Opcional) bloquear más arrastres
    _bloquear_objetos_arrastrables()

func _perder() -> void:
    lbl_ganar.text = "Sin intentos."
    lbl_ganar.visible = true

    # Señales opcionales locales
    actividad_fallida.emit()

    # Señal que consume GameManager -> él resta vida y decide si vuelve a JUGANDO o GAME_OVER
    resuelto.emit(false)
    _bloquear_objetos_arrastrables()

func _bloquear_objetos_arrastrables() -> void:
    for c in contenedor_objetos.get_children():
        if c is ObjetoArrastrable and is_instance_valid(c):
            c.mouse_filter = Control.MOUSE_FILTER_IGNORE
