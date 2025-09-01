extends Control

class_name ActividadBase

#-- Método que todas las actividades deben implementar
func configurar_con_parametros(parametros: Dictionary) -> void:
	push_error("Método configurar_con_parametros no implementado en " + name)
