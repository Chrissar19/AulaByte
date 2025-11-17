extends ActividadBase
class_name Actividad4

enum Fase {INTRO1, INTRO2, ELECCION, RESULTADO}

@export var t_intro1 := 5.0
@export var t_intro2 := 5.0

@onready var zona_cartas: Control = $Fondo/ZonaCartas
@onready var btn_aceptar: Button = $UI/BtnAceptar
@onready var carta_bici: TextureRect = $Fondo/CartaBici
@onready var carta_bus: TextureRect = $Fondo/CartaBus
@onready var carta_camion: TextureRect = $Fondo/CartaCamion
@onready var btn_reiniciar: Button = $UI/BtnReiniciar
@onready var carta_carro: TextureRect = $Fondo/CartaCarro
@onready var lbl_texto: Label = $UI/LblTexto

var _seleccion: CartaVolteable = null
var _cartas: Array[CartaVolteable] = []
var _fase: int = Fase.INTRO1
var _contador: int = 0
var _interaccion_habilitada := false

func _ready() -> void:
	super._ready()
	_reunir_cartas()

	if not btn_aceptar.pressed.is_connected(_on_btn_aceptar_pressed):
		btn_aceptar.pressed.connect(_on_btn_aceptar_pressed)
	if not btn_reiniciar.pressed.is_connected(_on_btn_reiniciar_pressed):
		btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
		
	_iniciar_secuencia()


func _reunir_cartas() -> void:
	_cartas.clear()
	for n in zona_cartas.get_children():
		if n is CartaVolteable:
			var c := n as CartaVolteable
			_cartas.append(c)
			if not c.carta_volteada.is_connected(_on_carta_volteada):
				c.carta_volteada.connect(_on_carta_volteada)
			if not c.carta_seleccionada.is_connected(_on_carta_seleccionada):
				c.carta_seleccionada.connect(_on_carta_seleccionada)

#-----------------------------------------------------------
#-- SECUENCIA PARA EL SILOGISMO
#------------------------------------------------------------
func _iniciar_secuencia() -> void:
	_contador += 1
	var i := _contador
	
	_interaccion_habilitada = false
	btn_aceptar.disabled = true
	_seleccion= null
	for c in _cartas:
		c.deseleccionar_y_cerrar()
		
	#-- Estado visual inicial
	zona_cartas.visible = false
	carta_carro.visible = false
	carta_bici.visible = false
	carta_bus.visible = false
	carta_camion.visible = false
	
	lbl_texto.text = "Todos los vehículos tienen ruedas."  
	carta_bici.visible = true
	carta_bus.visible = true
	carta_camion.visible = true
	_fase = Fase.INTRO1
	await get_tree().create_timer(t_intro1).timeout
	if i != _contador: return
	
	lbl_texto.text = "El carro es un vehículo."  
	carta_carro.visible = true
	carta_bici.visible = false
	carta_bus.visible = false
	carta_camion.visible = false
	_fase = Fase.INTRO2
	await get_tree().create_timer(t_intro2).timeout
	if i != _contador: return
	
	lbl_texto.text = "Elige la carta que completa el silogismo."
	carta_carro.visible = false
	zona_cartas.visible = true
	_fase = Fase.ELECCION
	_interaccion_habilitada = true
	
	
#--------------------------------------------------------
#-- INTERACCION CON CARTAS
#-------------------------------------------------------    
func _on_carta_volteada(carta: CartaVolteable) -> void:
	if not _interaccion_habilitada: return
	# Cierra las demás
	for c in _cartas:
		if c != carta:
			c.forzar_cierre()

func _on_carta_seleccionada(carta: CartaVolteable) -> void:
	if not _interaccion_habilitada: return
	# Solo una seleccionada
	for c in _cartas:
		if c != carta:
			c.deseleccionar_y_cerrar()
	_seleccion = carta
	btn_aceptar.disabled = false
	

#------------------------------------------------
#-- BOTONES
#-----------------------------------------------
func _on_btn_aceptar_pressed() -> void:
	if _seleccion == null: return
	_interaccion_habilitada = false
	if _seleccion.es_correcta:
		finalizar_exito()
	else:
		finalizar_fracaso()
		

func _on_btn_reiniciar_pressed() -> void:
	_iniciar_secuencia()
