extends Area2D

signal activado(id: String, ref: Node)

@export_enum("A", "B", "C", "D", "E", "F", "G") var id: String = "A"
@export_enum("azul", "amarilla", "roja", "morada", "verde") var color_inter: String = "verde"
@export var activo: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var t_feedback: Timer = $Timer

var jugador_en_rango: bool = false

#-----------------------------------------------------------------------------------
func _ready() -> void:
    add_to_group("Interruptores")
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    monitoring = true
    if collision_shape_2d:
        collision_shape_2d.disabled = false
    asignar_color()
    if anim.sprite_frames.has_animation("desactivado"):
        anim.play("desactivado")
    activo = false 
    
    t_feedback.one_shot = true
    add_child(t_feedback)
    t_feedback.timeout.connect(_on_timer_timeout)

#-----------------------------------------------------------------------------------
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("Jugador"):
        jugador_en_rango = true

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("Jugador"):
        jugador_en_rango = false

#-----------------------------------------------------------------------------------
func _process(_delta: float) -> void:
    if not activo and jugador_en_rango and Input.is_action_just_pressed("Accion"):
        emit_signal("activado", id, self)

#-----------------------------------------------------------------------------------
func asignar_color() -> void:
    match color_inter:
        "azul":     anim.modulate = Color(0, 0, 1)
        "amarilla": anim.modulate = Color(1, 1, 0)
        "morada":   anim.modulate = Color(0.5, 0, 0.5)
        "roja":     anim.modulate = Color(1, 0, 0)
        "verde":    anim.modulate = Color(0.5, 1, 0.5)

#-----------------------------------------------------------------------------------
func activar_visual() -> void:
    # Reproduce la animación solo una vez
    if anim.sprite_frames.has_animation("activado"):
        anim.play("activado")
    activo = true
    
func desactivar_visual() -> void:
    if anim.sprite_frames.has_animation("desactivado"):
        anim.play("desactivado")
    activo = false
    
    
func presionar_temporal(seg: float = 3.0) -> void:
    if anim.sprite_frames.has_animation("activado"):
        anim.play("activado")
    if t_feedback.time_left > 0.0:
        t_feedback.stop()
    t_feedback.start(seg)


func _on_timer_timeout() -> void:
    if not activo and anim.sprite_frames.has_animation("desactivado"):
        anim.play("desactivado")
