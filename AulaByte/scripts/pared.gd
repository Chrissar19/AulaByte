extends CharacterBody2D

class_name Pared

# ============================================================================
# EXPORTS
# ============================================================================
@export var gravedad: float = 2000.0
@export var friccion: float = 0.1
@export var imagen_bloque: Texture2D
@export var alto_bloque: float = 32.0
@export var ancho_bloque: float = 32.0
@export var numero_bloques_vertical: int = 1
@export var numero_bloques_horizontal: int = 1

# ============================================================================
# ONREADY NODES
# ============================================================================
@onready var bloques: Area2D = $Bloques
@onready var timer_destroy: Timer = $TimerDestroy
@onready var particulas_pared: CPUParticles2D = $ParticulasPared
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var bloques_colicion: CollisionShape2D = $Bloques/BloquesColicion

# ============================================================================
# VARIABLES
# ============================================================================
var _generated_blocks: Array = []

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	build_wall()

# ============================================================================
# PROCESO FÍSICO
# ============================================================================
func _physics_process(delta: float) -> void:
	aplicar_gravedad(delta)
	aplicar_friccion()
	move_and_slide()

func aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0.0

func aplicar_friccion() -> void:
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, friccion)

# ============================================================================
# CONSTRUCCIÓN DE LA PARED
# ============================================================================
func build_wall() -> void:
	_clear_generated_blocks()
	_generated_blocks = []
	
	var total_width: float = numero_bloques_horizontal * ancho_bloque
	var total_height: float = numero_bloques_vertical * alto_bloque
	
	for y in range(numero_bloques_vertical):
		for x in range(numero_bloques_horizontal):
			var block_pos: Vector2 = Vector2(
				x * ancho_bloque,
				-(y * alto_bloque)
			)
			var block := Sprite2D.new()
			block.position = block_pos + Vector2(ancho_bloque * 0.5, -alto_bloque * 0.5)
			
			if imagen_bloque:
				block.texture = imagen_bloque
				var tex_size: Vector2 = imagen_bloque.get_size()
				if tex_size.x != 0 and tex_size.y != 0:
					block.scale = Vector2(ancho_bloque / tex_size.x, alto_bloque / tex_size.y)
				else:
					block.scale = Vector2.ONE
			else:
				var placeholder := ColorRect.new()
				placeholder.color = Color8(180, 80, 80)
				placeholder.size = Vector2(ancho_bloque, alto_bloque)
				placeholder.position = block_pos
				bloques.add_child(placeholder)
				_generated_blocks.append(placeholder)
				continue
			
			block.name = "bloque_%d_%d" % [x, y]
			bloques.add_child(block)
			_generated_blocks.append(block)
	
	_update_collision_shape(total_width, total_height)

func _update_collision_shape(total_width: float, total_height: float) -> void:
	var rect_shape := RectangleShape2D.new()
	rect_shape.extents = Vector2(total_width * 0.5, total_height * 0.5)
	
	if bloques_colicion:
		bloques_colicion.shape = rect_shape
		bloques_colicion.position = Vector2(total_width * 0.5, -total_height * 0.5)
	
	if collision_shape_2d:
		collision_shape_2d.shape = rect_shape
		collision_shape_2d.position = Vector2(total_width * 0.5, -total_height * 0.5)

func _clear_generated_blocks() -> void:
	for child in bloques.get_children():
		child.queue_free()
	_generated_blocks.clear()
	
func destroy() -> void:
	_clear_generated_blocks()
	
	if bloques_colicion:
		bloques_colicion.set_deferred("disabled", true)
	if collision_shape_2d:
		collision_shape_2d.set_deferred("disabled", true)
	
	if particulas_pared:
		particulas_pared.emitting = true
		
	if timer_destroy:
		timer_destroy.start()
		
func _on_timer_destroy_timeout() -> void:
	if bloques_colicion:
		bloques_colicion.shape = null
	if collision_shape_2d:
		collision_shape_2d.shape = null
	
	queue_free()
