extends Control
class_name MenuPrincipal

# ───────────────────────────────────────────────────────────────
# Constantes de rutas
# ───────────────────────────────────────────────────────────────
const RUTA_INTRO            := "res://escenas/intro/Intro.tscn"
const RUTA_SELECCION        := "res://escenas/menu/Seleccion_personaje/seleccion_personaje.tscn"
const RUTA_OPCIONES         := "res://escenas/menu/opciones_menu.tscn"
const RUTA_NUBE_SCN         := "res://escenas/menu/nubes.tscn"
const RUTA_MUSICA_MENU      := "res://recursos/Audio/musica/neon-pulse-30s-307999.wav"

# ───────────────────────────────────────────────────────────────
# Nodos
# ───────────────────────────────────────────────────────────────
@onready var fondo: Control = $Fondo
@onready var btn_jugar: Button = $VBoxContainer/BtnJugar
@onready var btn_opciones: Button = $VBoxContainer/BtnOpciones
@onready var btn_salir: Button = $VBoxContainer/BtnSalir
@onready var lbl_version: Label = $LblVersion

@onready var temporizador_nubes: Timer = $temNubes
@onready var temporizador_espera: Timer = $temEspera

# ───────────────────────────────────────────────────────────────
# Recursos
# ───────────────────────────────────────────────────────────────
var escena_nube: PackedScene = preload(RUTA_NUBE_SCN)
var musica_menu: AudioStream = preload(RUTA_MUSICA_MENU)

# ───────────────────────────────────────────────────────────────
# Estado
# ───────────────────────────────────────────────────────────────
var jugador_activo := false
var rng := RandomNumberGenerator.new()

# ───────────────────────────────────────────────────────────────
# Ready
# ───────────────────────────────────────────────────────────────
func _ready() -> void:
    rng.randomize()

    # Música (via autoload "Musica" recomendado)
    if has_node("/root/Musica"):
        get_node("/root/Musica").call("reproducir", musica_menu, true)

    # Etiqueta versión (opcional)
    if lbl_version:
        lbl_version.text = ProjectSettings.get_setting("application/config/version", "v0.1") as String

    # Foco y navegación por teclado
    btn_jugar.grab_focus()
    btn_jugar.focus_neighbor_bottom = btn_opciones.get_path()
    btn_opciones.focus_neighbor_top = btn_jugar.get_path()
    btn_opciones.focus_neighbor_bottom = btn_salir.get_path()
    btn_salir.focus_neighbor_top = btn_opciones.get_path()

    # Timers
    temporizador_espera.timeout.connect(_on_tem_espera_timeout)
    temporizador_nubes.timeout.connect(_on_tem_nubes_timeout)

    # Arranques
    temporizador_espera.start()        # inactividad → intro
    temporizador_nubes.start()         # spawn de nubes

    # Semilla decorativa inicial
    _crear_nube_normal()
    _crear_nube_fondo()

# Resetea inactividad al detectar interacción
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouse or event is InputEventKey or event is InputEventJoypadButton:
        jugador_activo = true
        temporizador_espera.start()  # reinicia el conteo de inactividad

# ───────────────────────────────────────────────────────────────
# Nubes decorativas (pooling simple)
# ───────────────────────────────────────────────────────────────
func _crear_nube(z: int, alto_min: int, alto_max: int, tam_min: float, tam_max: float, vel_min: float, vel_max: float) -> void:
    var nube: Nube = escena_nube.instantiate()
    var altura := rng.randi_range(alto_min, alto_max)
    nube.position = Vector2(-50.0, altura)
    nube.velocidad = rng.randf_range(vel_min, vel_max)
    nube.z_index = z
    var s := rng.randf_range(tam_min, tam_max)
    nube.scale = Vector2(s, s)
    fondo.add_child(nube)

func _crear_nube_normal() -> void:
    var z_nube: int = [-1, 0, 1][rng.randi_range(0, 2)]
    _crear_nube(z_nube, 5, 120, 0.5, 1.5, 0.8, 40.0)

func _crear_nube_fondo() -> void:
    _crear_nube(-1, 4, 280, 0.2, 0.7, 0.15, 10.0)

func _on_tem_nubes_timeout() -> void:
    # Ritmo: alterna entre nube foreground y fondo
    if rng.randf() < 0.6:
        _crear_nube_normal()
    else:
        _crear_nube_fondo()

# ───────────────────────────────────────────────────────────────
# Inactividad → Intro
# ───────────────────────────────────────────────────────────────
func _on_tem_espera_timeout() -> void:
    if not jugador_activo:
        get_tree().change_scene_to_file(RUTA_INTRO)
    else:
        jugador_activo = false
        temporizador_espera.start()

# ───────────────────────────────────────────────────────────────
# Botones
# ───────────────────────────────────────────────────────────────
func _on_salir_pressed() -> void:
    if has_node("/root/Musica"):
        get_node("/root/Musica").call("detener")
    get_tree().quit()

func _on_opciones_pressed() -> void:
    if ResourceLoader.exists(RUTA_OPCIONES):
        get_tree().change_scene_to_file(RUTA_OPCIONES)
    else:
        push_warning("Escena de opciones no implementada aún.")

func _on_jugar_pressed() -> void:
    if temporizador_espera:
        temporizador_espera.stop()

    GameManager.cambiar_estado(GameManager.EstadoJuego.SELECCION_PERSONAJE)

    get_tree().change_scene_to_file(RUTA_SELECCION)
