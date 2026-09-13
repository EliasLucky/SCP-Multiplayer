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

class_name RoundSettings
extends Resource

@export_group("Round")
@export var containment_zones : Array[ContainmentZone] = [];
@export var spawn_team_order : String = "4014313041341404134033434414";

## 0th index of teams array is expected to be Spectator team
## all other IDs in spawn_team_order are:
## 0 - scp, 1 - guard, 4 - cd, 3 - scientist, 2 - any custom team
@export var teams : Array[Team] = [];

@export var event_rounds : Array[RoundSettings] = [];

@export_group("Map")
@export var spawnwaves_enabled : bool = true;
@export_enum("600","480","300","180","120","60") var spawnwave_waiting_time : String = "300";
@export var lcz_decontamination_enabled : bool = true;
@export_enum("600","480","300") var lcz_decontamination_waiting_time : String = "600";
@export var hcz_decontamination_enabled : bool = false;
@export_enum("480","300") var hcz_decontamination_waiting_time : String = "300";
@export var can_activate_hcz_decontamination : bool = false;
@export var active_hcz_decontamination_only_on_biohazard : bool = true;

@export var ocz_enabled : bool = true;

@export var custom_map : PackedScene;
@export var custom_map_team_spawn : Array[TeamSpawn] = [];

@export_group("Warheads")
@export var omega_warhead_enabled : bool = true;
@export var alpha_warhead_enabled : bool = true;

@export_enum("180","120") var omega_warhead_waiting_time : String = "120";
@export_enum("180","120","90") var alpha_warhead_waiting_time : String = "90";

@export var omega_warhead_initial_detonation : bool = false;
@export var alpha_warhead_initial_detonation : bool = false;

@export_group("Infections")
@export var scp610_enabled : bool = true;
@export var scp008_enabled : bool = true;

#@export_group("SCPs")
#@export var disabled_scps_spawn : Array[TeamClass] = [];
#@export var scp610_from_scp_enabled : bool = true;

#@export_group("Events")
#@export var random_round_events_enabled : bool = true;
#@export var round_events : Array[RoundEvent] = [];
