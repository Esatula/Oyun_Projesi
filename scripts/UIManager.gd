extends Control

@onready var dialogue_box = $DialoguePanel
@onready var dialogue_label = $DialoguePanel/Label
@onready var options_container = $OptionsContainer
@onready var feedback_panel = $FeedbackPanel
@onready var feedback_label = $FeedbackPanel/Label
@onready var try_again_btn = $FeedbackPanel/TryAgainButton

signal option_chosen(id)
signal try_again
signal dialogue_advanced

func _ready():
	options_container.visible = false
	feedback_panel.visible = false
	try_again_btn.connect("pressed", _on_try_again_pressed)
	
	# Enable input on DialoguePanel
	dialogue_box.mouse_filter = Control.MOUSE_FILTER_STOP
	dialogue_box.gui_input.connect(_on_dialogue_panel_gui_input)
	
	# Apply Theme Colors
	# Main BG: #3FD6D6, Secondary/Border: #E53935
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#3FD6D6") # Cyan
	style.bg_color.a = 0.9 # Slight transparency
	style.border_color = Color("#E53935") # Red Border
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	dialogue_box.add_theme_stylebox_override("panel", style)
	
	# Try Again Button Style (Standardize)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("#E53935")
	btn_style.set_corner_radius_all(5)
	try_again_btn.add_theme_stylebox_override("normal", btn_style)

func _on_dialogue_panel_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("dialogue_advanced")

func show_dialogue(text: String):
	dialogue_label.text = text
	# Ensure dialogue is visible unless options are showing (handled elsewhere, but good to reset)
	# However, if we just want to update text while options are hidden, we should check mode.
	if not options_container.visible:
		dialogue_box.visible = true

func show_options(options: Array):
	# Hide dialogue box to prevent overlap
	dialogue_box.visible = false
	options_container.visible = true
	
	# Clear existing buttons
	for child in options_container.get_children():
		child.queue_free()
	
	# Create new buttons
	for opt in options:
		var btn = Button.new()
		# Minimum size for horizontal layout
		btn.custom_minimum_size = Vector2(250, 180)
		
		# Theme for Buttons
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color("#3FD6D6") # Cyan
		btn_style.border_color = Color("#E53935") # Red Border
		btn_style.set_border_width_all(3)
		btn_style.set_corner_radius_all(8)
		
		# Hover style
		var hover_style = btn_style.duplicate()
		hover_style.bg_color = Color("#E53935") # Red on hover? Or lighter Cyan?
		# Let's try lighter cyan for hover logic or keep simple for now. 
		# User asked for specific colors but not hover behaviors.
		
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color.BLACK) # Black text on Cyan
		
		# If image is provided in option dict, set it
		if opt.has("icon_path"):
			var icon_texture = load(opt["icon_path"])
			if icon_texture:
				btn.icon = icon_texture
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				btn.expand_icon = true
		
		btn.text = opt["text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.connect("pressed", func(): _on_button_pressed(opt["id"]))
		options_container.add_child(btn)

func show_feedback(text: String):
	options_container.visible = false
	dialogue_box.visible = false
	feedback_panel.visible = true
	
	# Theme for Feedback Panel
	var fb_style = StyleBoxFlat.new()
	fb_style.bg_color = Color("#3FD6D6")
	fb_style.border_color = Color("#E53935") # Red border
	fb_style.set_border_width_all(4)
	fb_style.set_corner_radius_all(10)
	feedback_panel.add_theme_stylebox_override("panel", fb_style)
	
	feedback_label.text = text

func hide_feedback():
	feedback_panel.visible = false
	dialogue_box.visible = true

func _on_button_pressed(id):
	AudioManager.play_click()
	options_container.visible = false
	# Dialogue box will stay hidden until next show_dialogue call or manual reset
	emit_signal("option_chosen", id)
	# Also notify Main directly if scene structure allows
	if get_parent().get_parent().has_method("_on_option_selected"):
		get_parent().get_parent()._on_option_selected(id)

func _on_try_again_pressed():
	AudioManager.play_click()
	hide_feedback()
	emit_signal("try_again")
	if get_parent().get_parent().has_method("_on_try_again"):
		get_parent().get_parent()._on_try_again()
