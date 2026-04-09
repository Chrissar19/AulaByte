extends NivelBase
class_name Nivel10

const COLOR_A_ID = {
	"azul": 1, "amarilla": 2, "roja": 3, "morada": 4, 
	"verde": 5, "rosa": 6, "naranja": 7
}

var orden_activacion: Array[int] = [] 
var ids_que_si_sirven: Array[String] = []

func _ready():
	super._ready()
	orden_activacion.clear()
	
	# Escanea los IDs necesarios
	var plataformas = get_tree().get_nodes_in_group("Z_PLATAFORMAS")
	for p in plataformas:
		if p is PlataformaUniversal:
			for id_req in p.ids_requeridos:
				if not ids_que_si_sirven.has(id_req):
					ids_que_si_sirven.append(id_req)

	# Conecta los interruptores
	var inters = get_tree().get_nodes_in_group("Interruptores")
	for i in inters:
		if i.has_signal("activado"):
			i.activado.connect(_al_activar)
			
	# Escucha cuando el jugador interactúa con la puerta
	var puerta = get_node_or_null("PuertaNivel")
	if puerta:
		print("NIVEL: Puerta detectada y lista.")

func _al_activar(id_inter: String, ref_inter: Node):
	if ids_que_si_sirven.has(id_inter):
		var id_num = COLOR_A_ID.get(ref_inter.color_inter, 0)
		if id_num != 0:
			orden_activacion.append(id_num)
			GameManager.establecer_parametros_actividad({"codigo": orden_activacion})
			print("NIVEL: Código actualizado en GM -> ", orden_activacion)
			
func obtener_secuencia() -> Array[int]:
	return orden_activacion
