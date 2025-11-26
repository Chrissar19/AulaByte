extends ActividadBase
class_name Actividad9

@onready var ram: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Ram
@onready var video: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Video
@onready var raton: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Raton
@onready var texto: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Texto
@onready var imagen: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Imagen
@onready var video_2: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Video2
@onready var teclado: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Teclado
@onready var imagen_2: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Imagen2
@onready var microfono: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Microfono
@onready var impresora: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Impresora
@onready var audifonos: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Audifonos
@onready var disco_duro: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/DiscoDuro
@onready var procesador: ImagenArrastrable2 = $ZonaJuego/ContenedorObjetos/Procesador
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_pista: Button = $UI/BtnPista
@onready var audio_pista: AudioStreamPlayer = $AudioPista

var zonas_correctas: Dictionary = {
	"texto": ["ArchivosDigitales"],
	"teclado": ["ElementoEntrada"],
	"raton": ["ElementoEntrada"],
	"microfono": ["ElementoEntrada"],
	"disco_duro": ["ComponentesInternos", "PartesComputador"],
	"imagen": ["ArchivosDigitales"],
	"imagen_2": ["ArchivosDigitales"],
	"video": ["ArchivosDigitales"],
	"video_2": ["ArchivosDigitales"],
	"ram": ["ComponentesInternos", "PartesComputador"],
	"procesador": ["ComponentesInternos", "PartesComputador"],
	"impresora": ["ElementoSalida"],
	"audifonos": ["ElementoSalida"]
}

var asignaciones: Dictionary = {}

func _ready() -> void:
	super._ready()
	
	btn_salir.pressed.connect(_on_btn_salir_pressed)

func on_element_asigned(element: String, categorias: Array[String], zona: String, image: ImagenArrastrable2) -> void:
	if not zonas_correctas.has(element):
		finalizar_fracaso()
		return

	var zonas_validas: Array = zonas_correctas[element]
	if not zona in zonas_validas:
		finalizar_fracaso()
		return
		
	if not asignaciones.has(element):
		asignaciones[element] = []
		
	if zona in asignaciones[element]:
		return
		
	asignaciones[element].append(zona)
	
	if _asignacion_completa(element):
		if image and image.has_method("ocultar_elemento"):
			image.ocultar_elemento()
			
	if _todas_asignaciones_correctas():
		finalizar_exito()

func _asignacion_completa(element: String) -> bool:
	if not asignaciones.has(element):
		return false
		
	var zonas_validas = zonas_correctas[element]
	var zonas_asignadas = asignaciones[element]
	return zonas_asignadas.size() == zonas_validas.size()

func _todas_asignaciones_correctas() -> bool:
	if asignaciones.size() < zonas_correctas.size():
		return false

	for element in zonas_correctas.keys():
		if not _asignacion_completa(element):
			return false

	return true

func _on_texto_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("texto", categorias, zona, texto)

func _on_disco_duro_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("disco_duro", categorias, zona, disco_duro)

func _on_teclado_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("teclado", categorias, zona, teclado)

func _on_raton_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("raton", categorias, zona, raton)

func _on_microfono_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("microfono", categorias, zona, microfono)

func _on_imagen_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("imagen", categorias, zona, imagen)

func _on_imagen_2_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("imagen_2", categorias, zona, imagen_2)

func _on_video_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("video", categorias, zona, video)

func _on_video_2_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("video_2", categorias, zona, video_2)

func _on_ram_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("ram", categorias, zona, ram)

func _on_procesador_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("procesador", categorias, zona, procesador)

func _on_impresora_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("impresora", categorias, zona, impresora)

func _on_audifonos_element_asigned(categorias: Array[String], zona: String) -> void:
	on_element_asigned("audifonos", categorias, zona, audifonos)

func _on_btn_salir_pressed() -> void:
	cancelar_actividad()


func _on_btn_pista_pressed() -> void:
	if audio_pista:
		audio_pista.play()
