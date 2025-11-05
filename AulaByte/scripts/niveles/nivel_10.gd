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

#---------------------------------------------------------------------------------------------------

func _ready() -> void:
    #-- Llama a _ready de la base
    super._ready()
    
    for sw in get_tree().get_nodes_in_group("Interruptores"):
        if sw.has_signal("activado"):
            sw.activado.connect(on_interruptor_activado)
    
    anim_a.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
    anim_b.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
    anim_c.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
    
    plataforma1.sync_to_physics = true
    plataforma2.sync_to_physics = true
    plataforma3.sync_to_physics = true
    
    for ap in [anim_a, anim_b, anim_c]:
        if ap.is_playing():
            anim_a.stop()
        anim_a.seek(0.0)
    
    
# ────────────────────────────────────────────────────────────────────────────
# ENRUTAMIENTO DE INTERRUPTORES
# ────────────────────────────────────────────────────────────────────────────
func on_interruptor_activado(id: String) -> void:
    #-- Grupo1
    if id in grupo1_id and not grupo1_completado:
        _procesar_interruptor(id, grupo1_correctos, grupo1_activados, anim_a, 1)
    # Grupo 2
    elif id in grupo2_ids and not grupo2_completado:
        _procesar_interruptor(id, grupo2_correctos, grupo2_activados, anim_b, 2)
    # Grupo 3
    elif id in grupo3_ids and not grupo3_completado:
        _procesar_interruptor(id, grupo3_correctos, grupo3_activados, anim_c, 3)
        
func _procesar_interruptor(id: String, correctos: Array, activados: Array, anim: AnimationPlayer, grupo: int) -> void:
    if id in correctos:
        if id not in activados:
            activados.append(id)
    else:
        #-- incorrecto
        activados.clear()
        if anim.is_playing():
            anim.stop()
        anim.seek(0.0)
        
    #-- Interruptores correctos
    if activados.size() == correctos.size():
        #-- Evitar repetir
        if not anim.is_playing():
            anim.play("mover")
        #-- Marcar grupo completado
        match grupo:
            1: grupo1_completado = true
            2: grupo2_completado = true
            3: grupo3_completado = true
