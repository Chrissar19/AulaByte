extends Control

class_name ActividadBase

signal resuelto(exito: bool)

#-- Método que todas las actividades deben implementar
func configurar_con_parametros(parametros: Dictionary) -> void:
	pass
	
func limpiar() -> void:
	pass
