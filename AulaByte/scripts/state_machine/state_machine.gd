extends Node

class_name StateMachine

#--El nodo principal seria el nodo player, se conecta mediante el owner
@onready var nodo_de_control = self.owner

#-- SE CONECTA LA MAQUINA CON LOS ESTADOS--
@export_node_path("Node") var estado_inicial #--Almacena el estado inicial
@onready var estado = get_node(estado_inicial) #--Guarda el estado que se este ejecutando

#--DEBUG --> DEPURAR
@export var DEPURAR : bool = true #--permitira mostrar mensajes en la consola sobre el estado actual
@export var IMPRIMIR_HISTORIAL : bool = false
var historial = []
#-----------------------------------------------------------------------------------

func _ready() -> void:
	#--Espera a que los nodos esten listos antes de llamar al metodo _enter_state
	call_deferred("_entrar_a_estado")
	pass
	
#--ESTA FUNCION SE EJECUTARA COMO SI FUERA LA FUN READY EN LA MAQUINA DE EST.
func _entrar_a_estado():
	#--Imprime en consola el estado actual
	if DEPURAR:
		print(owner.name, ": Entrando al estado: ", estado.name)
	
	#--TODOS LOS ESTADOS DEBEN TENER LA VARIABLE NODE
	#--Se agrega este nodo al nodo Player para controlas los nodos hijos
	estado.node = nodo_de_control
	
	#--TODOS LOS ESTADOS DEBEN TENER LA VARIABLE ESTATE_MACHINE
	#--ALMACENA LA MAQUINA DE ESTADOS
	estado.state_machine = self #Todos los nodos tipo estado, deben tener esta variable
	estado.enter() #--Reemplazara la funsion ready en los estados
	
#--cambia a un nuevo estado
#--nuevo estado seria el estado al que se va a cambiar
func cambiar_a(nuevo_estado):
	historial.append(estado.name) #--Se agrega el nuevo estado al arreglo historial
	estado = get_node(nuevo_estado) #-- Se guarda el estado actual
	_entrar_a_estado()
	#--verifica si la variable historial es verdadera e imprime
	if IMPRIMIR_HISTORIAL:
		print(historial)
		
#--SOBRE ESCRIBIR LOS METODOS PRINCIPALES--
#--------------------------------------------------------------------
	#--SOBREESCRIBIR EL MÉTODO process
func _process(delta: float) -> void:
	#--Verifica si el estado tiene el metodo process
	if estado.has_method("process"):
		estado.process(delta) #--Se ejecuta si el estado tiene el metodo
		
#--SOBREESCRIBIR EL MÉTODO phisics_process
func _physics_process(delta: float):
	if estado.has_method("physics_process"):
		estado.physics_process(delta)
		
	#--Recibe un evento por parametro
func _input(event):
	if estado.has_method("input"):
		estado.input(event)
		
func _unhandled_input(event):
	if estado.has_method("unhandled_input"):
		estado.unhandled_input(event)

func _unhandled_key_input(event):
	if estado.has_method("unhandled_key_input"):
		estado.unhandled_key_input(event)
		
#------------------------------------------------------------------------------
