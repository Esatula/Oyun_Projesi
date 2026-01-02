extends Node2D

@onready var dialogue_ui = $CanvasLayer/UI
@onready var background = $Background
@onready var injured_person_area = $Areas/InjuredPerson
@onready var medkit_area = $Areas/Medkit

# State management
var is_intro_done = false
var has_diagnosed = false

func _ready():
	# Initial Setup
	injured_person_area.visible = false
	medkit_area.visible = false
	medkit_area.monitoring = false
	
	# Start Intro Sequence
	run_intro_sequence()

func run_intro_sequence():
	# Dialogue 1
	dialogue_ui.show_dialogue("Derse geç kalıyorum! Metro daha gelmedi...")
	await dialogue_ui.dialogue_advanced
	AudioManager.play_click()
	
	# Dialogue 2
	dialogue_ui.show_dialogue("Ben bir doktor adayıyım. İnsanlara yardım etmek istiyorum.")
	await dialogue_ui.dialogue_advanced
	AudioManager.play_click()
	
	# Reveal Injured Person
	injured_person_area.visible = true
	
	# Dialogue 3
	dialogue_ui.show_dialogue("Ah! Yardıma ihtiyacı olan biri var!")
	is_intro_done = true

func _on_injured_person_clicked():
	if not is_intro_done: return
	
	if not GameManager.has_examined_patient:
		# Start Examination Dialogue
		start_examination()

func start_examination():
	dialogue_ui.show_dialogue("Yaralı adama yaklaştım. Acı içinde görünüyor. Önce bilgi almalıyım.")
	show_examination_options()

func show_examination_options():
	var options = [
		{"text": "\"Geçmiş olsun, neyiniz var?\"", "id": "ask_condition"},
		{"text": "\"Parmaklarınızı oynatabiliyor musunuz?\"", "id": "check_mobility"},
		{"text": "\"Ağrı tam olarak nasıl?\"", "id": "ask_pain"},
		{"text": "[Teşhis Koy]", "id": "make_diagnosis"}
	]
	dialogue_ui.show_options(options)

func _on_medkit_clicked():
	if GameManager.has_examined_patient and has_diagnosed:
		GameManager.is_bag_open = true
		dialogue_ui.show_dialogue("Çantayı açtım. Yanık tedavisi için malzemeleri seçmeliyim.")
		show_medkit_options()

func show_medkit_options():
	var options = [
		{
			"text": "Üzerine tereyağı sür",
			"id": "butter",
			"feedback": "Sakın yapma! Tereyağı, diş macunu veya yoğurt sürmek ısıyı hapseder. Enfeksiyon riskini artırır."
		},
		{
			"text": "Su ile soğut ve kapat",
			"id": "cool_cover",
			"feedback": "" # Correct
		},
		{
			"text": "Elini salla",
			"id": "shake",
			"feedback": "Hayır! Yanmış bir bölgeyi sallamak dokulara daha fazla zarar verir ve acıyı artırır."
		}
	]
	dialogue_ui.show_options(options)

func _on_option_selected(option_id):
	AudioManager.play_click()
	
	match option_id:
		"ask_condition":
			dialogue_ui.show_dialogue("Yaralı: \"Metroyu bekliyordum... Dengemi kaybedip duvara çarptım. Kolumu çok sert sürttüm, yanıyor gibi hissediyorum!\"")
			await dialogue_ui.dialogue_advanced
			AudioManager.play_click()
			show_examination_options()
			
		"check_mobility":
			dialogue_ui.show_dialogue("Yaralı: \"Evet, parmaklarımı oynatabiliyorum. Bir kırık olduğunu sanmıyorum ama deri çok kötü acıyor.\"")
			await dialogue_ui.dialogue_advanced
			AudioManager.play_click()
			show_examination_options()
			
		"ask_pain":
			dialogue_ui.show_dialogue("Yaralı: \"Zonklama yok ama derim kavrulmuş gibi sızlıyor. Kıyafetim değdikçe canım çok yanıyor.\"")
			await dialogue_ui.dialogue_advanced
			AudioManager.play_click()
			show_examination_options()
		
		"make_diagnosis":
			show_diagnosis_options()
			
		"diagnose_burn":
			dialogue_ui.show_dialogue("Doğru tespit. Bu bir 'Sürtünme Yanığı'. Deri bütünlüğü bozulmuş ve enfeksiyon riski var.")
			has_diagnosed = true
			GameManager.has_examined_patient = true
			
			await dialogue_ui.dialogue_advanced
			AudioManager.play_click()
			
			dialogue_ui.show_dialogue("Hemen müdahale etmem gerekiyor. İlk Yardım Çantamı kullanmalıyım.")
			medkit_area.visible = true
			medkit_area.monitoring = true
			
		"diagnose_fracture":
			dialogue_ui.show_feedback("Kırık belirtileri (şekil bozukluğu, hareket kısıtlılığı) yok. Hasta parmaklarını oynatabiliyor. Tekrar düşün.")
			
		"diagnose_scratch":
			dialogue_ui.show_feedback("Bu basit bir çizikten fazlası. Deride geniş bir hasar ve yanma hissi var. Tekrar incele.")
			
		"cool_cover":
			dialogue_ui.show_dialogue("Harika! Yanığı temiz suyla soğutmak acıyı alır. Ardından enfeksiyonu önlemek için kapatmalıyız.")
			
			# Wait for user to read before changing scene
			await dialogue_ui.dialogue_advanced
			AudioManager.play_click()
			
			get_tree().change_scene_to_file("res://scenes/Treatment.tscn")
			
		"butter":
			dialogue_ui.show_feedback("Sakın yapma! Tereyağı, diş macunu veya yoğurt sürmek ısıyı hapseder. Enfeksiyon riskini artırır.")
			
		"shake":
			dialogue_ui.show_feedback("Hayır! Yanmış bir bölgeyi sallamak dokulara daha fazla zarar verir ve acıyı artırır.")
			
		"back_to_exam":
			start_examination()

func show_diagnosis_options():
	dialogue_ui.show_dialogue("Topladığım bilgilere göre teşhisim ne?")
	var options = [
		{"text": "Bu bir Yanık", "id": "diagnose_burn"},
		{"text": "Bu bir Kırık", "id": "diagnose_fracture"},
		{"text": "Bu basit bir Çizik", "id": "diagnose_scratch"},
		{"text": "[Geri Dön]", "id": "back_to_exam"}
	]
	dialogue_ui.show_options(options)
	
	# Add logic for back button in 'match option_id' locally or generically?
	# I need to add "back_to_exam" case in _on_option_selected.

# I missed updating _on_option_selected to handle "back_to_exam". 
# I will do a follow-up replace or try to fit it in if I can contextually match enough lines.
# The current replacement block covers _on_option_selected fully except the end.
# I'll just be careful to include it next time or extend this block if possible. 
# Wait, I am replacing existing functions entirely. I can add "back_to_exam" inside the match block above.

# Let me refine the ReplacementContent to include back_to_exam handling.

func _on_try_again():
	# Logic to return to the last decision point
	# Simple implementations: Check state and re-show options
	if not GameManager.has_examined_patient:
		start_examination() # Back to start of exam if calling try_again there
	elif not has_diagnosed:
		show_diagnosis_options()
	else:
		show_medkit_options()

# Input Event Handlers
func _on_injured_person_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_injured_person_clicked()

func _on_medkit_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_medkit_clicked()
