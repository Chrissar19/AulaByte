extends Control
class_name ZonaCPU

var is_loked = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


func set_is_loked(value: bool) -> void:
	is_loked = value

func get_is_loked() -> bool:
	return is_loked

func _can_drop_data(at_position: Vector2, data: Variant)-> bool:
	return !is_loked
