extends Area2D

@onready var anim : AnimatedSprite2D = $DoorSprite
@onready var PopUp : CanvasLayer = $"PopUp"
var is_active : bool = false
var player
var is_opened : bool = false

@onready var master_slider : HSlider = $"PopUp/BoxContainer/Sound Settings/Master_Settings/Master_Slider"
@onready var music_slider : HSlider = $"PopUp/BoxContainer/Sound Settings/Music_Settings/Music_Slider"
@onready var sfx_slider : HSlider = $"PopUp/BoxContainer/Sound Settings/Sfx_Settings/Sfx_Slider"

@onready var fullscreen_check : CheckBox = $PopUp/BoxContainer/Graphics/Fullscreen/FullscreenCheck
@onready var bloom_check : CheckBox = $PopUp/BoxContainer/Graphics/Bloom/BloomCheck
@onready var invert_check : CheckBox = $"PopUp/BoxContainer/Graphics/Invert-Colors/InvertCheck"
@onready var contrast_slider : HSlider = $PopUp/BoxContainer/Graphics/Contrast/Contrast_Slider
@onready var brightness_slider : HSlider = $PopUp/BoxContainer/Graphics/Brightness/Brightness_Slider
@onready var vignette_slider : HSlider = $PopUp/BoxContainer/Graphics/Vignette/Vignette_Slider


func _ready():
	anim.play("closed_no_key")
	master_slider.value = Global.master_vol
	music_slider.value = Global.music_vol
	sfx_slider.value = Global.sfx_vol

	bloom_check.button_pressed = Global.bloom
	invert_check.button_pressed = Global.invert_color
	fullscreen_check.button_pressed = Global.fullscreen
	contrast_slider.value = Global.contrast
	brightness_slider.value = Global.brightness
	vignette_slider.value = Global.vignette

func _process(_delta):
	if Input.is_action_just_pressed("Interact") && is_active:
		if !is_opened:
			anim.play("opened")
			is_opened = true
		elif is_opened:
			PopUp.visible = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		is_active = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_active = false
		player = null
		PopUp.set_visible(false)
		Global.save_settings()

func _on_button_pressed():
	PopUp.set_visible(false)
	Global.save_settings()

func _on_music_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(bus_index, value)
	Global.music_vol = value

func _on_sfx_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Sfx")
	AudioServer.set_bus_volume_linear(bus_index, value)
	Global.sfx_vol = value

func _on_master_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_index, value)
	Global.master_vol = value

func _on_bloom_check_pressed():
	Global.toggle_bloom(bloom_check.button_pressed)

func _on_invert_check_toggled(toggled_on):
	Global.toggle_invert_color(toggled_on)

func _on_fullscreen_check_pressed():
	Global.toggle_fullscreen(fullscreen_check.button_pressed)

func _on_contrast_slider_value_changed(value):
	Global.change_contrast(value)

func _on_brightness_slider_value_changed(value):
	Global.change_brightness(value)

func _on_vignette_slider_value_changed(value):
	Global.change_vignette(value)
