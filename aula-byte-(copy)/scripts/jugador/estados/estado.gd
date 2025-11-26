extends Node

class_name EstadoBase

var estado: Node = null
var nombre: String = ""

func enter(_estado: Node) -> void:
    estado = _estado
    
func exit() -> void:
    estado = null
    
func actualizar_fisicas(delta: float) -> void:
    pass
