extends Control

@onready var options_panel = $OptionsPanel
@onready var volume_slider = $OptionsPanel/VBoxContainer/VolumeSlider

func _ready():
	if options_panel:
		options_panel.visible = false
	if volume_slider:
		volume_slider.value_changed.connect(_on_volume_changed)
		volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func _on_play_button_pressed():
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_button_pressed():
	AudioManager.play_click()
	options_panel.visible = true

func _on_close_options_pressed():
	AudioManager.play_click()
	options_panel.visible = false

func _on_quit_button_pressed():
	AudioManager.play_click()
	get_tree().quit()

func _on_volume_changed(value):
	AudioManager.set_volume(value)
