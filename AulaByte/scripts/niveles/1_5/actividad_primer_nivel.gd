extends ActividadBase

# ===========================
# Ajustes
# ===========================

#-- Referencias a los nodos de la interfaz
@onready var lbl_intentos: Label = $LblIntentos
@onready var salida_texto: Label = $SalidaTexto
@onready var dato_1: Label = $HBoxClaves/Dato1
@onready var dato_2: Label = $HBoxClaves/Dato2
@onready var dato_3: Label = $HBoxClaves/Dato3
@onready var dato_4: Label = $HBoxClaves/Dato4
@onready var btn_derecha: TextureButton = $BtnDerecha
@onready var btn_izquierda: TextureButton = $BtnIzquierda
@onready var btn_arriba: TextureButton = $BtnArriba
@onready var btn_abajo: TextureButton = $BtnAbajo
@onready var btn_confirmar: Button = $BtnConfirmar
@onready var btn_salir: Button = $BtnSalir
@onready var btn_borrar: Button = $BtnBorrar



#-- Variables
var contrasenna_correcta: Array[int] = []
var contrasenna_ingresada: Array[int] = []
var intentos: int = 3

func _ready() -> void:
    btn_arriba.pressed.connect(_on_boton_numero_pressed.bind(1))
    btn_izquierda.pressed.connect(_on_boton_numero_pressed.bind(2))
    btn_abajo.pressed.connect(_on_boton_numero_pressed.bind(3))
    btn_derecha.pressed.connect(_on_boton_numero_pressed.bind(4))
    
    btn_borrar.pressed.connect(_on_btn_borrar_pressed)
    btn_confirmar.pressed.connect(_on_btn_confirmar_pressed)
    btn_salir.pressed.connect(_on_btn_salir_pressed)
    
    actualizar_pantalla()
    salida_texto.text = "Ingresa la contraseña"

func _on_boton_numero_pressed(numero: int) -> void:
    if contrasenna_ingresada.size() < 4:
        contrasenna_ingresada.append(numero)
        actualizar_pantalla()
        

func _on_btn_confirmar_pressed() -> void:
    if contrasenna_ingresada.size() < 4:
        salida_texto.text = "Contraseña incompleta"
        return
        
    var acierto = contrasenna_ingresada == contrasenna_correcta
    
    if acierto:
        salida_texto.text = "¡Contraseña correcta!"
        #-- pausa pequeña
        await get_tree().create_timer(1.0).timeout
        emit_signal("resuelto", true)
        queue_free()
    else:
        intentos -= 1
        if intentos <= 0:
            lbl_intentos.text = "Se agotaron los intentos."
            salida_texto.text = "Contraseña incorrecta."
            await get_tree().create_timer(1.5).timeout
            emit_signal("resuelto", false)
            queue_free()
        else:
            salida_texto.text = "Contraseña incorrecta"
            lbl_intentos.text = "Intentos restantes: %d" % intentos
            
            contrasenna_ingresada.clear()
            actualizar_pantalla()

func actualizar_pantalla() -> void:
    var datos = [dato_1, dato_2, dato_3, dato_4]
    
    for i in range(datos.size()):
        if i < contrasenna_ingresada.size():
            var valor = contrasenna_ingresada[i]  # ← Aquí está el número (1,2,3,4)
            
            if valor == 1:
                datos[i].text = "↑"
            elif valor == 2:
                datos[i].text = "←"
            elif valor == 3:
                datos[i].text = "↓"
            elif valor == 4:
                datos[i].text = "→"
        else:
            datos[i].text = "*"

func _on_btn_borrar_pressed() -> void:
    contrasenna_ingresada.clear()
    actualizar_pantalla()
    salida_texto.text = "Ingrese la contraseña"


func _on_btn_salir_pressed() -> void:
    emit_signal("resuelto", false)
    queue_free()

#-- Implementa el método para recibir parámetros
func configurar_con_parametros(parametros: Dictionary) -> void:
    if parametros.has("codigo"):
        #-- validad y convertir en entero
        contrasenna_correcta = []
        for elemento in parametros["codigo"]:
            contrasenna_correcta.append(int(elemento))
        print("Código correcto establecido desde parámetros: ", contrasenna_correcta)
    
    if parametros.has("intentos"):
        intentos = int(parametros["intentos"])
        if lbl_intentos != null:
            lbl_intentos.text = "Intentos: %d" % intentos
        else:
            push_error("El parámetro 'intentos' debe ser un número entero")
