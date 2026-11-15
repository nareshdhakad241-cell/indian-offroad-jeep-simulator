extends Control

var steering_value: float = 0.0
var wheel_rotation: float = 0.0
var touch_active: bool = false
var touch_start_angle: float = 0.0

func _ready() -> void:
    add_to_group("steering_wheel")
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _process(delta: float) -> void:
    if not touch_active:
        steering_value = move_toward(steering_value, 0.0, delta * 2.8)
    wheel_rotation = lerp(wheel_rotation, steering_value * 0.95, minf(delta * 12.0, 1.0))
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    var center := size * 0.5
    if event is InputEventScreenTouch:
        if event.pressed:
            touch_active = true
            touch_start_angle = (event.position - center).angle()
            accept_event()
        else:
            touch_active = false
            accept_event()
    elif event is InputEventScreenDrag and touch_active:
        var current_angle: float = (event.position - center).angle()
        var delta_angle := wrapf(current_angle - touch_start_angle, -PI, PI)
        steering_value = clampf(delta_angle / 1.05, -1.0, 1.0)
        accept_event()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        touch_active = event.pressed
        if event.pressed:
            touch_start_angle = (event.position - center).angle()
        accept_event()
    elif event is InputEventMouseMotion and touch_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var current_angle: float = (event.position - center).angle()
        var delta_angle := wrapf(current_angle - touch_start_angle, -PI, PI)
        steering_value = clampf(delta_angle / 1.05, -1.0, 1.0)
        accept_event()

func _draw() -> void:
    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.43
    draw_circle(center, radius + 7.0, Color(0.02, 0.025, 0.022, 0.55))
    draw_arc(center, radius, 0.0, TAU, 72, Color(0.12, 0.14, 0.12), 18.0, true)
    draw_arc(center, radius, 0.0, TAU, 72, Color(0.72, 0.68, 0.49), 3.0, true)
    for i in range(3):
        var angle := wheel_rotation + float(i) * TAU / 3.0 - PI / 2.0
        var end_point := center + Vector2(cos(angle), sin(angle)) * radius * 0.78
        draw_line(center, end_point, Color(0.20, 0.22, 0.19), 12.0, true)
        draw_line(center, end_point, Color(0.72, 0.68, 0.49), 2.0, true)
    draw_circle(center, radius * 0.19, Color(0.12, 0.14, 0.12))
    draw_arc(center, radius * 0.19, 0.0, TAU, 48, Color(0.82, 0.76, 0.55), 3.0, true)
    draw_circle(center, radius * 0.07, Color(0.82, 0.76, 0.55))
