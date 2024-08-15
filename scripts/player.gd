extends StaticBody2D
#1082, 324 for player 2 position
#50, 324 player 1
var win_height : int 
var p_height : int
@onready var multiplayersync = $MultiplayerSynchronizer
@onready var chat_box = $chat_box
@onready var chat_text = $chat_text
@onready var chat_timer = $chat_timer
@onready var chat_text2 = $chat_text2

func _input(event):
	if multiplayersync.get_multiplayer_authority() == multiplayer.get_unique_id():
		if event.is_action_pressed("enter") && chat_box.visible == false:
			chat_box.focus_mode = Control.FOCUS_ALL
			chat_box.visible = true
			call_deferred("deferred_grab_focus")
func _ready():
	win_height = get_viewport_rect().size.y
	p_height = $ColorRect.get_size().y
	multiplayersync.set_multiplayer_authority(str(name).to_int())
	add_to_group("PlayerGroup")
	
	
func _process(delta):
	
	if multiplayersync.get_multiplayer_authority() == multiplayer.get_unique_id():
		var mousepos = get_viewport().get_mouse_position().y
		position.y = mousepos
		position.y = clamp(position.y, p_height / 2, win_height - p_height / 2)
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	

@rpc("any_peer","call_local")
func _on_chat_timer_timeout():
	chat_text.visible = false
	chat_text2.visible = false

@rpc("any_peer","call_local")
func Chatlabel(text):
	chat_text.text = text
	chat_text.visible = true 
	chat_timer.start()
	chat_text2.text = text
	chat_text2.visible = true 

		


func _on_chat_box_text_submitted(new_text):
	if multiplayersync.get_multiplayer_authority() == multiplayer.get_unique_id():
		chat_text.text = chat_box.get_text()
		chat_text2.text = chat_box.get_text()
		chat_box.visible = false
		Chatlabel.rpc(chat_box.get_text())
		chat_box.text = ""
		chat_box.release_focus()
func deferred_grab_focus():
	chat_box.grab_focus()
