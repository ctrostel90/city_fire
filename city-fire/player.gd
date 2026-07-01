class_name player
extends RigidBody2D

@onready var left_wheel: Sprite2D = $front_wheel/left
@onready var right_wheel: Sprite2D = $front_wheel/right

## --- Tuning ---
@export var engine_power: float = 800.0
@export var brake_force: float = 600.0
@export var turn_speed: float = 2.0 # radians/sec
@export var friction: float = 0.95 # velocity damping (0-1)
@export var min_speed_to_turn: float = 20.0 # prevents spinning in place
@export var device_id: int = 0 # 0 = player 1, 1 = player 2

var steer_angle: float = 0.0


func _physics_process(delta: float) -> void:
	var throttle = Input.get_action_strength("accelerate", false)
	var brake = Input.get_action_strength("braking", false)
	var steer = Input.get_axis("steer_left", "steer_right")

	# --- Drive force ---
	# Push in the direction the body is currently facing
	var facing = transform.x
	if throttle > 0.0:
		apply_central_force(facing * throttle * engine_power)

	# --- Braking ---
	# Oppose current velocity directly
	if brake > 0.0:
		apply_central_force(-linear_velocity.normalized() * brake * brake_force)

	var speed = linear_velocity.length()
	var speed_factor = clamp(speed / 100.0, 0.0, 1.0)
	if speed > min_speed_to_turn:
		angular_velocity = steer * turn_speed * speed_factor
	# --- Friction ---
	# Bleed off lateral (sideways) velocity to prevent infinite sliding
	var lateral = transform.y * linear_velocity.dot(transform.y)
	linear_velocity -= lateral * (1.0 - friction)
