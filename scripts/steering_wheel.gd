extends Control

var steering_value: float = 0.0
var wheel_rotation: float = 0.0
var touch_active: bool = false
var active_touch_index: int = -1
var touch_start_angle: float = 0.0

func _ready() -> void:
    add_to_group("steering_wheel")
    # Do not capture touch events: accelerator/brake controls must receive
    # their own finger events while the steering finger remains active.
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func _process(delta: float) -> void:
    if not touch_active:
        steering_value = move_toward(steering_value, 0.0, delta * 2.8)
    wheel_rotation = lerp(wheel_rotation, steering_value * 0.95, minf(delta * 12.0, 1.0))
    queue_redraw()

func _input(event: InputEvent) -> void:
    var center: Vector2 = size * 0.5
    var to_local: Transform2D = get_global_transform_with_canvas().affine_inverse()

    if event is InputEventScreenTouch:
        var local_pos: Vector2 = to_local * event.position
        if event.pressed:
            if not touch_active and Rect2(Vector2.ZERO, size).has_point(local_pos):
                touch_active = true
                active_touch_index = event.index
                touch_start_angle = (local_pos - center).angle()
        elif touch_active and event.index == active_touch_index:
            touch_active = false
            active_touch_index = -1

    elif event is InputEventScreenDrag and touch_active and event.index == active_touch_index:
        var local_pos: Vector2 = to_local * event.position
        var current_angle: float = (local_pos - center).angle()
        var delta_angle: float = wrapf(current_angle - touch_start_angle, -PI, PI)
        steering_value = clampf(delta_angle / 1.05, -1.0, 1.0)

    # Mouse support for desktop testing; screen-touch events above are never
    # consumed, allowing independent simultaneous accelerator/brake presses.
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        var local_pos: Vector2 = to_local * event.position
        touch_active = event.pressed and Rect2(Vector2.ZERO, size).has_point(local_pos)
        if touch_active:
            touch_start_angle = (local_pos - center).angle()
    elif event is InputEventMouseMotion and touch_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var local_pos: Vector2 = to_local * event.position
        var current_angle: float = (local_pos - center).angle()
        var delta_angle: float = wrapf(current_angle - touch_start_angle, -PI, PI)
        steering_value = clampf(delta_angle / 1.05, -1.0, 1.0)

func _draw() -> void:
    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.43
    draw_circle(center, radius + 7.0, Color(0.02, 0.025, 0.022, 0.55))
    draw_arc(center, radius, 0.0, TAU, 72, Color(0.12, 0.14, 0.12), 18.0, true)
    draw_arc(center, radius, 0.0, TAU, 72, Color(0.72, 0.68, 0.49), 3.0, true)
    for i in range(3):
        var angle: float = wheel_rotation + float(i) * TAU / 3.0 - PI / 2.0
        var end_point: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * 0.78
        draw_line(center, end_point, Color(0.20, 0.22, 0.19), 12.0, true)
        draw_line(center, end_point, Color(0.72, 0.68, 0.49), 2.0, true)
    draw_circle(center, radius * 0.19, Color(0.12, 0.14, 0.12))
    draw_arc(center, radius * 0.19, 0.0, TAU, 48, Color(0.82, 0.76, 0.55), 3.0, true)
    draw_circle(center, radius * 0.07, Color(0.82, 0.76, 0.55))
