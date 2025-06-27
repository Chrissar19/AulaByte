extends Node2D

const FUERZA_SALTO = -400.0
var player:CharacterBody2D = null
var en_coyote_time:bool = false
var tocando_suelo:bool = false
var salto_buffering : bool = false
@export var tiempo_salto_buffering = 0.15
@export var duracion_coyote_time = 0.20
@onready var sound_jump: AudioStreamPlayer = $SoundJump
@onready var timer_coyote_time: Timer = $TimerCoyoteTime
@onready var tm_buffer_salto: Timer = $tmBufferSalto

func _ready() -> void:
	player = get_parent()
	timer_coyote_time.one_shot = true #Que se ejecuta una sola vez
	timer_coyote_time.timeout.connect(on_timer_coyote_time_timeout)
	tm_buffer_salto.one_shot = true
	tm_buffer_salto.timeout.connect(on_salto_buffe_time_timeout)
	
	
func _physics_process(_delta: float) -> void:
	# Accion de salto
	if Input.is_action_just_pressed("saltar"):
		if (player.is_on_floor() or en_coyote_time): # Si se presiona la barra espacio y se esta tocando el suelo
			saltar()
		else:
			salto_buffering = true
			tm_buffer_salto.start(tiempo_salto_buffering)
		
	if tocando_suelo and not player.is_on_floor() and player.get_real_velocity().y >= 0:
		en_coyote_time = true
		timer_coyote_time.start(duracion_coyote_time)

# Verifica si el personaje toca suelo al caer
	if not tocando_suelo and player.is_on_floor() and salto_buffering:
		salto_buffering = false
		tm_buffer_salto.stop()
		saltar()
	
	tocando_suelo = player.is_on_floor()
	
func on_timer_coyote_time_timeout() -> void:
	en_coyote_time = false

func on_salto_buffe_time_timeout() -> void:
	salto_buffering = false
	
func saltar() -> void:
	player.velocity.y = FUERZA_SALTO
	sound_jump.play() # Reproduce el sonido de salto
