extends Node2D

const FUERZA_SALTO = -400.0
var player:CharacterBody2D = null
var en_coyote_time:bool = false
var tocando_suelo:bool = false
@export var duracion_coyote_time = 0.20
@onready var soun_jump: AudioStreamPlayer = $SounJump
@onready var timer_coyote_time: Timer = $TimerCoyoteTime

func _ready() -> void:
	player = get_parent()
	timer_coyote_time.one_shot = true
	timer_coyote_time.timeout.connect(on_timer_coyote_time_timeout)
	
	
func _physics_process(_delta: float) -> void:
	# Accion de salto
	if Input.is_action_just_pressed("saltar") and (player.is_on_floor() or en_coyote_time): # Si se presiona la barra espacio y se esta tocando el suelo
		player.velocity.y = FUERZA_SALTO
		soun_jump.play() # Reproduce el sonido de salto
		
	if tocando_suelo and not player.is_on_floor() and player.get_real_velocity().y >= 0:
		en_coyote_time = true
		timer_coyote_time.start(duracion_coyote_time)
		
	tocando_suelo = player.is_on_floor()
	
func on_timer_coyote_time_timeout() -> void:
	en_coyote_time = false
