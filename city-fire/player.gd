class_name player
extends RigidBody2D

@export var wheel_base := 64
@export var engine_power := 900
@export var steering_limits := Vector2(-45, 45)

var steering_angle := 15.0
var acceleration := Vector2.ZERO
var friction := -55
var drag = -0.06
var steer_direction
var braking := -450.0
var max_speed_reverse := 250

@onready var left_wheel: Sprite2D = $front_wheel/left
@onready var right_wheel: Sprite2D = $front_wheel/right


func _ready() -> void:
	gravity_scale = 0


func _physics_process(delta: float) -> void:
	get_input()
	#apply_friction(delta)


func apply_friction(delta):
	return
	#if acceleration == Vector2.ZERO and velocity.length() < 50:
	#	velocity = Vector2.ZERO
	#var friction_force = velocity * friction * delta
	#var drag_force = velocity * velocity.length() * drag * delta
	#acceleration += drag_force + friction_force


func get_input() -> void:
	var dir := Input.get_axis("steer_left", "steer_right") # / 2.0 + 0.5
	steer_direction = dir * deg_to_rad(steering_angle)
	left_wheel.rotation = steer_direction
	right_wheel.rotation = steer_direction
	if Input.is_action_pressed("accelerate"):
		apply_central_force(Vector2.from_angle(steer_direction) * engine_power)
	if Input.is_action_pressed("braking"):
		acceleration = transform.x * braking


func calculate_steering(delta):
	return
	#var rear_wheel := position - transform.x * wheel_base / 2.0
	#var front_wheel := position + transform.x * wheel_base / 2.0
	#rear_wheel += velocity * delta
	#front_wheel += velocity.rotated(steer_direction) * delta
	#var new_heading := (front_wheel - rear_wheel).normalized()
	#var direction := new_heading.dot(velocity.normalized())
	#if direction > 0:
	#	velocity = new_heading * velocity.length()
	#else:
	#	velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	#rotation = new_heading.angle()
