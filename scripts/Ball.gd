extends CharacterBody2D
var righthit: bool
var lefthit: bool
var starthit = true
var win_size : Vector2
const START_SPEED : int = 200
const ACCEL : int = 10
var speed : int
var dir : Vector2
const MAX_Y_VECTOR : float = 0.6
@onready var ballplayer = $"../Ballplayer"
@onready var ballpoint = $"../Ballpoint"
const minscale = Vector2(1, 1)  
var mid_point: Vector2
var maxscale = Vector2(4, 4)
var is_scaling: bool = true 
var hitgorundsound: bool
var scale_speed: float = 1.0  
var scale_time: float = 0.0
@onready var ballsprite = $Ballsprite
@onready var ballground = $"../ballground"

func _ready():
	win_size = get_viewport_rect().size
	mid_point = win_size / 2
	if ballground:
		ballground.stop()

@rpc("any_peer", "call_local")
func new_ball():
	position.x = win_size.x / 2
	position.y = randi_range(200, win_size.y - 200)
	speed = START_SPEED
	dir = random_direction()
	rpc("update_ball_position", position, dir)

func _physics_process(delta):
	var distance_to_mid = position.distance_to(mid_point)
	var max_distance = mid_point.length()
	var ballscale = 1.0 - (distance_to_mid / max_distance)
	ballscale = clamp(ballscale, 0, 1)
	ballsprite.scale = minscale.lerp(maxscale, ballscale)
	
	if is_scaling:
		scale_time += delta * scale_speed
	else:
		scale_time += delta * -scale_speed
	scale_time = clamp(scale_time, 0, 1)
	scale = minscale.lerp(maxscale, scale_time)
	
	if scale_time == 0.0 or scale_time == 1.0:
		is_scaling = not is_scaling
	speed += delta
	translate(speed * delta * dir)
	
	if scale_time == 0:
		play_ballground()
		
	if is_multiplayer_authority():
		if lefthit || starthit: 
				rpc("update_ball_position", position, dir)
		var collision = move_and_collide(dir * speed * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("PlayerGroup"):
					if collider.position.x == 1084:
						starthit = false
						righthit = true
						lefthit = false
						speed = min(speed + ACCEL, 700) 
						dir = new_direction(collider)
						dir = dir.bounce(collision.get_normal())
						ballplaysound.rpc()
						rpc("update_ball_position", position, dir)
			
			dir = dir.bounce(collision.get_normal())
			ballplaysound.rpc()
			position += dir * delta * 10
	else:
		if righthit:
			rpc("update_ball_position", position, dir)
		var collision = move_and_collide(dir * speed * delta)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("PlayerGroup"):
					if collider.position.x == 50:
						starthit = false
						lefthit = true
						righthit = false
						speed = min(speed + ACCEL, 550) 
						dir = new_direction(collider)
						dir = dir.bounce(collision.get_normal())
						ballplaysound.rpc()
						rpc("update_ball_position", position, dir)
				
@rpc("any_peer","call_local")
func ballplaysound():
	ballplayer.play()
@rpc("call_remote")
func random_direction() -> Vector2:
	var new_dir := Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()
@rpc("authority", "call_remote")
func new_direction(collider) -> Vector2:
	var ball_y = position.y
	var pad_y = collider.position.y
	var dist = ball_y - pad_y
	var new_dir := Vector2()
	new_dir.x = -dir.x
	new_dir.y = (dist / (collider.p_height / 2)) * MAX_Y_VECTOR
	return new_dir.normalized()

@rpc("unreliable")
func update_ball_position(new_position: Vector2, new_dir: Vector2):
	position = new_position
	dir = new_dir
func play_ballground():
	if ballground:
		ballground.play()
