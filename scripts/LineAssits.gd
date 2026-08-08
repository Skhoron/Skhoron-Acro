extends Node3D

var enabled: bool = false
var gate_positions: Array[Vector3] = []
var line_mesh: MeshInstance3D

func _ready() -> void:
        _build_line_mesh()

func set_gates(gates: Array[Node3D]) -> void:
        gate_positions.clear()
        for g in gates:
                gate_positions.append(g.global_position)
        _update_line()

func _build_line_mesh() -> void:
        line_mesh = MeshInstance3D.new()
        add_child(line_mesh)
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0, 0.8, 1.0, 0.4)
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        line_mesh.material_override = mat

func _update_line() -> void:
        if gate_positions.size() < 2:
                return
        var arr_mesh = ArrayMesh.new()
        var verts = PackedVector3Array()
        for i in gate_positions.size() - 1:
                verts.append(gate_positions[i])
                verts.append(gate_positions[i + 1])
        var arrays = []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = verts
        arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
        line_mesh.mesh = arr_mesh

func set_enabled(val: bool) -> void:
        enabled = val
        line_mesh.visible = val