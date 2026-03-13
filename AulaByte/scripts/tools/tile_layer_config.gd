# res://shared/TileLayerConfig.gd
extends Resource
class_name TileLayerConfig

@export var tileset: TileSet
@export var rendering_quadrant_size := 16
@export var y_sort_enabled := false
@export var z_index := 0

# Física
@export var use_collision := true
@export var collision_layer := 1   # bits en Godot 4 (1<<0 = 1, 1<<1 = 2, etc.)
@export var collision_mask := 0    # los estáticos usualmente no necesitan máscara

# Navegación (opcional, por si usas Navigation2D)
@export var navigation_layer := 0

# Estilo
@export var modulate := Color.WHITE

func apply_to(layer: TileMapLayer) -> void:
    if tileset:
        layer.tile_set = tileset
    layer.rendering_quadrant_size = rendering_quadrant_size
    layer.y_sort_enabled = y_sort_enabled
    layer.z_index = z_index
    layer.modulate = modulate
    layer.navigation_layer = navigation_layer

    # Colisión: si no se usa, fuerza capas en 0 para evitar “sobrantes”
    if use_collision:
        layer.collision_layer = collision_layer
        layer.collision_mask = collision_mask
    else:
        layer.collision_layer = 0
        layer.collision_mask = 0
