extends PlayerState

func enter():
	print("Este es el estado Move")
	
#--Cambiar de estado Move a estado Idle
func process(_delta):
	if Input.is_action_pressed("izquierda"):
		state_machine.cambiar_a("PlayerStateIdle")
