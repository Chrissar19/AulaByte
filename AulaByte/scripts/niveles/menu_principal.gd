extends Control

# ───────────────────────────────────────────────────────────────
# Referencias UI
# ───────────────────────────────────────────────────────────────
@onready var btn_jugar: Button = $VBoxContainer/Jugar
@onready var btn_opciones: Button = $VBoxContainer/Opciones
@onready var btn_salir: Button = $VBoxContainer/Salir

# ───────────────────────────────────────────────────────────────
# Temporizadores
# ───────────────────────────────────────────────────────────────
@onready var temporizador_nubes: Timer = $temNubes
@onready var temporizador_espera: Timer = $temEspera

# ───────────────────────────────────────────────────────────────
# Recursos
# ───────────────────────────────────────────────────────────────
@onready var escena_nube: PackedScene = preload("res://escenas/menu/nubes.tscn")

# ───────────────────────────────────────────────────────────────
# Estado
# ───────────────────────────────────────────────────────────────
var jugador_activo: bool = false

# ───────────────────────────────────────────────────────────────
# Ready
# ───────────────────────────────────────────────────────────────
func _ready() -> void:
    randomize()
    
    # Conexiones
    temporizador_nubes.timeout.connect(_crear_nube_normal)
    temporizador_espera.timeout.connect(_on_tem_espera_timeout)
    
    _crear_nube_normal()
    _crear_nube_fondo()
    
    var musica_menu := preload("res://recursos/audio/Musica/neon-pulse-30s-307999.wav")
    if Engine.has_singleton("MusicaGlobal"):
        MusicaGlobal.reproducir(musica_menu, true)

# ───────────────────────────────────────────────────────────────
# Transición de escena
# ───────────────────────────────────────────────────────────────
func cambiar_escena(ruta: String) -> void:
    MusicaGlobal.detener()
    get_tree().change_scene_to_file(ruta)

# ───────────────────────────────────────────────────────────────
# Nubes decorativas
# ───────────────────────────────────────────────────────────────
func _crear_nube(z: int, alto_min: int, alto_max: int, tam_min: float, tam_max: float, vel_min: float, vel_max: float) -> void:
    var nube: Node2D = escena_nube.instantiate()
    var altura := randi_range(alto_min, alto_max)
    
    nube.position = Vector2(-450.0, altura)
    nube.velocidad = randf_range(vel_min, vel_max)
    nube.z_index = z
    nube.scale = Vector2(randf_range(tam_min, tam_max), randf_range(tam_min, tam_max))
    
    $Panel.add_child(nube)

func _crear_nube_normal() -> void:
    var z_index: int = [-1, 0, 1].pick_random()
    _crear_nube(z_index, 5, 120, 0.5, 1.5, 0.8, 40.0)

func _crear_nube_fondo() -> void:
    _crear_nube(-1, 4, 280, 0.2, 0.7, 0.15, 10.0)

# ───────────────────────────────────────────────────────────────
# Inactividad (volver a intro)
# ───────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
    if event.is_pressed():
        temporizador_espera.start()

func _on_tem_espera_timeout() -> void:
    if not jugador_activo:
        get_tree().change_scene_to_file("res://escenas/intro/Intro.tscn")


func _on_jugar_pressed() -> void:
    jugador_activo = true
    cambiar_escena("res://escenas/menu/Seleccion_personaje/seleccion_personaje.tscn")


func _on_opciones_pressed() -> void:
    jugador_activo = true
    print("Opción aún no implementada.")


func _on_salir_pressed() -> void:
    jugador_activo = true
    MusicaGlobal.detener()
    get_tree().quit()
