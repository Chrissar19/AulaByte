extends TextureRect
class_name ItemArrastrable

signal clas_correctamente(item: Control)

@export_enum("hardware", "no-hardware") var tipo := "hardware"
@export var nombre_item: String = "cpu"

var pos_inicial: Vector2
var escala: Vector2
var Arrastre_exitoso: bool = false

func _ready() -> void:
    add_to_group("ItemArrastrable")
    mouse_filter = Control.MOUSE_FILTER_STOP
    pos_inicial = position
    escala = scale
    #-- Para que escale desde el centro
    pivot_offset = size / 2.0
    
func _get_drag_data(at_position: Vector2) -> Variant:
    #-- Muestra el arrastre
    var ver := TextureRect.new()
    ver.texture = texture
    ver.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    ver.size = size
    set_drag_preview(ver)
    
    Arrastre_exitoso = false
    
    #-- Diccionario con los datos de los objetos
    return {
        "tipo": tipo,
        "item": self,
        "nombre": nombre_item
    }
    
func _notification(what: int) -> void:
    #-- Si se suelta en un lugar erroneo, vuelve al origen
    if what == NOTIFICATION_DRAG_END:
        if not Arrastre_exitoso:
            volver_al_origen()
            
func procesar_incorrecto() -> void:
    var t := create_tween()
    t.tween_property(self, "position", position + Vector2(10, 0), 0.05)
    t.tween_property(self, "position", position - Vector2(20, 0), 0.1)
    t.tween_property(self, "position", pos_inicial, 0.1)
    t.parallel().tween_property(self, "scale", escala, 0.15)
    
    
func procesar_correcto(destino: Control) -> void:
    Arrastre_exitoso = true
    #-- Efecto de entrar en la carpeta
    var cent_destino := destino.global_position + destino.size * 0.5 - size * 0.5
    var t := create_tween()
    t.tween_property(self, "scale", Vector2(0.0, 0.2), 0.25)
    await t.finished
    hide()
    emit_signal("clas_correctamente", self)
    queue_free()


func volver_al_origen() -> void:
    var t := create_tween()
    t.tween_property(self, "position", pos_inicial, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    t.parallel().tween_property(self, "scale", escala, 0.2)
