extends EnemigoBase
class_name Slime

# ============================================================================
# INICIALIZACIÓN ESPECÍFICA DE SLIME AZUL
# ============================================================================
func _inicializar_enemigo() -> void:
	
	z_index = ZCapas.ENEMIGOS if "ZCapas" in get_tree().root else 0
	
	if sprite:
		sprite.play("slime_walk_blue")

# ============================================================================
# MUERTE ESPECÍFICA POR CAJAS PESADAS
# ============================================================================
func _on_sensor_pisoton_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("Cajas") and area.is_in_group("Pisos"):
		if esta_muerto: return
		
		esta_muerto = true
		set_physics_process(false)
		
		if sprite:
			sprite.play("slime_death_blue")
		if audio_muerte:
			audio_muerte.play()
		if particulas:
			particulas.emitting = true
			
		if timer_muerte:
			timer_muerte.start(0.4)
		else:
			await get_tree().create_timer(0.4).timeout
			queue_free()
