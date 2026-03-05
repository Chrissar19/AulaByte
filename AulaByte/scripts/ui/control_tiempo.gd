extends ProgressBar
class_name ControlTiempo

signal tiempo_agotado

@export var tiempo_total: float = 10.0
@export var activar_al_inicio: bool = false

var tiempo_restante: float
var tiempo_activo: bool = false

# Referencias externas
var _etiqueta_mensaje: Label
var _btn_salir: Button
var _callback_habilitar_esc: Callable 

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	
	# --- BLINDAJE TÉCNICO ---
	step = 0.0  # Permite que la barra baje suavemente con decimales (delta)
	allow_greater = false
	allow_lesser = false
	
	_preparar_estilo_base()
	
	# Sincronización inicial de seguridad
	reajustar_limites(tiempo_total)
	
	if activar_al_inicio:
		iniciar()

# Nueva función interna para asegurar que la barra entienda los nuevos números
func reajustar_limites(nuevo_maximo: float):
	tiempo_total = nuevo_maximo
	max_value = tiempo_total
	value = tiempo_total
	tiempo_restante = tiempo_total
	print("[Componente] Límites reajustados: Max=", max_value, " Value=", value)

func iniciar(total: float = -1.0):
	if total > 0:
		reajustar_limites(total)
	else:
		reajustar_limites(tiempo_total)
	
	tiempo_activo = true
	modulate = Color.GREEN
	print("[Componente] Reloj EN MARCHA: ", tiempo_total, "s")

func detener():
	tiempo_activo = false
	print("[Componente] Reloj detenido.")

func vincular_ui(mensaje: Label, salir: Button, callback_esc: Callable):
	_etiqueta_mensaje = mensaje
	_btn_salir = salir
	_callback_habilitar_esc = callback_esc

func _process(delta: float):
	if not tiempo_activo: return
	
	tiempo_restante -= delta
	value = tiempo_restante # Esto ahora será fluido por el step = 0
	
	# Cálculo de porcentaje para colores
	var porcentaje = tiempo_restante / tiempo_total
	
	if porcentaje > 0.5:
		modulate = Color.GREEN
		_gestionar_bloqueo(false)
	elif porcentaje > 0.25:
		modulate = Color.YELLOW
		_gestionar_bloqueo(false)
	else:
		# Rojo con parpadeo
		var parpadeo = abs(sin(Time.get_ticks_msec() * 0.01))
		modulate = Color.RED.lerp(Color(1, 0.5, 0.5), parpadeo)
		_gestionar_bloqueo(true)

	if tiempo_restante <= 0:
		tiempo_restante = 0
		value = 0
		tiempo_activo = false
		print("[Componente] ¡TIEMPO AGOTADO!")
		tiempo_agotado.emit()

func _gestionar_bloqueo(bloquear: bool):
	if _btn_salir:
		_btn_salir.disabled = bloquear
		_btn_salir.modulate.a = 0.3 if bloquear else 1.0
	if _callback_habilitar_esc.is_valid():
		_callback_habilitar_esc.call(not bloquear)

func _preparar_estilo_base():
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1)
	bg.set_border_width_all(2)
	bg.border_color = Color.WHITE
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color.WHITE
	add_theme_stylebox_override("background", bg)
	add_theme_stylebox_override("fill", fill)
	
func pausar(valor: bool):
	tiempo_activo = not valor
	print("[Componente] Reloj ", "Pausado" if valor else "Reanudado")

func reanudar():
	tiempo_activo = true
