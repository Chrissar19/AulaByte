extends Node

@export var nodo_raiz_nivel: NodePath    # arrastra aquí el Control raíz del nivel
var total_items: int = 0
var clasificados: int = 0

func _ready() -> void:
    var raiz := get_node_or_null(nodo_raiz_nivel)
    if raiz == null:
        raiz = get_parent()

    # Busca todos los arrastrables colocados en la escena
    var items := get_tree().get_nodes_in_group("arrastrable")
    total_items = items.size()
    clasificados = 0

    for it in items:
        if it.has_signal("clasificado_correctamente"):
            it.connect("clasificado_correctamente", Callable(self, "_on_item_clasificado"))

func _on_item_clasificado(_it: Control) -> void:
    clasificados += 1
    # Aquí puedes actualizar UI de progreso si quieres
    if clasificados >= total_items:
        _finalizar_actividad()

func _finalizar_actividad() -> void:
    # Si usas un GameManager global, emite la señal que ya tienes
    var gm := get_node_or_null("/root/GameManager")
    if gm:
        gm.emit_signal("actividad_superada")
    # Además puedes cambiar de escena o mostrar popup de "¡Perfecto!"
    print("[Actividad] Completada. ¡Bien hecho!")
