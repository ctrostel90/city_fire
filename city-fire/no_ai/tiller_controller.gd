class_name TillerController
extends RigidBody2D

@export var engine_power: float = 6000.0
@export var max_steer_angle: float = 35.0
@export var steer_speed: float = 4.0
@export var brake_power: float = 800.0
@export var reverse_threshold: float = 10.0
@export var lateral_grip: float = 25.0
@export var min_turn_radius: float = 125.0

@export var wheel_fr: Sprite2D
@export var wheel_fl: Sprite2D
var _current_steer_angle: float = 0.0


func _ready() -> void:
	DebugLayer.add_debug_value('Tiller Engine Power', self, 'engine_power')
	DebugLayer.add_debug_value('Tiller Max Steer Angle', self, 'max_steer_angle')
	DebugLayer.add_debug_value('Tiller Current Steer', self, '_current_steer_angle')
	DebugLayer.add_debug_value('Tiller Steer Speed', self, 'steer_speed')
	DebugLayer.add_debug_value('Tiller LateralGrip', self, 'lateral_grip')
	DebugLayer.add_debug_value('Tiller Min Turn Radius', self, 'min_turn_radius')


func _physics_process(delta: float) -> void:
	var steering_input := Input.get_axis("tiller_right", "tiller_left")
	var brake_input := Input.get_action_strength("braking")

	var forward := transform.x
	var right_dir := transform.y

	var forward_speed := linear_velocity.dot(forward)
	var lateral_speed := linear_velocity.dot(transform.y)

	linear_velocity -= right_dir * lateral_speed * clamp(lateral_grip * delta, 0.0, 1.0)

	_current_steer_angle = move_toward(_current_steer_angle, steering_input, steer_speed * delta)

	var desired_radius = min_turn_radius / max(abs(_current_steer_angle), 0.0001)
	angular_velocity = signf(_current_steer_angle) * (forward_speed / desired_radius)

	wheel_fr.rotation = deg_to_rad(_current_steer_angle * max_steer_angle)
	wheel_fl.rotation = deg_to_rad(_current_steer_angle * max_steer_angle)
