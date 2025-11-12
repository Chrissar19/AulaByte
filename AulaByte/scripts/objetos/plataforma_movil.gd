extends AnimatableBody2D

@export_enum("normal", "amarilla", "roja", "morada", "verde") var plataf: String = "normal"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    asignar_plataforma()

func _process(delta: float) -> void:
    var nodo_padre := get_parent()
    if nodo_padre is Node2D:
        global_position = nodo_padre.global_position
        
        
func asignar_plataforma() -> void:
    match plataf:
        "normal":
            anim.play("default")
        "amarilla":
            anim.play("amarilla")
        "morada":
            anim.play("morada")
        "roja":
            anim.play("roja")
        "verde":
            anim.play("verde")
            
            
