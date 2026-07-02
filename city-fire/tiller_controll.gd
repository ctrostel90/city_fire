class_name TillerController
extends RigidBody2D
## TillerRearController2D.gd
##
## Controls the REAR tiller (trailer) unit of a top-down 2D articulated
## tiller truck. This unit has no engine -- it's towed via a joint
## connected to the front tractor unit -- but its own wheels can be
## steered independently, like a real "tillerman" steering the rear axle
## to help the long vehicle take corners.

@export_group("Steering")
@export var max_steer_angle: float = 40.0 # rear tiller wheels often turn sharper
@export var steer_speed: float = 4.5
@export var turn_torque: float = 2500.0
@export var invert_steering: bool = true # true = countersteer relative to front, common on real tillers

@export_group("Grip")
@export var lateral_grip: float = 10.0 # how strongly sideways sliding is cancelled

@export_group("Stability")
@export var yaw_damping: float = 6.0 # resists excess spin so the long trailer doesn't fishtail

@export_group("Wheel Visuals (optional)")
@export var sprite_rl: Node2D
@export var sprite_rr: Node2D

var _current_steer_angle: float = 0.0


func _physics_process(delta: float) -> void:
	_handle_steering(delta)
	_apply_lateral_grip(delta)
	_apply_yaw_damping()


func _forward_dir() -> Vector2:
	return transform.x


func _handle_steering(delta: float) -> void:
	var steer_input := Input.get_axis("tiller_left", "tiller_right")
	if invert_steering:
		steer_input = -steer_input
	var target_angle := steer_input * max_steer_angle
	_current_steer_angle = move_toward(_current_steer_angle, target_angle, steer_speed * max_steer_angle * delta)

	sprite_rl.rotation = deg_to_rad(_current_steer_angle)
	sprite_rr.rotation = deg_to_rad(_current_steer_angle)

	var forward_dir := _forward_dir()
	var forward_speed := linear_velocity.dot(forward_dir)
	var steer_ratio := _current_steer_angle / max_steer_angle
	var speed_sign := signf(forward_speed) if abs(forward_speed) > 0.1 else 1.0
	apply_torque(steer_ratio * turn_torque * speed_sign)


func _apply_lateral_grip(delta: float) -> void:
	var forward_dir := _forward_dir()
	var right_dir := forward_dir.orthogonal()
	var lateral_speed := linear_velocity.dot(right_dir)
	linear_velocity -= right_dir * lateral_speed * clamp(lateral_grip * delta, 0.0, 1.0)


func _apply_yaw_damping() -> void:
	# Counteracts excess spin to keep the long trailer from whipping around
	# behind the tractor unit.
	apply_torque(-angular_velocity * yaw_damping)
