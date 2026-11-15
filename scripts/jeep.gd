extends CharacterBody3D

@export var acceleration := 16.0
@export var reverse_power := 8.0
@export var max_speed := 24.0
@export var steering_rate := 1.55
@export var friction := 7.0
var speed := 0.0
var steer := 0.0

func _physics_process(delta: float) -> void:
    var throttle := Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
    var turn := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    if throttle > 0.0:
        speed = move_toward(speed, max_speed, acceleration * delta)
    elif throttle < 0.0:
        speed = move_toward(speed, -max_speed * 0.35, reverse_power * delta)
    else:
        speed = move_toward(speed, 0.0, friction * delta)
    steer = move_toward(steer, turn, delta * 3.0)
    if abs(speed) > 0.4:
        rotate_y(-steer * steering_rate * delta * clamp(abs(speed)/8.0, 0.25, 1.0) * sign(speed))
    var forward := -global_transform.basis.z
    velocity.x = forward.x * speed
    velocity.z = forward.z * speed
    velocity.y -= 22.0 * delta
    move_and_slide()
