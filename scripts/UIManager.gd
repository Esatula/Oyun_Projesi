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

func show_dialogue(text: String):
	dialogue_label.text = text

func show_options(options: Array):
	options_container.visible = true
	# Clear existing buttons
	for child in options_container.get_children():
		child.queue_free()
	
	# Create new buttons
	for opt in options:
		var btn = Button.new()
		# Minimum size for horizontal layout
		btn.custom_minimum_size = Vector2(200, 150)
		
		# If image is provided in option dict, set it
		# Doing a simple text + icon layout
		if opt.has("icon_path"):
			var icon_texture = load(opt["icon_path"])
			if icon_texture:
				btn.icon = icon_texture
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				btn.expand_icon = true
		
		btn.text = opt["text"]
		btn.connect("pressed", func(): _on_button_pressed(opt["id"]))
		options_container.add_child(btn)

func show_feedback(text: String):
	options_container.visible = false
	dialogue_box.visible = false
	feedback_panel.visible = true
	feedback_label.text = text

func hide_feedback():
	feedback_panel.visible = false
	dialogue_box.visible = true

func _on_button_pressed(id):
	options_container.visible = false
	emit_signal("option_chosen", id)
	# Also notify Main directly if scene structure allows
	if get_parent().get_parent().has_method("_on_option_selected"):
		get_parent().get_parent()._on_option_selected(id)

func _on_try_again_pressed():
	hide_feedback()
	emit_signal("try_again")
	if get_parent().get_parent().has_method("_on_try_again"):
		get_parent().get_parent()._on_try_again()
