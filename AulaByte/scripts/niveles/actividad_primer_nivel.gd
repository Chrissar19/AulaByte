extends Control

class_name ActividadN1

# ===========================
# Ajustes
# ===========================
@export var codigo_correcto: PackedStringArray = []
@export var intentos := 3
@export var validar := false #-- validar cuando la longitud coincide
@export var asteriscos := true #-- Muestran *** por las flechas

@onready var btn_arriba: TextureButton = $ContenedorFlechas/BtnArriba
@onready var btn_izquierda: TextureButton = $ContenedorFlechas/BtnIzquierda
@onready var btn_abajo: TextureButton = $ContenedorFlechas/BtnAbajo
@onready var btn_derecha: TextureButton = $ContenedorFlechas/BtnDerecha
@onready var btn_salir: Button = $BtnSalir
@onready var dato_1: Label = $VBoxContainer/HBoxClaves/Dato1
@onready var dato_2: Label = $VBoxContainer/HBoxClaves/Dato2
@onready var dato_3: Label = $VBoxContainer/HBoxClaves/Dato3
@onready var dato_4: Label = $VBoxContainer/HBoxClaves/Dato4


func _on_btn_arriba_pressed() -> void:
	pass # Replace with function body.


func _on_btn_izquierda_pressed() -> void:
	pass # Replace with function body.


func _on_btn_abajo_pressed() -> void:
	pass # Replace with function body.


func _on_btn_derecha_pressed() -> void:
	pass # Replace with function body.
