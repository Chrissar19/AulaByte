extends NivelBase

@onready var plataforma1: AnimatableBody2D = $Plataformas/Plataforma
@onready var plataforma3: AnimatableBody2D = $Plataformas/Plataforma3
@onready var plataforma2: AnimatableBody2D = $Plataformas/Plataforma2

@onready var anim_a: AnimationPlayer = $Plataformas/Plataforma/AnimA
@onready var anim_b: AnimationPlayer = $Plataformas/Plataforma2/AnimB
@onready var anim_c: AnimationPlayer = $Plataformas/Plataforma3/AnimC


#-- Grupos
var grupo1_id := ["A"]
var grupo1_correctos := ["A"]

var grupo2_ids := ["B", "C", "D"]
var grupo2_correctos := ["C"]

var grupo3_ids := ["E", "F", "G"]
var grupo3_correctos := ["F", "E"]

#-- Estado activado
var grupo1_activados: Array = []
var grupo2_activados: Array = []
var grupo3_activados: Array = []

var grupo1_completado := false
var grupo2_completado := false
var grupo3_completado := false

#-- Diccionario para las animaciones}
var sw_g1: Dictionary = {}
var sw_g2: Dictionary = {}
var sw_g3: Dictionary = {}

#---------------------------------------------------------------------------------------------------

func _ready() -> void:
    #-- Llama a _ready de la base
    super._ready()
    
    # -- conectar interruptores mapeados por grupo
    for sw in get_tree().get_nodes_in_group("Interruptores"):
        if sw.has_signal("activado"):
            sw.activado.connect(on_interruptor_activado)
            
        # Acceso seguro: get() devuelve Variant → tipamos a String
        var sid_any = sw.get("id")
        var sid: String = sid_any if sid_any is String else ""
        if sid.is_empty():
            continue  # no es un interruptor válido
            
        # Mapear según su id al diccionario correcto (clave = sid)
        if sid in grupo1_id:
            sw_g1[sid] = sw
        elif sid in grupo2_ids:
            sw_g2[sid] = sw
        elif sid in grupo3_ids:
            sw_g3[sid] = sw
        
    #-- AnimationsPlayers
    for ap in [anim_a, anim_b, anim_c]:
        if ap:
            if ap.is_playing():
                ap.stop()
            ap.seek(0.0)
            
    #-- Sincronizar
    if plataforma1: plataforma1.sync_to_physics = true
    if plataforma2: plataforma2.sync_to_physics = true
    if plataforma3: plataforma3.sync_to_physics = true
    
# ────────────────────────────────────────────────────────────────────────────
# ENRUTAMIENTO DE INTERRUPTORES
# ────────────────────────────────────────────────────────────────────────────
func on_interruptor_activado(id: String, ref: Node) -> void:
    #-- Grupo1
    if id in grupo1_id and not grupo1_completado:
        _procesar_interruptor(id, ref, grupo1_correctos, grupo1_activados, anim_a, sw_g1, 1)
    # Grupo 2
    elif id in grupo2_ids and not grupo2_completado:
        _procesar_interruptor(id, ref, grupo2_correctos, grupo2_activados, anim_b, sw_g2, 2)
    # Grupo 3
    elif id in grupo3_ids and not grupo3_completado:
        _procesar_interruptor(id, ref, grupo3_correctos, grupo3_activados, anim_c, sw_g3, 3)
        
func _procesar_interruptor(id: String, ref: Node, correctos: Array, activados: Array, anim: AnimationPlayer, switches: Dictionary, grupo: int) -> void:
    if id in correctos:
        if id not in activados:
            activados.append(id)
            if ref and ref.has_method("activar_visual"):
                ref.activar_visual()
    else:
        #-- incorrecto
        _reset_grupo(activados, switches)
        if switches.has(id):
            var sw_pressed: Node = switches[id]
            if sw_pressed and sw_pressed.has_method("presionar_temporal"):
                sw_pressed.presionar_temporal(3.0)
        if anim:
            if anim.is_playing(): anim.stop()
            anim.seek(0.0)
        return
        
    #-- Combinaciones completas
    if activados.size() == correctos.size():
        #-- Evitar repetir
        if anim and not anim.is_playing():
            anim.play("mover")
        #-- Marcar grupo completado
        match grupo:
            1: grupo1_completado = true
            2: grupo2_completado = true
            3: grupo3_completado = true
            

func _reset_grupo(activados: Array, switches: Dictionary) -> void:
    for id_in in activados:
        if switches.has(id_in):
            var sw: Node = switches[id_in]
            if sw and  sw.has_method("desactivar_visual"):
                sw.desactivar_visual()
    activados.clear()
