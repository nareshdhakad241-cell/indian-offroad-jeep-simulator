extends Node3D

func _ready() -> void:
    _make_world()
    _make_jeep_visuals()
    _make_camera()
    _make_lighting()
    _make_ui()

func _make_world() -> void:
    var ground := StaticBody3D.new()
    ground.position.y = -0.6
    var mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(500, 500)
    mesh.mesh = plane
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.34, 0.29, 0.20)
    mat.roughness = 1.0
    mesh.material_override = mat
    ground.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(500, 1, 500)
    collision.shape = shape
    ground.add_child(collision)
    add_child(ground)

    for i in range(34):
        var hill := MeshInstance3D.new()
        var hmsh := CylinderMesh.new()
        hmsh.top_radius = randf_range(0.4, 3.0)
        hmsh.bottom_radius = randf_range(5.0, 13.0)
        hmsh.height = randf_range(8.0, 24.0)
        hmsh.radial_segments = 7
        hill.mesh = hmsh
        var hm := StandardMaterial3D.new()
        hm.albedo_color = [Color(0.37,0.34,0.26), Color(0.29,0.32,0.24), Color(0.43,0.37,0.27)][i % 3]
        hm.roughness = 1.0
        hill.material_override = hm
        hill.position = Vector3(randf_range(-100,100), hmsh.height * 0.35 - 0.5, randf_range(-120,120))
        hill.rotation.z = randf_range(-0.12,0.12)
        add_child(hill)

    var river := MeshInstance3D.new()
    var river_mesh := BoxMesh.new()
    river_mesh.size = Vector3(7, 0.12, 220)
    river.mesh = river_mesh
    var water := StandardMaterial3D.new()
    water.albedo_color = Color(0.12, 0.38, 0.48, 0.82)
    water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    water.roughness = 0.18
    river.material_override = water
    river.position = Vector3(28, -0.35, -25)
    river.rotation.y = 0.16
    add_child(river)

func _make_jeep_visuals() -> void:
    var jeep = get_node("Jeep")
    _box(jeep, Vector3(0,0.65,0), Vector3(2.2,0.65,3.6), Color(0.18,0.34,0.20))
    _box(jeep, Vector3(0,1.25,-0.15), Vector3(1.85,0.8,1.75), Color(0.13,0.25,0.16))
    _box(jeep, Vector3(0,1.28,0.78), Vector3(1.7,0.52,0.05), Color(0.08,0.12,0.13))
    _box(jeep, Vector3(0,0.72,1.86), Vector3(1.25,0.48,0.12), Color(0.08,0.08,0.07))
    for x in [-1.08,1.08]:
        for z in [-1.15,1.15]:
            var wheel := MeshInstance3D.new()
            var wm := CylinderMesh.new()
            wm.top_radius = 0.48
            wm.bottom_radius = 0.48
            wm.height = 0.28
            wm.radial_segments = 16
            wheel.mesh = wm
            wheel.rotation.z = PI/2
            wheel.position = Vector3(x,0.34,z)
            var rubber := StandardMaterial3D.new()
            rubber.albedo_color = Color(0.035,0.035,0.032)
            wheel.material_override = rubber
            jeep.add_child(wheel)
    var spare := MeshInstance3D.new()
    var sm := CylinderMesh.new()
    sm.top_radius = 0.42
    sm.bottom_radius = 0.42
    sm.height = 0.18
    spare.mesh = sm
    spare.rotation.x = PI/2
    spare.position = Vector3(0,0.85,1.92)
    var spare_mat := StandardMaterial3D.new()
    spare_mat.albedo_color = Color(0.035,0.035,0.032)
    spare.material_override = spare_mat
    jeep.add_child(spare)

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> void:
    var n := MeshInstance3D.new()
    var m := BoxMesh.new()
    m.size = size
    n.mesh = m
    n.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.85
    n.material_override = material
    parent.add_child(n)

func _make_camera() -> void:
    var camera := Camera3D.new()
    camera.name = "FollowCamera"
    camera.position = Vector3(0, 5.5, 9)
    camera.rotation_degrees = Vector3(-22, 0, 0)
    camera.current = true
    get_node("Jeep").add_child(camera)

func _make_lighting() -> void:
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.25
    add_child(sun)
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_SKY
    e.sky = Sky.new()
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.55,0.60,0.65)
    e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = e
    add_child(env)

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var label := Label.new()
    label.text = "OFFROAD 4x4  |  Touch controls"
    label.position = Vector2(20, 18)
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(label)
    _add_touch_button(layer, "◀", "ui_left", Vector2(35, 560))
    _add_touch_button(layer, "▶", "ui_right", Vector2(145, 560))
    _add_touch_button(layer, "BRAKE", "ui_down", Vector2(850, 560), Vector2(140, 90))
    _add_touch_button(layer, "GO", "ui_up", Vector2(1010, 560), Vector2(180, 110))

func _add_touch_button(parent: CanvasLayer, caption: String, action: String, pos: Vector2, button_size: Vector2 = Vector2(95, 90)) -> void:
    var button := Button.new()
    button.text = caption
    button.position = pos
    button.size = button_size
    button.add_theme_font_size_override("font_size", 22)
    button.modulate = Color(1, 1, 1, 0.82)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    parent.add_child(button)
