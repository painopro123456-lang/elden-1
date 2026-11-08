extends Control

@onready var status_label: Label = $Status

func _ready() -> void:
	$Menu/GrandPrix.pressed.connect(_on_grand_prix_pressed)
	$Menu/TimeTrial.pressed.connect(_on_time_trial_pressed)
	$Menu/Settings.pressed.connect(_on_settings_pressed)

func _on_grand_prix_pressed() -> void:
	status_label.text = "GRAND PRIX MODE IS BEING BUILT — NO PLACEHOLDER RACE."

func _on_time_trial_pressed() -> void:
	status_label.text = "TIME TRIAL MODE IS PLANNED FOR THE FIRST PLAYABLE BUILD."

func _on_settings_pressed() -> void:
	status_label.text = "GRAPHICS AND CONTROL SETTINGS WILL BE ADDED BEFORE RELEASE."
