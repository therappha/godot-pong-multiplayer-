extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var game_scene: PackedScene
@onready var joinip = "localhost"
var port = 5008
var ishost: bool
var host_id: int = -1 
@rpc
func _rpc_change_scene():
	print("Changing scene to: ", game_scene.resource_path)
	var new_scene = game_scene.instance()
	if new_scene:
		get_tree().change_scene_to(new_scene)
	else:
		print("Failed to load the scene.")


func request_scene_change():
	if ishost:
		_rpc_change_scene()  
	else:
		if host_id != -1:
			rpc_id(host_id, "_rpc_request_scene_change")  
			print("Host ID not yet assigned or known.")


@rpc
func _rpc_request_scene_change():
	if ishost:
		_rpc_change_scene() 
func _on_host_pressed():
	ishost = true
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(port)
	
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	print("Host started with authority")

func _on_join_pressed():
	ishost = false
	peer.create_client(joinip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	print("Client started and connecting")
	request_scene_change()  # 

func _on_peer_connected(id):
	if ishost:
		print("New peer connected with ID:", id)
		if id == peer.get_unique_id():
			_assign_control(id) 
			host_id = id  
			print("Control assigned to host with ID:", id)
	else:
		if id == peer.get_unique_id():
			_assign_control(2)  
			print("Control assigned to client with ID:", id)

func _assign_control(id):
	var player = get_node(str(id))
	if player:
		player.set_process_input(true)
		print("Assigned control to player with ID:", id)
	else:
		print("Player node not found for ID:", id)
