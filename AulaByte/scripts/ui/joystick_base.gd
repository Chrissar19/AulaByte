extends Control

@export var limite := 50.0
@onready var palanca: Sprite2D = $Palanca

var touch_id = -1
var valor_jugador := 0.0

func _ready():
	if not OS.has_feature("editor") and not (OS.has_feature("android") or OS.has_feature("ios")):
		visible = false
		set_process_input(false)
		return

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			if global_position.distance_to(event.position) < limite * 2:
				touch_id = event.index
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			palanca.position = Vector2.ZERO
			valor_jugador = 0.0
	if event is InputEventScreenDrag and event.index == touch_id:
		var diff = event.position.x - global_position.x
		palanca.position.x = clamp(diff, -limite, limite)
		valor_jugador = palanca.position.x / limite
