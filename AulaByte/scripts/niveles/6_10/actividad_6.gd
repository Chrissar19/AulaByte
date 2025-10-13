extends ActividadBase
class_name Minijuego6

@export var figura_objetivo: String = "cohete"
@export var tiempo_limite: float = 180.0
@export var tolerancia_pos: float = 20.0
@export var tolerancia_rot: float = 15.0

#-- NODOS
@onready var area_juego: Control = $AreaJuego
@onready var silueta: Control = $AreaJuego/Silueta
@onready var area_piezas: Control = $AreaPiezas
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var lbl_instrucciones: Label = $UI/LblInstrucciones
@onready var btn_salir: Button = $UI/BtnSalir


#-- Escena de pieza
const PiezaTangram = preload("res://escenas/Niveles/6_10/pieza_tangram.tscn")

#-- datos del juego
var piezas: Array[Node2D] = []
var zonas_objetivo: Array[Dictionary] = []
var timer: float = 0.0
var juego_iniciado: bool = false

func _ready() -> void:
    super._ready()
    crear_boton_si_no_existe = true
    _configurar_ui()
    _crear_figura()
    _crear_piezas()
    juego_iniciado = true
    
    
func _process(delta: float) -> void:
    if not juego_iniciado or _finalizado: return
        
    #--Temporizador
    timer += delta
    if timer >= tiempo_limite:
        finalizar_fracaso()
        return
        
    #-- verificar si se completo
    if _verificar_completado():
        finalizar_exito()
        
             
#-------------------------------------------------------------
#-- CONFIGURACION
#--------------------------------------------------------------
func _configurar_ui() -> void:
    lbl_instrucciones.text = "Arrastra las piezas y completa la figura. Click derecho para rotar"
    
    
func configurar_con_parametros(parametros: Dictionary) -> void:
    if parametros.has("figura"):
        figura_objetivo = parametros.figura
    if parametros.has("tiempo"):
        tiempo_limite = parametros.tiempo
        
        
#-------------------------------------------------------------
#-- CREACCION DE FIGURA
#-------------------------------------------------------------
func _crear_figura() -> void:
    for child in silueta.get_children():
        child.queue_free()
        
    zonas_objetivo.clear()
    
    #-- centro del AreaJuego
    var centro = area_juego.size / 2

    #-- Difinir las zonas de cada figura
    match figura_objetivo:
        "cohete":
            _crear_cohete_objetivo(centro)
        "casa":
            _crear_casa_objetivo(centro)
        "Tortuga":
            _crear_tortuga_objetivo(centro)
        _:
            _crear_cohete_objetivo(centro)
            
            
func _crear_cohete_objetivo(centro: Vector2) -> void:
    #-- Piezas del tangram
    var definir_piezas = [
        {"tipo": "triangulo_mediano", "pos": Vector2(173, 48), "rot": 90.0},
        {"tipo": "triangulo_pequeno", "pos": Vector2(101, 168), "rot": 0.0},
        {"tipo": "cuadrado", "pos": Vector2(101, 144), "rot": 0.0},
        {"tipo": "triangulo_pequeno", "pos": Vector2(173, 49), "rot": 180.0},
        {"tipo": "paralelogramo", "pos": Vector2(196, 143), "rot": 90.0},
        {"tipo": "triangulo_grande", "pos": Vector2(125, 192), "rot": 270.0},
        {"tipo": "triangulo_grande", "pos": Vector2(173, 144), "rot": 180.0},
    ]
    for def in definir_piezas:
        _crear_zona_objetivo(centro + def.pos, def.rot, def.tipo)
        
func _crear_casa_objetivo(centro: Vector2) -> void:
    #-- Piezas del tangram
    var definir_piezas = [
        {"tipo": "triangulo_mediano", "pos": Vector2(198, 128), "rot": 90.0},
        {"tipo": "triangulo_pequeno", "pos": Vector2(102, 129), "rot": 0.0},
        {"tipo": "cuadrado", "pos": Vector2(162, 45), "rot": 45.0},
        {"tipo": "triangulo_pequeno", "pos": Vector2(103, 128), "rot": 0.0},
        {"tipo": "paralelogramo", "pos": Vector2(163, 78), "rot": 45.0},
        {"tipo": "triangulo_grande", "pos": Vector2(85, 82), "rot": 45.0},
        {"tipo": "triangulo_grande", "pos": Vector2(198, 129), "rot": 90.0},
    ]
    for def in definir_piezas:
        _crear_zona_objetivo(centro + def.pos, def.rot, def.tipo)
        
func _crear_tortuga_objetivo(centro: Vector2) -> void:
    #-- Piezas del tangram
    var definir_piezas = [
        {"tipo": "triangulo_mediano", "pos": Vector2(187, 181), "rot": 135},
        {"tipo": "triangulo_pequeno", "pos": Vector2(102, 136), "rot": 45.0},
        {"tipo": "cuadrado", "pos": Vector2(178, 98), "rot": 0.0},
        {"tipo": "triangulo_pequeno", "pos": Vector2(102, 108), "rot": 225.0},
        {"tipo": "paralelogramo", "pos": Vector2(205, 46), "rot": 135.0},
        {"tipo": "triangulo_grande", "pos": Vector2(180, 74), "rot": 90.0},
        {"tipo": "triangulo_grande", "pos": Vector2(86, 74), "rot": 0.0},
    ]
    for def in definir_piezas:
        _crear_zona_objetivo(centro + def.pos, def.rot, def.tipo)
        
func _crear_zona_objetivo(pos: Vector2, rotacion: float, tipo: String) -> void:
    var zona = ColorRect.new()
    zona.color = Color(1, 1, 1, 0.3)
    zona.size = _obtener_tam_pieza(tipo)
    zona.pivot_offset = zona.size / 2
    zona.position = pos - zona.size /2
    zona.rotation_degrees = rotacion
    silueta.add_child(zona)
    
    #-- Guardar datos de la zona
    zonas_objetivo.append({
        "pos": pos,
        "rot": rotacion,
        "tipo": tipo,
        "ocupada": false,
        "nodo": zona
    })
    

#-------------------------------------------------------------
#-- CREACCION DE FIGURA
#-------------------------------------------------------------
func _crear_piezas() -> void:
    var tipos = [
        "triangulo_mediano",
        "triangulo_pequeno",
        "cuadrado",
        "triangulo_pequeno",
        "paralelogramo",
        "triangulo_grande",
        "triangulo_grande"
    ]
    
    #-- Colores tradicionales
    var colores = [
        Color.YELLOW,
        Color.CYAN,
        Color.BLUE,
        Color.GREEN,
        Color.PURPLE,
        Color.RED,
        Color.ORANGE
        
    ]

    #-- posiciones iniciales
    var posiciones_iniciales = [
        Vector2(80, 11),
        Vector2(8, 67),
        Vector2(64, 59),
        Vector2(64, 11),
        Vector2(120, 11),
        Vector2(8, 123),
        Vector2(144, 75)
    ]
    
    for i in tipos.size():
        var pieza = PiezaTangram.instantiate()
        area_piezas.add_child(pieza)
        
        pieza.position = posiciones_iniciales[i]
        pieza.configurar(tipos[i], colores[i])
        pieza.colocada_correctamente.connect(_on_pieza_colocada)
        piezas.append(pieza)
        
        
func _obtener_tam_pieza(tipo: String) -> Vector2:
    match tipo:
        "triangulo_mediano":
            return Vector2(48, 48)
        "triangulo_pequeno":
            return Vector2(24, 48)
        "cuadrado":
            return Vector2(48, 48)
        "paralelogramo":
            return Vector2(72, 24)
        "triangulo_grande":
            return Vector2(96, 48)
        _:
            return Vector2(48, 48)
            

#---------------------------------------------
#-- VERIFICAR
#---------------------------------------------
func _verificar_completado() -> bool:
    var piezas_correctas := 0
    
    for pieza in piezas:
        if pieza.esta_colocada_correctamente:
            piezas_correctas += 1
    return piezas_correctas == piezas.size()
    
    
func _on_pieza_colocada() -> void:
    var piezas_correctas = 0
    for pieza in piezas:
        if pieza.esta_colocada_correctamente:
            piezas_correctas += 1
            
    lbl_instrucciones.text = "Piezas colocadas: %d/7" % piezas_correctas
    
    
    
func limpiar() -> void:
    for pieza in piezas:
        if is_instance_valid(pieza):
            pieza.queue_free()
        piezas.clear()
        zonas_objetivo.clear()
        juego_iniciado = false
