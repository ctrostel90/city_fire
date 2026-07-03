class_name FireEngineController
extends RigidBody2D
## TractorFrontController2D.gd
##
## Controls the FRONT tractor/cab unit of a top-down 2D articulated tiller
## truck: throttle (accelerate / brake / reverse) and front-wheel steering.
##
## Assumes a top-down view: gravity_scale should be 0 on this body, and the
## sprite/mesh should face "up" (-Y) at rotation 0. Grip is simulated by
## cancelling the sideways (lateral) velocity component each frame, which is
## the standard trick for arcade-style top-down vehicle handling.
##
## Expected Input Map actions (Project Settings > Input Map):
##   accelerate, brake, reverse, steer_left, steer_right

@export_group("Engine")
@export var engine_force: float = 2000.0 # forward push
@export var reverse_force: float = 1000.0 # reverse push
@export var brake_force: float = 3000.0 # braking force
@export var max_forward_speed: float = 500.0 # px/s soft cap
@export var max_reverse_speed: float = 200.0 # px/s soft cap
@export var rolling_resistance: float = 0.4 # coasting drag factor

@export_group("Steering")
@export var max_steer_angle: float = 30.0 # degrees, for front-wheel visuals only
@export var steer_speed: float = 4.0 # visual angle interpolation speed
@export var turn_torque: float = 4000.0 # yaw torque strength while moving
@export var steering_speed_scale: float = 100.0
@export_group("Grip")
@export var lateral_grip: float = 10.0 # how strongly sideways sliding is cancelled (0 = ice, high = glued)

@export_group("Wheel Visuals (optional)")
@export var sprite_fl: Node2D
@export var sprite_fr: Node2D

@export_group("Self-Alignment")
@export var angular_damping: float = 3.0 # bleeds off leftover spin
@export var align_strength: float = 800.0 # weathervanes heading toward velocity direction
@export var align_min_speed: float = 20.0 # only align above this speed, so parking-lot turns aren't fought

var _current_steer_angle: float = 0.0


func _physics_process(delta: float) -> void:
	_handle_steering(delta)
	_apply_self_alignment(delta)
	_handle_throttle()
	_apply_lateral_grip(delta)


func _forward_dir() -> Vector2:
	return Vector2.UP.rotated(rotation)


func _handle_steering(delta: float) -> void:
	var steer_input := Input.get_axis("steer_left", "steer_right")
	var target_angle := steer_input * max_steer_angle
	_current_steer_angle = move_toward(_current_steer_angle, target_angle, steer_speed * max_steer_angle * delta)

	sprite_fl.rotation = deg_to_rad(_current_steer_angle)
	sprite_fr.rotation = deg_to_rad(_current_steer_angle)

	var forward_speed := linear_velocity.dot(_forward_dir())
	var steer_ratio := _current_steer_angle / max_steer_angle
	# var speed_sign := signf(forward_speed) if abs(forward_speed) > 0.1 else 1.0
	var speed_sign := 1.0
	var speed_factor := clampf(linear_velocity.length() / steering_speed_scale, 0.0, 1.0)
	apply_torque(steer_ratio * turn_torque * speed_factor)


func _apply_self_alignment(_delta: float) -> void:
	apply_torque(-angular_velocity * angular_damping)
	var speed := linear_velocity.length()
	if speed > align_min_speed:
		var travel_dir := linear_velocity.normalized()
		var angle_diff := transform.x.angle_to(travel_dir)
		apply_torque(angle_diff * align_strength)


func _handle_throttle() -> void:
	var forward_dir := transform.x
	var forward_speed := linear_velocity.dot(forward_dir)

	if Input.is_action_pressed("accelerate") and forward_speed < max_forward_speed:
		apply_central_force(forward_dir * engine_force)
	elif Input.is_action_pressed("braking_tiller") and forward_speed > -max_reverse_speed:
		apply_central_force(-forward_dir * reverse_force)
	elif Input.is_action_pressed("braking") and abs(forward_speed) > 0.1:
		apply_central_force(-sign(forward_speed) * forward_dir * brake_force)
	else:
		apply_central_force(-linear_velocity * mass * rolling_resistance * 0.1)


func _apply_lateral_grip(delta: float) -> void:
	var forward_dir := transform.x
	var right_dir := forward_dir.orthogonal()
	var lateral_speed := linear_velocity.dot(right_dir)
	# Cancel the sideways component so the truck doesn't skate around like a puck.
	linear_velocity -= right_dir * lateral_speed * clamp(lateral_grip * delta, 0.0, 1.0)
