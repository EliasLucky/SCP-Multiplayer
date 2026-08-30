class_name ProgressionRank
extends Resource

@export var level : int
@export var max_exp : int

@export var progression_conditions : Array[ProgressionCondition]

@export var abilities : Array[Ability]

#@export var script_node : PackedScene

func serialize() -> Dictionary:
	return {
		"level": level,
		"max_exp": max_exp,
		"progression_conditions": _serialize_progression_conditions(),
		"abilities": _serialize_abilities()
	}

func _serialize_progression_conditions() -> Array[Dictionary]:
	var data = [];
	for i in range(0,progression_conditions.size()-1):
		data.append(progression_conditions[i].serialize());
	return data;

func _serialize_abilities() -> Array[Dictionary]:
	var data = [];
	for i in range(0,abilities.size()-1):
		data.append(inst_to_dict(abilities[i]));
	return data;
