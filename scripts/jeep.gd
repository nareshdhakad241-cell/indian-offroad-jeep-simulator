extends CharacterBody3D

@export var acceleration: float = 16.0
@export var reverse_power: float = 8.0
@export var max_speed: float = 24.0
@export var steering_rate: float = 1.55
@export var rolling_friction: float = 3.5
@export var brake_power: float = 24.0

var speed: float = 0.0
var steer: float = 0.0

func _physics_process(delta: float) -> void:
    var throttle := Input.get_action_strength("ui_up")
    var reverse := Input.get_action_strength("ui_down")
    var brake := Input.get_action_strength("brake")
    var turn := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

    if brake > 0.0:
        speed = move_toward(speed, 0.0, brake_power * brake * delta)
    elif throttle > 0.0:
        speed = move_toward(speed, max_speed, acceleration * throttle * delta)
    elif reverse > 0.0:
        if speed > 0.5:
            speed = move_toward(speed, 0.0, brake_power * reverse * delta)
        else:
            speed = move_toward(speed, -max_speed * 0.35, reverse_power * reverse * delta)
    else:
        speed = move_toward(speed, 0.0, rolling_friction * delta)

    steer = move_toward(steer, turn, delta * 3.0)
    if abs(speed) > 0.4:
        var steering_factor: float = clampf(abs(speed) / 8.0, 0.25, 1.0)
        rotate_y(-steer * steering_rate * delta * steering_factor * sign(speed))

    var forward := -global_transform.basis.z
    velocity.x = forward.x * speed
    velocity.z = forward.z * speed
    if not is_on_floor():
        velocity.y -= 22.0 * delta
    else:
        velocity.y = -0.5

    move_and_slide()
