extends Control

@onready var play: Button = $AspectRatioContainer/HSplitContainer/VBoxContainer/Play
@onready var credits_text: RichTextLabel = $AspectRatioContainer/HSplitContainer/CreditsText
@onready var exit: Button = $AspectRatioContainer/HSplitContainer/VBoxContainer/Exit


func _on_credits_pressed() -> void:
		if credits_text.is_visible_in_tree():
			credits_text.hide()
		else:
			credits_text.show()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
