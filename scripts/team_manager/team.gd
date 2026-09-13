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

class_name Team
extends Resource

@export_group("General")
## team_id is used in RoundSettings spawn_team_order
@export var team_id : int = 0;
@export var team_name : String = "";
@export var team_primary_color : Color = Color.WHITE;
@export var team_secondary_color : Color = Color.WHITE;

@export var team_direction_one : String = "";
@export var team_direction_two : String = "";
@export var team_direction_three : String = "";

## e.g. team MTF. classes MTF Commander, MTF Liutenant, etc.
## team does not need to have classes but it can though.
@export var classes : Array[TeamClass] = [];

@export var friendly_teams : Array[Team] = [];

## Items that will be applied to player inventory after he spawned as this team.
## If classess are present then the inventory_data from TeamClass classes will be used.
@export var inventory_data : Array[ItemData] = [];

# NOTE: It was planned as an abilities system for SCPs
# NOTE: At the same time it would be applied to non SCPs.
# e.g. ClassD would have ShyGuyViewer ability which means ClassD team players can trigger SCP-096.
@export_group("Rank and Ability System")
@export var use_ranks : bool = false;
@export var ranks : Array[ProgressionRank] = [];
@export var abilities : Array[Ability] = [];

@export_group("Player Stats")
@export var custom_walk_speed : int = -1;
@export var custom_sprint_speed : int = -1;
@export var custom_jump_velocity : int = -1;
@export var can_walk : bool = true;
@export var can_sprint : bool = true;
@export var can_jump : bool = true;
@export var can_crouch : bool = true;

@export var custom_health : float = -1.0;
@export var custom_max_health : float = -1.0;
@export var custom_stamina : float = -1.0;
@export var custom_max_stamina : float = -1.0;

@export var player_model : String = "";

@export_group("Custom HUD")
@export var hud : String = "";

@export_group("Escapee")
@export var escapee : bool = false;
@export var escaped_spawn_team : Team
@export var escaped_spawn_class : TeamClass
@export var count_escape_as_classd : bool = false;
@export var count_escape_as_foundation : bool = false;

@export_group("Spawnwave")
@export var initial_spawn_enabled : bool = false;
@export var spawnwave : bool = false;
@export var unit_of : String = "";

@export_group("Spawnwave Properties")
@export var spawn_for_biohazard : bool = false;
@export var spawn_for_firehazard : bool = false;
@export var spawn_for_reinforcements : bool = false;

@export_group("Spawnwave Altering")
@export var spawn_biohazard : bool = false;
@export var spawn_firehazard : bool = false;
@export var spawn_reinforcements : bool = false;

@export_group("Infection Team Type")
@export var scp008 : bool = false;
@export var scp610 : bool = false;
@export var zombie : bool = false;

func serialize() -> Dictionary:
	return {
		"name": team_name,
		"primary_color": team_primary_color,
		"secondary_color": team_secondary_color,
		"direction_one": team_direction_one,
		"direction_two": team_direction_two,
		"direction_three": team_direction_three,
	}
