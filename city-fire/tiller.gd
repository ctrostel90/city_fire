class_name Tiller
extends RigidBody2D

## --- Tuning ---
@export var engine_power: float = 800.0
@export var brake_force: float = 600.0
@export var turn_speed: float = 2.0 # radians/sec
@export var friction: float = 0.95 # velocity damping (0-1)
@export var min_speed_to_turn: float = 20.0 # prevents spinning in place
@export var device_id: int = 0 # 0 = player 1, 1 = player 2

var max_steer_angle: float = 25.0

@onready var left_wheel: Sprite2D = $rear_wheel/left
@onready var right_wheel: Sprite2D = $rear_wheel/right


func _physics_process(delta: float) -> void:
	var steer := Input.get_axis("tiller_right", "tiller_left")

	# rotation of sprites
	left_wheel.rotation_degrees = steer * max_steer_angle
	right_wheel.rotation_degrees = steer * max_steer_angle
	var speed = linear_velocity.length()
	var speed_factor = clamp(speed / 100.0, 0.0, 1.0)
	if speed > min_speed_to_turn:
		angular_velocity = steer * turn_speed * speed_factor
	# --- Friction ---
	# Bleed off lateral (sideways) velocity to prevent infinite sliding
	var lateral = transform.y * linear_velocity.dot(transform.y)
	# linear_velocity -= lateral * (1.0 - friction)
