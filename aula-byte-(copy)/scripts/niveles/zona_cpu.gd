extends Control
class_name ZonaCPU

var is_loked = false
var elements:Array[String]=[]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS

func set_is_loked(value: bool) -> void:
	is_loked = value

func get_is_loked() -> bool:
	return is_loked

func _can_drop_data(at_position: Vector2, data: Variant)-> bool:
	return !is_loked
	
func add_element(element: String) -> void:
	if not has_element(element):
		elements.append(element)

func has_element(element: String) -> bool:
	return element in elements

func remove_element(element: String) -> void:
	if has_element(element):
		elements.erase(element)
