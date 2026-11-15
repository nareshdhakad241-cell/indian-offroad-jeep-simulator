extends Node3D

const UI_BASE := Vector2(1280.0, 720.0)

func _ready() -> void:
    randomize()
    _make_world()
    _make_jeep_visuals()
    _make_camera()
    _make_lighting()
    _make_ui()

func _make_world() -> void:
    var ground := StaticBody3D.new()
    ground.position.y = -0.65
    var mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(650, 650)
    mesh.mesh = plane
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.30, 0.25, 0.17)
    mat.roughness = 1.0
    mesh.material_override = mat
    ground.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(650, 1, 650)
    collision.shape = shape
    ground.add_child(collision)
    add_child(ground)

    # Layered mountain silhouettes around the playable valley.
    for i in range(46):
        var hill := MeshInstance3D.new()
        var hill_mesh := CylinderMesh.new()
        hill_mesh.top_radius = randf_range(0.2, 2.0)
        hill_mesh.bottom_radius = randf_range(8.0, 22.0)
        hill_mesh.height = randf_range(16.0, 38.0)
        hill_mesh.radial_segments = 8
        hill.mesh = hill_mesh
        var hill_mat := StandardMaterial3D.new()
        hill_mat.albedo_color = [Color(0.27, 0.30, 0.24), Color(0.38, 0.34, 0.27), Color(0.31, 0.29, 0.24)][i % 3]
        hill_mat.roughness = 1.0
        hill.material_override = hill_mat
        hill.position = Vector3(randf_range(-145, 145), hill_mesh.height * 0.38 - 0.5, randf_range(-155, 155))
        hill.rotation.z = randf_range(-0.15, 0.15)
        add_child(hill)

    # A winding dirt track made from connected road sections.
    var road_mat := StandardMaterial3D.new()
    road_mat.albedo_color = Color(0.22, 0.18, 0.13)
    road_mat.roughness = 1.0
    for i in range(18):
        var road := MeshInstance3D.new()
        var road_mesh := BoxMesh.new()
        road_mesh.size = Vector3(9.0, 0.10, 22.0)
        road.mesh = road_mesh
        road.material_override = road_mat
        road.position = Vector3(sin(float(i) * 0.32) * 13.0, -0.08, -float(i) * 18.0)
        road.rotation.y = sin(float(i) * 0.32) * 0.16
        add_child(road)

    # River and banks.
    var river := MeshInstance3D.new()
    var river_mesh := BoxMesh.new()
    river_mesh.size = Vector3(7, 0.12, 240)
    river.mesh = river_mesh
    var water := StandardMaterial3D.new()
    water.albedo_color = Color(0.10, 0.34, 0.43)
    water.roughness = 0.2
    water.metallic = 0.08
    river.material_override = water
    river.position = Vector3(34, -0.34, -55)
    river.rotation.y = 0.16
    add_child(river)

    # Scattered original low-poly trees and rocks along the valley.
    for i in range(52):
        var x := randf_range(-90.0, 90.0)
        var z := randf_range(-150.0, 110.0)
        if absf(x) < 10.0:
            continue
        _make_tree(Vector3(x, -0.55, z), randf_range(0.75, 1.35))
    for i in range(45):
        var rock := MeshInstance3D.new()
        var rock_mesh := SphereMesh.new()
        rock_mesh.radius = randf_range(0.35, 1.1)
        rock_mesh.height = rock_mesh.radius * 1.2
        rock.mesh = rock_mesh
        var rock_mat := StandardMaterial3D.new()
        rock_mat.albedo_color = Color(0.30, 0.29, 0.26)
        rock_mat.roughness = 1.0
        rock.material_override = rock_mat
        rock.position = Vector3(randf_range(-85, 85), -0.25, randf_range(-145, 100))
        rock.scale = Vector3(1.4, 0.75, 1.1)
        add_child(rock)

func _make_tree(pos: Vector3, tree_scale: float) -> void:
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.12
    trunk_mesh.bottom_radius = 0.22
    trunk_mesh.height = 2.2
    trunk.mesh = trunk_mesh
    var trunk_mat := StandardMaterial3D.new()
    trunk_mat.albedo_color = Color(0.22, 0.14, 0.08)
    trunk.material_override = trunk_mat
    trunk.position = pos + Vector3(0, 1.1 * tree_scale, 0)
    trunk.scale = Vector3.ONE * tree_scale
    add_child(trunk)

    var crown := MeshInstance3D.new()
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.25
    crown_mesh.height = 2.7
    crown.mesh = crown_mesh
    var crown_mat := StandardMaterial3D.new()
    crown_mat.albedo_color = Color(0.13, 0.25, 0.12)
    crown_mat.roughness = 1.0
    crown.material_override = crown_mat
    crown.position = pos + Vector3(0, 2.65 * tree_scale, 0)
    crown.scale = Vector3(1.0, 1.15, 1.0) * tree_scale
    add_child(crown)

func _make_jeep_visuals() -> void:
    var jeep: Node3D = get_node("Jeep")
    var body_color := Color(0.19, 0.30, 0.16)
    var dark := Color(0.045, 0.055, 0.05)
    var glass := Color(0.10, 0.19, 0.21)
    _box(jeep, Vector3(0, 0.70, 0), Vector3(2.25, 0.62, 3.75), body_color)
    _box(jeep, Vector3(0, 1.30, -0.22), Vector3(1.92, 0.92, 1.90), body_color)
    _box(jeep, Vector3(0, 1.35, 0.76), Vector3(1.72, 0.60, 0.06), glass)
    _box(jeep, Vector3(0, 1.35, -1.18), Vector3(1.72, 0.58, 0.06), glass)
    for x in [-0.91, 0.91]:
        _box(jeep, Vector3(x, 1.35, -0.20), Vector3(0.06, 0.78, 1.78), body_color)
        _box(jeep, Vector3(x, 0.88, 0), Vector3(0.18, 0.20, 3.45), dark)
    _box(jeep, Vector3(0, 0.68, -1.94), Vector3(2.32, 0.24, 0.20), dark)
    _box(jeep, Vector3(0, 0.68, 1.94), Vector3(2.32, 0.24, 0.20), dark)
    _box(jeep, Vector3(0, 0.88, -1.91), Vector3(1.15, 0.42, 0.08), dark)
    for x in [-0.72, 0.72]:
        _box(jeep, Vector3(x, 0.98, -2.00), Vector3(0.36, 0.24, 0.08), Color(0.92, 0.82, 0.48))
        _box(jeep, Vector3(x, 0.60, -2.00), Vector3(0.34, 0.14, 0.08), Color(0.65, 0.08, 0.04))
    for x in [-1.12, 1.12]:
        for z in [-1.22, 1.22]:
            _make_wheel(jeep, Vector3(x, 0.40, z))
    _make_wheel(jeep, Vector3(0, 0.95, 2.02), true)
    _box(jeep, Vector3(0, 0.34, 0), Vector3(1.75, 0.18, 2.6), dark)

func _make_wheel(parent: Node3D, pos: Vector3, spare: bool = false) -> void:
    var wheel := MeshInstance3D.new()
    var wheel_mesh := CylinderMesh.new()
    wheel_mesh.top_radius = 0.49
    wheel_mesh.bottom_radius = 0.49
    wheel_mesh.height = 0.34
    wheel_mesh.radial_segments = 24
    wheel.mesh = wheel_mesh
    wheel.rotation.z = PI / 2.0
    if spare:
        wheel.rotation.x = PI / 2.0
        wheel.rotation.z = 0.0
    wheel.position = pos
    var rubber := StandardMaterial3D.new()
    rubber.albedo_color = Color(0.025, 0.028, 0.026)
    rubber.roughness = 1.0
    wheel.material_override = rubber
    parent.add_child(wheel)

    var hub := MeshInstance3D.new()
    var hub_mesh := CylinderMesh.new()
    hub_mesh.top_radius = 0.22
    hub_mesh.bottom_radius = 0.22
    hub_mesh.height = 0.36
    hub_mesh.radial_segments = 16
    hub.mesh = hub_mesh
    hub.rotation = wheel.rotation
    hub.position = pos
    var hub_mat := StandardMaterial3D.new()
    hub_mat.albedo_color = Color(0.42, 0.43, 0.40)
    hub.material_override = hub_mat
    parent.add_child(hub)

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.82
    node.material_override = material
    parent.add_child(node)

func _make_camera() -> void:
    var camera := Camera3D.new()
    camera.name = "FollowCamera"
    camera.position = Vector3(0, 6.2, 10.5)
    camera.rotation_degrees = Vector3(-24, 0, 0)
    camera.current = true
    camera.fov = 72.0
    get_node("Jeep").add_child(camera)

func _make_lighting() -> void:
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.35
    sun.shadow_enabled = true
    add_child(sun)
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.55, 0.60, 0.65)
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.ssao_enabled = true
    env.environment = environment
    add_child(env)

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var title := Label.new()
    title.text = "INDIAN OFFROAD JEEP SIMULATOR"
    title.position = Vector2(22, 16)
    title.add_theme_font_size_override("font_size", 22)
    title.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78))
    layer.add_child(title)

    var splash := Control.new()
    splash.name = "StartupSplash"
    splash.set_anchors_preset(Control.PRESET_FULL_RECT)
    splash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(splash)

    var backdrop := ColorRect.new()
    backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
    backdrop.color = Color(0.035, 0.055, 0.045, 0.97)
    splash.add_child(backdrop)

    var emblem := Label.new()
    emblem.text = "4×4"
    emblem.set_anchors_preset(Control.PRESET_CENTER)
    emblem.position = Vector2(-100, -110)
    emblem.size = Vector2(200, 100)
    emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    emblem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    emblem.add_theme_font_size_override("font_size", 64)
    emblem.add_theme_color_override("font_color", Color(0.82, 0.76, 0.48))
    splash.add_child(emblem)

    var splash_title := Label.new()
    splash_title.text = "INDIAN OFFROAD JEEP SIMULATOR"
    splash_title.set_anchors_preset(Control.PRESET_CENTER)
    splash_title.position = Vector2(-360, 5)
    splash_title.size = Vector2(720, 56)
    splash_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    splash_title.add_theme_font_size_override("font_size", 28)
    splash_title.add_theme_color_override("font_color", Color(0.96, 0.94, 0.86))
    splash.add_child(splash_title)

    var splash_subtitle := Label.new()
    splash_subtitle.text = "EXPLORE • CLIMB • CONQUER"
    splash_subtitle.set_anchors_preset(Control.PRESET_CENTER)
    splash_subtitle.position = Vector2(-260, 60)
    splash_subtitle.size = Vector2(520, 34)
    splash_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    splash_subtitle.add_theme_font_size_override("font_size", 16)
    splash_subtitle.add_theme_color_override("font_color", Color(0.66, 0.70, 0.60))
    splash.add_child(splash_subtitle)

    get_tree().create_timer(2.0).timeout.connect(splash.queue_free)

    # Four independent touch buttons: Android multi-touch lets steering,
    # accelerator and brake be held with separate fingers.
    _add_touch_button(layer, "◀", "ui_left", Vector2(24, -126, 112, -28), Control.PRESET_BOTTOM_LEFT)
    _add_touch_button(layer, "▶", "ui_right", Vector2(132, -126, 220, -28), Control.PRESET_BOTTOM_LEFT)
    _add_touch_button(layer, "BRAKE", "brake", Vector2(-226, -122, -118, -28), Control.PRESET_BOTTOM_RIGHT)
    _add_touch_button(layer, "RACE", "ui_up", Vector2(-112, -142, -20, -20), Control.PRESET_BOTTOM_RIGHT)

func _add_touch_button(parent: CanvasLayer, caption: String, action: String, offsets: Vector4, preset: Control.LayoutPreset) -> void:
    var button := Button.new()
    button.text = caption
    button.set_anchors_preset(preset)
    button.offset_left = offsets.x
    button.offset_top = offsets.y
    button.offset_right = offsets.z
    button.offset_bottom = offsets.w
    button.add_theme_font_size_override("font_size", 23)
    button.add_theme_color_override("font_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color(1.0, 0.82, 0.35))
    button.add_theme_stylebox_override("normal", _button_style(Color(0.08, 0.12, 0.10, 0.82)))
    button.add_theme_stylebox_override("pressed", _button_style(Color(0.28, 0.36, 0.22, 0.95)))
    button.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.22, 0.15, 0.9)))
    button.focus_mode = Control.FOCUS_NONE
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    parent.add_child(button)

func _button_style(color: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.corner_radius_top_left = 18
    style.corner_radius_top_right = 18
    style.corner_radius_bottom_left = 18
    style.corner_radius_bottom_right = 18
    style.border_width_left = 2
    style.border_width_right = 2
    style.border_width_top = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.72, 0.68, 0.48, 0.8)
    return style
