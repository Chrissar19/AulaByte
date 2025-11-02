extends NivelBase

@onready var pared: Pared = $Plataformas/Pared

func _ready() -> void:
	super._ready()

func _on_jefe_final_ondead() -> void:
	pared.destroy()
