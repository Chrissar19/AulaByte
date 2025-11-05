extends Node2D
class_name Actividad8

@onready var zona_rompe_c: Control = $ZonaRompeC
@onready var piezas_root: Control = $Piezas
@onready var lbl_tiempo: Label = $UI/LblTiempo
@onready var t_nivel: Timer = Timer.new()

@export var tiempo_segundos: int = 90
var _piezas_colocadas: int = 0
var _total_piezas: int

func _ready() -> void:
    add_child(t_nivel)
    _total_piezas = piezas_root.get_child_count()
    t_nivel.wait_time = 1.0
    t_nivel.timeout.connect(_actualizar_tiempo)
    t_nivel.start()
    lbl_tiempo.text = "Tiempo: " + str(tiempo_segundos)
    for pieza in piezas_root.get_children():
        if pieza is PiezaPuzzle:
            pieza.colocada.connect(_on_pieza_colocada)
            
    _barajar_piezas()

func _actualizar_tiempo() -> void:
    tiempo_segundos -= 1
    lbl_tiempo.text = "Tiempo: " + str(tiempo_segundos)
    if tiempo_segundos <= 0:
        _terminar_juego(false)

func _on_pieza_colocada() -> void:
    _piezas_colocadas += 1
    if _piezas_colocadas == _total_piezas:
        _terminar_juego(true)

func _terminar_juego(exito: bool) -> void:
    t_nivel.stop()
    if exito:
        print("¡Rompecabezas completado!")
    else:
        print("Tiempo agotado.")
        
        
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
        # Opcional: centrar la pieza dentro de la celda según su tamaño
        var target := slots[i]
        var size := pieza.size
        var cell_center := target + Vector2(cell_w, cell_h) * 0.5
        var final_pos := cell_center - size * 0.5
        # Clampeamos dentro del área por seguridad
        final_pos.x = clamp(final_pos.x, 0.0, area.x - size.x)
        final_pos.y = clamp(final_pos.y, 0.0, area.y - size.y)
        pieza.position = final_pos
