# Copyright (C) 2026 Elias Lucky.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>

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
