extends AnimatableBody2D
class_name PlataformaUniversal

@export_group("Visual")
@export_enum("default","verde", "roja", "amarilla", "morada", "azul", "naranja", "rosa") var color_plataforma: String = "default"

@export_group("Movimiento")
@export var distancia: Vector2 = Vector2(0, -200)
@export var duracion: float = 3.0
@export var tiempo_espera: float = 1.0

@export_group("Lógica de Activación")
@export var auto_iniciar: bool = true 
@export var ids_requeridos: Array[String] = ["A"] 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var pos_inicio: Vector2
var pos_final: Vector2
var activa: bool = false
var interruptores_completados: Dictionary = {}

func _ready() -> void:
	z_index = ZCapas.PLATAFORMAS
	add_to_group("Z_PLATAFORMAS")
	sync_to_physics = true
	
	if anim and anim.sprite_frames.has_animation(color_plataforma):
		anim.play(color_plataforma)
	
	pos_inicio = global_position
	pos_final = global_position + distancia
	
	for id_req in ids_requeridos:
		interruptores_completados[id_req] = false
		
	await get_tree().process_frame
	
	var todos_los_inter = get_tree().get_nodes_in_group("Interruptores")
	for inter in todos_los_inter:
		if inter is Interruptor:
			if inter.id in ids_requeridos:
				inter.activado.connect(_al_recibir_activacion)
				inter.desactivado.connect(_al_recibir_desactivacion) # Nueva conexión
	
	if auto_iniciar:
		activa = true
		iniciar_ciclo()

func _al_recibir_activacion(id_emisor: String, _ref: Node) -> void:
	if id_emisor in interruptores_completados:
		interruptores_completados[id_emisor] = true
	
	chequear_combinacion()

func _al_recibir_desactivacion(id_emisor: String) -> void:
	# Si la plataforma ya arrancó, ignoramos que el interruptor se apague
	if activa: return 
	
	# Si no ha arrancado, "olvidamos" este interruptor
	if id_emisor in interruptores_completados:
		interruptores_completados[id_emisor] = false

func chequear_combinacion() -> void:
	var todo_listo = true
	for id_req in interruptores_completados:
		if not interruptores_completados[id_req]:
			todo_listo = false
			break

	if todo_listo and not activa:
		activa = true
		iluminar_interruptores_vinculados()
		iniciar_ciclo()
		
func iluminar_interruptores_vinculados() -> void:
	# Buscamos en el grupo de interruptores
	var todos = get_tree().get_nodes_in_group("Interruptores")
	for inter in todos:
		if inter is Interruptor and inter.id in ids_requeridos:
			# Si el interruptor pertenece a esta plataforma, lo iluminamos
			inter.fijar_activado()

func iniciar_ciclo() -> void:
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", pos_final, duracion)
	tween.tween_interval(tiempo_espera)
	tween.tween_property(self, "global_position", pos_inicio, duracion)
	tween.tween_interval(tiempo_espera)
