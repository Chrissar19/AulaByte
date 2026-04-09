extends ActividadBase
class_name Actividad8

# --- Referencias UI ---
@onready var zona_rompe_c: Control = $ZonaRompeC
@onready var piezas_root: Control = $Piezas
@onready var btn_salir: Button = $UI/BtnSalir
@onready var aud_pista: AudioStreamPlayer = $AudPista
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo 

# --- Configuración y Estado ---
@export var tiempo_segundos: int = 90
var _piezas_colocadas: int = 0
var _total_piezas: int = 0

# --- Ciclo de Vida ---
func _ready() -> void:
	super._ready()
	
	# TIEMPO
	ctrl_tiempo.vincular_ui(null, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_on_tiempo_agotado)
	ctrl_tiempo.iniciar(tiempo_segundos)
	
	# Conexiones
	btn_salir.pressed.connect(_on_salir_pressed)
	
	# Inicializar piezas
	_inicializar_piezas()
	_barajar_piezas()

func _inicializar_piezas() -> void:
	_total_piezas = 0
	for pieza in piezas_root.get_children():
		if pieza is PiezaPuzzle:
			_total_piezas += 1
			# Conecta la señal de la pieza a la lógica
			if not pieza.colocada.is_connected(_on_pieza_colocada):
				pieza.colocada.connect(_on_pieza_colocada)

# --- Lógica de Juego ---
func _on_pieza_colocada() -> void:
	_piezas_colocadas += 1
	# print("Pieza encajada: ", _piezas_colocadas, "/", _total_piezas)
	
	if _piezas_colocadas >= _total_piezas:
		_ganar()

func _on_tiempo_agotado() -> void:
	_perder()

# --- Finalización ---
func _ganar() -> void:
	ctrl_tiempo.detener()
	finalizar_exito()

func _perder() -> void:
	ctrl_tiempo.detener()
	finalizar_fracaso()

func _on_salir_pressed() -> void:
	ctrl_tiempo.detener()
	cancelar_actividad()

func _on_btn_pista_pressed() -> void:
	if aud_pista.playing: return
	
	ctrl_tiempo.pausar(true)
	aud_pista.play()
	
	await aud_pista.finished
	if not _finalizado:
		ctrl_tiempo.pausar(false)

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("tiempo"):
		tiempo_segundos = max(1, int(parametros["tiempo"]))
		ctrl_tiempo.iniciar(tiempo_segundos)

# --- Lógica de Mezcla---
func _barajar_piezas() -> void:
	var piezas: Array = []
	var posiciones: Array[Vector2] = []
	for c in piezas_root.get_children():
		if c is PiezaPuzzle:
			piezas.append(c)
			posiciones.append(c.position)

	if posiciones.is_empty(): return

	var unicas := {}
	for p in posiciones: unicas[p] = true
	
	if unicas.size() <= 1:
		_dispersar_en_grilla(piezas)
	else:
		posiciones.shuffle()
		for i in piezas.size():
			piezas[i].position = posiciones[i]

func _dispersar_en_grilla(piezas: Array) -> void:
	var area: Vector2 = piezas_root.size
	var n := piezas.size()
	var cols := maxi(2, int(ceil(sqrt(n))))
	var rows := int(ceil(float(n) / float(cols)))
	var padding := 8.0
	var cell_w := (area.x - padding * (cols + 1)) / float(cols)
	var cell_h := (area.y - padding * (rows + 1)) / float(rows)

	var slots: Array[Vector2] = []
	for r in rows:
		for c in cols:
			if slots.size() >= n: break
			slots.append(Vector2(padding + c*(cell_w+padding), padding + r*(cell_h+padding)))

	slots.shuffle()
	for i in n:
		var pieza := piezas[i] as Control
		var cell_center := slots[i] + Vector2(cell_w, cell_h) * 0.5
		pieza.position = cell_center - pieza.size * 0.5
