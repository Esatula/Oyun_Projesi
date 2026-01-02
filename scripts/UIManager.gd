extends Control

@onready var dialogue_box = $DialoguePanel
@onready var dialogue_label = $DialoguePanel/Label
@onready var options_container = $OptionsContainer
@onready var feedback_panel = $FeedbackPanel
@onready var feedback_label = $FeedbackPanel/Label
@onready var try_again_btn = $FeedbackPanel/TryAgainButton

signal option_chosen(id)
signal try_again

func _ready():
	options_container.visible = false
	feedback_panel.visible = false
	try_again_btn.connect("pressed", _on_try_again_pressed)
	
	# Apply Blue Theme to Dialogue Box
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.1, 0.4, 0.85) # Dark Blue
	style.border_color = Color(0.3, 0.6, 1.0) # Light blue border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	dialogue_box.add_theme_stylebox_override("panel", style)

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
		
		# Blue Theme for Buttons
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.0, 0.2, 0.6, 1.0) # slightly lighter blue
		btn_style.border_color = Color(1, 1, 1, 1)
		btn_style.set_border_width_all(2)
		btn_style.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		
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
	
	# Blue Theme for Feedback Panel
	var fb_style = StyleBoxFlat.new()
	fb_style.bg_color = Color(0.0, 0.1, 0.4, 0.9)
	fb_style.border_color = Color(1, 0, 0) # Red border for alert/feedback
	fb_style.set_border_width_all(3)
	fb_style.set_corner_radius_all(10)
	feedback_panel.add_theme_stylebox_override("panel", fb_style)
	
	feedback_label.text = text

func hide_feedback():
	feedback_panel.visible = false
	dialogue_box.visible = true

func _on_button_pressed(id):
	options_container.visible = false
	# Dialogue box will stay hidden until next show_dialogue call or manual reset
	emit_signal("option_chosen", id)
	# Also notify Main directly if scene structure allows
	if get_parent().get_parent().has_method("_on_option_selected"):
		get_parent().get_parent()._on_option_selected(id)

func _on_try_again_pressed():
	hide_feedback()
	emit_signal("try_again")
	if get_parent().get_parent().has_method("_on_try_again"):
		get_parent().get_parent()._on_try_again()
