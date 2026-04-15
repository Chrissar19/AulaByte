extends Sprite2D

func _ready() -> void:
	animar_flecha()

func animar_flecha():
	#-- Se configura la variable para que sea infinita
	var tween = create_tween().set_loops()
	
	#-- Animacion de tamaño
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE)
	#-- cambio de color
	tween.parallel().tween_property(self, "modulate", Color(0.0, 0.783, 0.664, 1.0), 0.5)
	tween.tween_property(self, "modulate", Color(1,1,1), 0.5)
