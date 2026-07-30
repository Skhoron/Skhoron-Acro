extends Node

var gates: Array[Node3D] = []
var current_gate_index: int = 0
var gates_passed: int = 0
var missed_gates: int = 0

signal gate_passed(gate_index: int)
signal gate_missed(gate_index: int)
signal all_gates_complete

func _ready() -> void:
	_find_gates()

func _find_gates() -> void:
	for child in get_tree().get_nodes_in_group("gate"):
		gates.append(child)
	gates.sort_custom(func(a, b): return a.name < b.name)
	_highlight_next_gate()

func register_pass(gate_node: Node3D) -> void:
	var idx = gates.find(gate_node)
	if idx == current_gate_index:
		gates_passed += 1
		current_gate_index += 1
		emit_signal("gate_passed", idx)
		if current_gate_index >= gates.size():
			emit_signal("all_gates_complete")
		else:
			_highlight_next_gate()
	elif idx > current_gate_index:
		missed_gates += idx - current_gate_index
		emit_signal("gate_missed", current_gate_index)
		current_gate_index = idx + 1
		if current_gate_index < gates.size():
			_highlight_next_gate()

func _highlight_next_gate() -> void:
	for i in gates.size():
		var g = gates[i]
		if g.has_method("set_highlight"):
			g.set_highlight(i == current_gate_index)

func reset() -> void:
	current_gate_index = 0
	gates_passed = 0
	missed_gates = 0
	_highlight_next_gate()

func get_accuracy() -> float:
	var total = gates_passed + missed_gates
	if total == 0:
		return 1.0
	return float(gates_passed) / float(total)