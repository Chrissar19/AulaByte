extends ActividadBase
class_name Actividad8

@onready var zona_rompe_c: Control = $ZonaRompeC
@onready var piezas_root: Control = $Piezas
@onready var lbl_tiempo: Label = $UI/LblTiempo
@onready var t_nivel: Timer = Timer.new()
@onready var btn_salir: Button = $UI/BtnSalir
@onready var aud_pista: AudioStreamPlayer = $AudPista

@export var tiempo_segundos: int = 90

var _piezas_colocadas: int = 0
var _total_piezas: int = 0

func _ready() -> void:
	# Llamar primero a la base
	super._ready()
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	# Crear y configurar timer de cuenta regresiva
	add_child(t_nivel)
	t_nivel.wait_time = 1.0
	t_nivel.one_shot = false
	t_nivel.timeout.connect(_actualizar_tiempo)
	t_nivel.start()
	
	# Inicializar piezas
	_total_piezas = 0
	for pieza in piezas_root.get_children():
		if pieza is PiezaPuzzle:
			_total_piezas += 1
			pieza.colocada.connect(_on_pieza_colocada)
	
	lbl_tiempo.text = "Tiempo: " + str(tiempo_segundos)
	
	_barajar_piezas()


func _actualizar_tiempo() -> void:
	tiempo_segundos -= 1
	lbl_tiempo.text = "Tiempo: " + str(tiempo_segundos)
	if tiempo_segundos <= 0:
		_terminar_juego(false)


func _on_pieza_colocada() -> void:
	_piezas_colocadas += 1
	if _piezas_colocadas >= _total_piezas:
		_terminar_juego(true)


func _terminar_juego(exito: bool) -> void:
	if is_instance_valid(t_nivel):
		t_nivel.stop()
	
	if exito:
		print("¡Rompecabezas completado!")
		finalizar_exito()   # notifica a GameManager → abrir puerta
	else:
		print("Tiempo agotado.")
		finalizar_fracaso() # notifica a GameManager → perder vida / reintentar


func _barajar_piezas() -> void:
	# Recolecta piezas y sus posiciones locales dentro del contenedor Piezas
	var piezas: Array = []
	var posiciones: Array[Vector2] = []
	for c in piezas_root.get_children():
		if c is PiezaPuzzle:
			piezas.append(c)
			posiciones.append((c as Control).position)

	# Si todas las piezas tienen la misma posición (caso raro), usa grilla
	var unicas := {}
	for p in posiciones:
		unicas[p] = true
	if unicas.size() <= 1:
		_dispersar_en_grilla(piezas)
		return

	# Barajar y reasignar
	posiciones.shuffle()
	for i in piezas.size():
		(piezas[i] as Control).position = posiciones[i]


func _dispersar_en_grilla(piezas: Array) -> void:
	# Plan B: coloca las piezas en una grilla dentro del contenedor Piezas
	if piezas.is_empty():
		return

	var area: Vector2 = (piezas_root as Control).size
	var n := piezas.size()
	var cols := maxi(2, int(ceil(sqrt(n)))) # grilla aproximadamente cuadrada
	var rows := int(ceil(float(n) / float(cols)))
	var padding := 8.0

	# Estimamos tamaño de celda
	var cell_w := (area.x - padding * (cols + 1)) / float(cols)
	var cell_h := (area.y - padding * (rows + 1)) / float(rows)

	# Creamos posiciones de celdas
	var slots: Array[Vector2] = []
	var idx := 0
	for r in rows:
		for c in cols:
			if idx >= n:
				break
			var pos := Vector2(
				padding + c * (cell_w + padding),
				padding + r * (cell_h + padding)
			)
			slots.append(pos)
			idx += 1

	slots.shuffle()
	for i in n:
		var pieza := piezas[i] as Control
		var target := slots[i]
		var tam := pieza.size
		var cell_center := target + Vector2(cell_w, cell_h) * 0.5
		var final_pos := cell_center - tam * 0.5
		final_pos.x = clamp(final_pos.x, 0.0, area.x - tam.x)
		final_pos.y = clamp(final_pos.y, 0.0, area.y - tam.y)
		pieza.position = final_pos


func cancelar_actividad() -> void:
	# Si el jugador cancela (ESC o botón salir), paramos timer
	if is_instance_valid(t_nivel):
		t_nivel.stop()
	# Llamamos comportamiento base (emite cancelado/cancelar)
	super.cancelar_actividad()


func configurar_con_parametros(parametros: Dictionary) -> void:
	# Por si quieres ajustar el tiempo desde el nivel o GameManager
	if parametros.has("tiempo"):
		tiempo_segundos = max(1, int(parametros["tiempo"]))
		lbl_tiempo.text = "Tiempo: " + str(tiempo_segundos)

func _on_btn_salir_pressed() -> void:
	cancelar_actividad()


func _on_btn_pista_pressed() -> void:
	aud_pista.play()
