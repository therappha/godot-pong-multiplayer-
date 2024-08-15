extends Node2D
@onready var background_music = $"../BackgroundMusic"

@onready var host = $"../Host"
@onready var join = $"../Join"
@onready var starting_label = $"../StartingGameLabel"
@onready var start_timer = $"../Start_timer"

var timer_started : bool
@onready var start_game = $"../StartGame"
@onready var label_timer = $"../LabelTimer"
@onready var ipaddress = $"../Ipaddress"
@onready var port = $"../Port"
@onready var countdownsong = $"../countdownsong"
var peer
@export var player_scene : PackedScene
@export var ishost: bool
func _ready():
	multiplayer.peer_connected.connect(_peer_Connected)
	multiplayer.peer_disconnected.connect(_peer_Disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_Failed)
func _process(delta):
	if GameManager.game_over == true:
		background_music.playing = true
		timer_started = false
		starting_label.text = "Ready to start"
		$"..".show()
		GameManager.game_over = false
		if ishost:
				start_game.visible = true
	elif timer_started:
		starting_label.text= "Starting game in: " + str(int(label_timer.time_left) + 1)

@rpc("any_peer")
func SendPlayerInfo(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id]={
			"name": name,
			"id": id,
			"score": 0
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInfo.rpc(GameManager.Players[i].name, i)
	

func _disablebuttons():
	ipaddress.visible = false
	join.visible = false
	host.visible = false
	port.visible = false
	$"../Game Label2".visible = false
	
@rpc("any_peer","call_local")
func StartGame():

	var scene = preload("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	$"..".hide()
func _peer_Connected(id):
	print("Peer Connected id: " + str(id))
	if id != 1:
		starting_label.text ="Player Connected id:" + str(id)
		start_game.visible = true

func _peer_Disconnected(id):
	print("Peer Disconnected:  " +  str(id))
	
func _connected_to_server():
	print("Connected to server")	
	starting_label.text= "Connected to server as Player 1"
	SendPlayerInfo.rpc_id(1, "", multiplayer.get_unique_id())
func _connection_Failed():
	print("Couldnt Connect")
	starting_label.text = "Couldnt Connect"


func _on_host_pressed():
	ishost = true
	_disablebuttons()
	var hostport = int(port.get_text())	
	if port.get_text() == "":
		hostport = 5008	
	peer = ENetMultiplayerPeer.new()
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(hostport) 
	var error = peer.create_server( int(hostport), 2)
	if error != OK:
		print("Couldn't Create Server", str(error))
		starting_label.text = "Couldnt Create Server"
		return
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	starting_label.text = "Waiting for players"
	SendPlayerInfo(name,multiplayer.get_unique_id())



func _on_join_pressed():
	ishost = false
	_disablebuttons()
	var hostport = int(port.get_text())	
	if port.get_text() == "":
		hostport = 5008	
	var joinip = ipaddress.get_text()
	if joinip == "":
		joinip = "localhost"
			
	

	peer = ENetMultiplayerPeer.new()
	peer.create_client(joinip, hostport)
	multiplayer.set_multiplayer_peer(peer)

	
	
	

@rpc("any_peer","call_local")
func _on_start_game_pressed():
	start_timer.start()
	TimerLabel.rpc()
	start_game.visible = false

@rpc("any_peer","call_local")
func TimerLabel():
	timer_started = true
	label_timer.start()
	background_music.playing = false
	countdownsong.play()
		
	
	

@rpc("any_peer","call_local")
func _on_start_timer_timeout():
	StartGame.rpc()


