class_name CarController
extends RigidBody2D

@export var engine_power: float = 15000.0
@export var max_steer_angle: float = 35.0
@export var max_speed: float = 100.0
@export var steer_speed: float = 4.0
@export var brake_power: float = 800.0
@export var reverse_threshold: float = 10.0
@export var lateral_grip: float = 25.0
@export var min_turn_radius: float = 125.0

@export var wheel_fr: Sprite2D
@export var wheel_fl: Sprite2D
var _current_steer_angle: float = 0.0


func _ready() -> void:
	DebugLayer.add_debug_value('Engine Power', self, 'engine_power')
	DebugLayer.add_debug_value('Max Speed', self, 'max_speed')
	DebugLayer.add_debug_value('Max Steer Angle', self, 'max_steer_angle')
	DebugLayer.add_debug_value('Current Steer', self, '_current_steer_angle')
	DebugLayer.add_debug_value('Steer Speed', self, 'steer_speed')
	DebugLayer.add_debug_value('LateralGrip', self, 'lateral_grip')
	DebugLayer.add_debug_value('Min Turn Radius', self, 'min_turn_radius')


func _speed_scale(forward_speed: float) -> float:
	return clamp(forward_speed / max_speed, 0, 1)


func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate")
	var steering_input := Input.get_axis("steer_left", "steer_right")
	var brake_input := Input.get_action_strength("braking")

	var forward := transform.x
	var right_dir := transform.y

	var forward_speed := linear_velocity.dot(forward)
	var lateral_speed := linear_velocity.dot(transform.y)

	apply_central_force(forward * throttle * engine_power)

	linear_velocity -= right_dir * lateral_speed * clamp(lateral_grip * delta, 0.0, 1.0)

	_current_steer_angle = move_toward(_current_steer_angle, steering_input, steer_speed * delta)

	var desired_radius = min_turn_radius / max(abs(_current_steer_angle), 0.0001)
	angular_velocity = signf(_current_steer_angle) * (forward_speed / desired_radius)

	wheel_fr.rotation = deg_to_rad(max_steer_angle * _current_steer_angle)
	wheel_fl.rotation = deg_to_rad(max_steer_angle * _current_steer_angle)
