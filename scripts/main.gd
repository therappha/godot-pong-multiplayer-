extends Node
var score := [0, 0]
@onready var winmusic = $Winmusic
@onready var winmusic2 = $Winmusic2
@onready var gameover = false
@onready var player_won = $CanvasLayer/ScoreLabels/PlayerWon
@onready var player1_score = $CanvasLayer/ScoreLabels/player1score
@onready var player2_score = $CanvasLayer/ScoreLabels/player2score
var score_win = 6
@onready var ballpoint = $Ballpoint
@export var player_scene : PackedScene	
func _ready():
	var index = 0
	for i in GameManager.Players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.Players[i].id)
		add_child(current_player)
		for spawn in  get_tree().get_nodes_in_group("PlayerSpawn"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
			index += 1
	StartBallTimer.rpc()
func _process(delta):
	player_win()
	
			
		
@rpc("call_local")
func StartBallTimer():
	$BallTimer.start()
func _on_ball_timer_timeout():
	$Ball.new_ball()

func _on_score_left_body_entered(body):
	if is_multiplayer_authority():
		update_score.rpc(true)
		


func _on_score_right_body_entered(body):
	if !is_multiplayer_authority():
		update_score.rpc(false)
@rpc("any_peer", "call_local")
func update_score(add_to_left):
	if add_to_left:
		score[1] += 1
		player2_score.text = str(score[1])
		$BallTimer.start()
		ballpoint.play()
	else:
		score[0] += 1
		player1_score.text = str(score[0])
		$BallTimer.start()
		ballpoint.play()



func player_win():
	if gameover:
		return
	if score[0] == score_win:
		winmusic2.playing = true
		winmusic.playing = true
		$BallTimer.stop()
		gameover = true
		player_won.text = "Player 1 WON"
	elif score[1] == score_win:
		winmusic2.playing = true
		winmusic.playing = true
		player_won.text = "Player 2 WON"
		$BallTimer.stop()
		gameover = true
		

func _on_winmusic_finished():
	GameManager.game_over = true
	queue_free()

	pass
	
	
	
