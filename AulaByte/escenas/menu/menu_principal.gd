extends Control

@onready var btn_jugar: Button = $VBoxContainer/Jugar
@onready var btn_opciones: Button = $VBoxContainer/Opciones
@onready var btn_salir: Button = $VBoxContainer/Salir
@onready var tem_nubes: Timer = $temNubes

@onready var escena_nubes:= preload("res://escenas/menu/nubes.tscn")

func _ready() -> void:
	randomize()
	tem_nubes.timeout.connect(_crear_nube) #--Reproduce las nubes
	tem_nubes.timeout.connect(_crear_nube_fondo) #--Reproduce las nubes
	btn_jugar.pressed.connect(_on_jugar)
	btn_opciones.pressed.connect(_on_opciones)
	btn_salir.pressed.connect(_on_salir)
	btn_jugar.grab_focus()

func _on_jugar() -> void:
	get_tree().change_scene_to_file("res://escenas/menu/Seleccion_personaje/seleccion_personaje.tscn")
	
func _on_opciones() -> void:
	print("Opcion aún no implementada")
	
func _on_salir() -> void:
	get_tree().quit()
	
func _crear_nube() -> void:
	var nube: Node2D = escena_nubes.instantiate()
	var alto_min := 5
	var alto_max := 120
	var altura := randi_range(alto_min, alto_max)
	var posicion_x: float = -450.0
	nube.position = Vector2(posicion_x, altura) #-- Genera la nube completa fuera de pantalla
	nube.velocidad = randf_range(0.8, 40.0)
	#-- Profundidad aleatoria entre -1 y 1 para las nubes
	nube.z_index = [-1, 0, 1].pick_random()
	nube.scale = Vector2(randf_range(1.5,0.5), randf_range(1.7, 0.5))
	#--Se agrega la nube como hijo del fondo para mantener el orden
	$Panel.add_child(nube)
	
	
func _crear_nube_fondo() -> void:
	var nube_fondo: Node2D = escena_nubes.instantiate()
	var alto_fondo := 260
	var alto_min_fondo := 4
	var posicion_x: float = -450.0
	var altura_fondo := randi_range(alto_min_fondo, alto_fondo)
	nube_fondo.position = Vector2(posicion_x, altura_fondo)
	nube_fondo.velocidad = randf_range(0.15, 10.0)
	nube_fondo.z_index = -1
	nube_fondo.scale = Vector2(randf_range(0.7,0.2), randf_range(0.7, 0.2))
	$Panel.add_child(nube_fondo)
