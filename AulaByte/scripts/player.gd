extends CharacterBody2D
class_name Player

#-- CONSTANTES FISICAS
@export var GRAVEDAD := 1200.0 #--Gravedad en px/s2
@export var VEL_HORIZONTAL = 150.0
@export var FUERZA_SALTO = -400.0
@export var FUERZA_EMPUJE = 800.0 #--Fuerza que se aplica a la caja
const COYOTE_TIME := 0.2 #--Tiempo maximo en el que se puede saltar tras dejar el suelo
var coyote_timer: float = 0.0

#--REFERENCIAS DE NODOS
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_jump: AudioStreamPlayer = $StateMachine/SoundJump #--Sonido de salto
@onready var empuje_ray: RayCast2D = $EmpujeRay

var animations: PlayerAnimations = PlayerAnimations.new()
var states: PlayerStates = PlayerStates.new()

#--ESTADOS
var esta_empujando: bool = false
var estaba_empujando: bool = false

func _physics_process(delta: float) -> void:
		
	#--aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta
		#--Cuenta coyote time
		coyote_timer -= delta
	else:
		#--Al tocar el suelo
		velocity.y = 0
		coyote_timer = COYOTE_TIME #--reinicia al tocar el suelo
	
	#--Logica de la maquina de estados
	state_machine._physics_process(delta)
	move_and_slide()

func movimiento_y_direccion() -> float:
	var dir := Input.get_axis("izquierda", "derecha") #--Recibe el dato entre -1, 0, o 1
	velocity.x = dir * VEL_HORIZONTAL
	actualizar_direccion(dir)
	return dir
	
func actualizar_direccion(dir: float) -> void:
	if dir != 0:
		animation_player.flip_h = dir < 0
	#-- ajusta la posición del raycast
	empuje_ray.target_position = Vector2(-20, 0) if animation_player.flip_h else Vector2(20, 0)
	
