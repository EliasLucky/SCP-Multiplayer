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

class_name RoundSystem
extends Node

@export var default_round_settings : RoundSettings
var round_settings : RoundSettings

@export var map_generator : MapGenerator

var teams_spawn_points : Array[TeamSpawn] = [];
var spawned_required_classes : Array[TeamClass] = [];
var spawn_amount_classes : Dictionary = {};

var players : Dictionary
var players_on_teams : Dictionary = {};
var players_awaiting_spawn : Dictionary = {};

var spawnwave_teams : Array[Team] = [];
var spawnwave_teams_choice : Array[Team] = [];
var spawnwave_teams_biohazard : Array[Team] = [];
var spawnwave_teams_firehazard : Array[Team] = [];
var spawnwave_teams_reinforcements : Array[Team] = [];
var _selected_spawnwave_team : Team;
var previous_spawnwave_team : Team;

var zones_decontamination_process : Array[Dictionary] = [];

# NOTE: Was planned as if there is SCP-008 in HCZ then allow manual decontamination process launch from special room.
var hcz_decontamination_biohazard : bool = false;

enum RoundState {
	INTERMISSION,LOADING,ON_GOING,FINISH,LOCKED,
}

class RoundStats:
	var spawned_class_ds : int
	var spawned_researchers : int
	var spawned_scps : int
	var escaped_class_ds : int
	var escaped_researchers : int
	var terminated_scps : int
	
	var omega_warhead_detonated : bool
	var alpha_warhead_detonated : bool
	
	func to_dictionary() -> Dictionary:
		var dictionary = {};
		dictionary["spawned_class_ds"] = spawned_class_ds;
		dictionary["spawned_researchers"] = spawned_researchers;
		dictionary["spawned_scps"] = spawned_scps;
		dictionary["escaped_class_ds"] = escaped_class_ds;
		dictionary["escaped_researchers"] = escaped_researchers;
		dictionary["terminated_scps"] = terminated_scps;
		dictionary["omega_warhead_detonated"] = omega_warhead_detonated;
		dictionary["alpha_warhead_detonated"] = alpha_warhead_detonated;
		return dictionary;

var current_round_state : RoundState = RoundState.INTERMISSION;

var round_stats : RoundStats

## NOTE: It's just a test. Usually, you would set up multiplayer and make player join there.
@export var test_player : Player

func _ready() -> void:
	GlobalTimers.spawnwave_timer_timeout.connect(_connect_spawnwave_timer_timeout);
	GlobalTimers.spawnwave_timer_animation_start.connect(_connect_spawnwave_timer_animation_start);
	GlobalTimers.lcz_decontamination_timer_timeout.connect(_connect_lcz_decontamination_timer_timeout);
	GlobalTimers.hcz_decontamination_timer_timeout.connect(_connect_hcz_decontamination_timer_timeout);
	#GlobalTimers.lcz_prevent_stalling_timer_timeout.connect(_connect_lcz_prevent_stalling_timer_timeout);
	GlobalTimers.omega_warhead_detonation_timer_timeout.connect(_connect_omega_warhead_detonation_timer_timeout);
	GlobalTimers.alpha_warhead_detonation_timer_timeout.connect(_connect_alpha_warhead_detonation_timer_timeout);
	
	_on_player_added(123456, test_player)


var time_counter = 0;
var round_counter = 0;

func _process(delta) -> void:
	if current_round_state == RoundState.INTERMISSION:
		time_counter += 1 * delta;
		if time_counter > 8:
			time_counter = 0;
			attempt_start_round(true);

func _physics_process(_delta) -> void:
	if zones_decontamination_process.size() > 0:
		for i in range(0,zones_decontamination_process.size()):
			var data = zones_decontamination_process[i];
			_check_and_damage_players_in_area(data.x_min,data.x_max,data.z_min,data.z_max,data.y_min,data.y_max,data.reason,data.message,false,data.damage);

func attempt_start_round(force : bool = false) -> void:
	#if players.size() >= 1 and force:
	current_round_state = RoundState.LOADING;
	
	_check_for_random_round();
	
	players_awaiting_spawn = players;
	
	if not round_stats:
		round_stats = RoundStats.new();
	
	round_stats.spawned_class_ds = 0;
	round_stats.spawned_researchers = 0;
	round_stats.spawned_scps = 0;
	round_stats.escaped_class_ds = 0;
	round_stats.escaped_researchers = 0;
	round_stats.terminated_scps = 0;
	round_stats.omega_warhead_detonated = false;
	round_stats.alpha_warhead_detonated = false;
	
	if round_settings.custom_map:
		_load_custom_map();
	else:
		_generate_containment_zones();
	
	#_update_players_intermission_status_ui("Generation complete.");
	
	_prepare_spawnwave_teams();
	
	#_hide_player_intermission_ui(players[players.keys()[0]])
	_spawn_teams();
	
	current_round_state = RoundState.ON_GOING;
	
	if round_settings.spawnwaves_enabled:
		GlobalTimers.start_spawnwave_timer(int(round_settings.spawnwave_waiting_time));
	if round_settings.lcz_decontamination_enabled:
		GlobalTimers.start_lcz_decontamination_timer(int(round_settings.lcz_decontamination_waiting_time) + GlobalTimers.lcz_decontamination_wait_before_activation);
	if round_settings.hcz_decontamination_enabled:
		GlobalTimers.start_lcz_decontamination_timer(int(round_settings.hcz_decontamination_waiting_time) + GlobalTimers.hcz_decontamination_wait_before_activation);
	if round_settings.omega_warhead_initial_detonation:
		GlobalTimers.start_omega_warhead_detonation_timer(int(round_settings.omega_warhead_detonation_waiting_time));
	if round_settings.alpha_warhead_initial_detonation:
		GlobalTimers.start_omega_warhead_detonation_timer(int(round_settings.alpha_warhead_detonation_waiting_time));
#else:
	#	_update_players_intermission_status_ui("Waiting for more players...\n(min players required: 3)");

## NOTE: After 3 rounds there is 50/50 change for an special EVENT round to start.
func _check_for_random_round():
	if round_counter > 3:
		if randi_range(0,1) == 1:
			round_settings = default_round_settings.event_rounds[randi_range(0,default_round_settings.event_rounds.size())];
		
			#_update_players_intermission_event_ui("EVENT ROUND");
			
			round_counter = 0;
			return;
		#else:
		#	round_settings = default_round_settings;
		#	
		#	_update_players_intermission_event_ui("");
		
		round_counter = 0;
	
	round_settings = default_round_settings;
	#_update_players_intermission_event_ui("");

func _load_custom_map():
	print("Loading custom map.");
	#_update_players_intermission_status_ui("Loading custom map.");
	
	var map = round_settings.custom_map.instantiate();
	map.global_position = Vector3(0,20,0);
	map_generator.add_child(map);
	
	teams_spawn_points = round_settings.custom_map_team_spawn;

func _generate_containment_zones():
	for i in range(0,round_settings.containment_zones.size()):
		print("Generating " + round_settings.containment_zones[i].zone_name);
		#_update_players_intermission_status_ui("Generating " + round_settings.containment_zones[i].zone_name);
		
		map_generator.generate_containment_zone(round_settings.containment_zones[i]);
		
		teams_spawn_points.append_array(map_generator.get_containment_zone_spawn_points(round_settings.containment_zones[i]));

func _prepare_spawnwave_teams() -> void:
	for i in range(0,round_settings.teams.size()):
		if round_settings.teams[i].spawnwave:
			if round_settings.teams[i].unit_of != "" and not spawnwave_teams.any(func(element): return element.unit_of == round_settings.teams[i].unit_of):
				spawnwave_teams_choice.append(round_settings.teams[i]);
			
			if round_settings.teams[i].unit_of == "":
				spawnwave_teams_choice.append(round_settings.teams[i]);
			
			spawnwave_teams.append(round_settings.teams[i]);
			
			if round_settings.teams[i].spawn_on_biohazard:
				spawnwave_teams_biohazard.append(round_settings.teams[i]);
			if round_settings.teams[i].spawn_on_firehazard:
				spawnwave_teams_firehazard.append(round_settings.teams[i]);
			if round_settings.teams[i].spawn_on_reinforcements:
				spawnwave_teams_reinforcements.append(round_settings.teams[i]);

func _spawn_teams() -> void:
	for i in range(0,len(round_settings.spawn_team_order)):
		if players_awaiting_spawn.is_empty():
			break;
		
		var team = _check_if_team_enabled(round_settings.teams, int(round_settings.spawn_team_order[i]));
		if team:
			var index = randi_range(0,players_awaiting_spawn.keys().size()-1);
			var key = players_awaiting_spawn.keys()[index];
			_spawn_player(players_awaiting_spawn[key], team);
			players_awaiting_spawn.erase(key);
	
	if players_awaiting_spawn.size() > 0:
		_spawn_teams();

func _check_if_team_enabled(teams : Array[Team], team_id : int) -> Team:
	for i in range(0,teams.size()):
		if teams[i].team_id == team_id and teams[i].initial_spawn_enabled:
			return teams[i];
	return null;

#func _prepare_spawnwave_animations() -> void:
#	for i in range(0,spawnwave_teams.size()):
#		var spawnwave_animation = map_generator.get_node_or_null(spawnwave_teams[i].name + "spawnwave_animation");
#		if spawnwave_animation:
#			spawnwave_animation.animation_finished.connect(_on_spawnwave_animation_finished);

#func _clear_spawnwave_animations() -> void:
#	for i in range(0,spawnwave_teams.size()):
#		var spawnwave_animation = map_generator.get_node_or_null(spawnwave_teams[i].name + "spawnwave_animation");
#		if spawnwave_animation:
#			spawnwave_animation.animation_finished.disconnect();


func _connect_spawnwave_timer_timeout() -> void:
	for i in range(players_awaiting_spawn.keys().size(),0):
		var key = players_awaiting_spawn.keys()[i];
		var player = players_awaiting_spawn[key];
		_spawn_player(player, _selected_spawnwave_team);
		
		players_awaiting_spawn.erase(key);
	
	_selected_spawnwave_team = null;

func _connect_spawnwave_timer_animation_start() -> void:
	_selected_spawnwave_team = spawnwave_teams[randi_range(0,spawnwave_teams.size())];
	_selected_spawnwave_team = _get_appropriate_spawnwave_team(_selected_spawnwave_team);
	
	var spawnwave_animation = map_generator.get_node_or_null(_selected_spawnwave_team.name + "spawnwave_animation");
	if spawnwave_animation:
		spawnwave_animation.get_node("AnimationPlayer").play("appear");
		spawnwave_animation.get_node("AnimationPlayer").queue("disappear");

func _get_appropriate_spawnwave_team(selected_team : Team) -> Team:
	var return_team : Team;
	
	var allowed_teams : Dictionary = {};
	allowed_teams.default = true;
	
	var allow_team = allowed_teams.keys()[randi_range(0,allowed_teams.keys().size())]
	if allow_team.b7:
		if spawnwave_teams_biohazard.size() > 0:
			return_team = _get_return_spawnwave_team(selected_team, spawnwave_teams_biohazard);
			if not return_team and selected_team.unit_of == "":
				if selected_team.spawn_on_biohazard:
					return_team = selected_team;
	if allow_team.e9:
		if spawnwave_teams_firehazard.size() > 0:
			return_team = _get_return_spawnwave_team(selected_team, spawnwave_teams_firehazard);
	if allow_team.nu7:
		if spawnwave_teams_reinforcements.size() > 0:
			return_team = _get_return_spawnwave_team(selected_team, spawnwave_teams_reinforcements);
			
	if allow_team.default:
		if selected_team.unit_of != "":
			var array = [];
			for i in range(0,spawnwave_teams.size()):
				if not spawnwave_teams[i].spawn_on_biohazard and not spawnwave_teams[i].spawn_on_firehazard and not spawnwave_teams[i].spawn_on_reinforcements:
					if selected_team.unit_of == spawnwave_teams[i].unit_of:
						array.append(spawnwave_teams[i]);
			
			return_team = array[randi_range(0,array.size())];
	
	if selected_team.unit_of == "" and not return_team:
		return_team = selected_team;
	
	return return_team;

func _get_return_spawnwave_team(selected_team : Team, spawnwave_teams_array : Array[Team]) -> Team:
	var return_team : Team
	
	if selected_team.unit_of != "":
		while selected_team.unit_of != return_team.unit_of:
			return_team = spawnwave_teams_array[randi_range(0,spawnwave_teams_array.size())];
	
	return return_team;

func _spawn_player(player, team : Team, team_class : TeamClass = null):
	var selected_class = team_class;
	
	if not team_class and team.classes.size() > 0:
		for i in range(0,team.classes.size()):
			if team.classes[i].spawn_only_once:
				if not spawned_required_classes.has(team.classes[i]):
					selected_class = team.classes[i];
					break;
				else:
					continue;
			if team.classes[i].spawn_amount > spawn_amount_classes[team.classes[i]]:
				spawn_amount_classes[team.classes[i]] += 1;
				
				selected_class = team.classes[i];
				break;
	
	if not selected_class and team.classes.size() > 0:
		selected_class = team.classes[randi_range(0,team.classes.size()-1)];
	
	var team_class_spawn_points = [];
	var team_spawn_points = [];
	for i in range(0,teams_spawn_points.size()):
		if teams_spawn_points[i].team.team_id != team.team_id:
			continue;
		
		if selected_class and teams_spawn_points[i].team_class:
			if selected_class == teams_spawn_points[i].team_class:
				team_class_spawn_points.append(teams_spawn_points[i]);
		else:
			team_spawn_points.append(teams_spawn_points[i]);
	
	var selected_spawn_point;
	if selected_class:
		selected_spawn_point = team_class_spawn_points[randi_range(0,team_class_spawn_points.size()-1)];
		
	else:
		selected_spawn_point = team_spawn_points[randi_range(0,team_spawn_points.size()-1)];

	players_on_teams[team] = player;
	
	player.position = selected_spawn_point.position;
	
	player.player_team = team;
	player.player_team_class = selected_class;

func _get_team_and_or_class(team_of_classes : Team, teams : Array[Team], classes : Array[TeamClass]) -> Dictionary:
	var result = {};
	result.team = null;
	result.team_class = null;
	
	if teams.size() > 0:
		result.team = teams[randi_range(0,teams.size()-1)];
		
		if result.team.classes.size() > 0:
			result.team_class = result.team.classes[randi_range(0,result.team.classes.size()-1)];
		else:
			result.team_class = classes
	else:
		if classes.size() > 0:
			result.team = team_of_classes;
			result.team_class = classes[randi_range(0,classes.size()-1)];
	
	return result;


func _on_player_added(network_id : int, player : Player):
	players[network_id] = player;
	players_awaiting_spawn[network_id] = player;
	
	# assign spectator team
	player.player_team = default_round_settings.teams[0];
	
	#_update_players_info_player_added(players.size(), player);
	
	#if current_round_state != RoundState.INTERMISSION and current_round_state != RoundState.LOADING:
	#	_give_player_team_ui(player,player.player_team);

func _on_player_removed(network_id : int, player : Player):
	if players_awaiting_spawn.has(network_id):
		players_awaiting_spawn.erase(network_id);
	
	players.erase(network_id);
	
	#_update_players_info_player_added(players.size(), player);
	
	if player.player_team != round_settings.teams[0]:
		# kill the player if he is present in-game
		#_player_killed(network_id, player, player.player_team, "", "");
		
		if current_round_state == RoundState.ON_GOING:
			_check_the_winner();

func _connect_lcz_decontamination_timer_timeout(prevent_stalling : bool = false):
	var lcz = _find_containment_zone_by_id(0);
	if lcz:
		map_generator.decontaminate_containment_zone(lcz);
		var data = {
			x_min = lcz.zone_offset.x,
			x_max = lcz.zone_offset.x + lcz.grid_width,
			z_min = lcz.zone_offset.y,
			z_max = lcz.zone_offset.y + lcz.grid_height,
			y_min = lcz.zone_y_position,
			y_max = lcz.zone_y_position + 50,
			damage = 20,
			reason = "",
			message = ""
		}
		zones_decontamination_process.append(data);
		if prevent_stalling:
			_check_and_damage_players_in_area(data.x_min, data.x_max, data.z_min, data.z_max, data.y_min, data.y_max, data.reason, "", true);
			#_check_and_kill_players_in_area(lcz.zone_offset,lcz.zone_offset + lcz.grid_width,lcz.zone_y_position,lcz.zone_y_position+50, "DECONTAMINATED", "Subject was found dead in the Light Containment Zone. Presumably, the cause is the Light Containment Zone decontamination protocol. It seems to be that the subject has failed to evacuate properly before the decontamination was started.");
	var ocz = _find_containment_zone_by_id(1);
	if ocz:
		map_generator.decontaminate_containment_zone(ocz);
		var data = {
			x_min = ocz.zone_offset.x,
			x_max = ocz.zone_offset.x + ocz.grid_width,
			z_min = ocz.zone_offset.y,
			z_max = ocz.zone_offset.y + ocz.grid_height,
			y_min = ocz.zone_y_position,
			y_max = ocz.zone_y_position + 50,
			damage = 20,
			reason = "DECONTAMINED",
			message = ""
		}
		zones_decontamination_process.append(data);
		if prevent_stalling:
			_check_and_damage_players_in_area(data.x_min, data.x_max, data.z_min, data.z_max, data.y_min, data.y_max, data.reason, "", true)
			#_check_and_kill_players_in_area(ocz.zone_offset,ocz.zone_offset + ocz.grid_width,ocz.zone_y_position,ocz.zone_y_position+50, "DECONTAMINATED", "");
	
	if current_round_state == RoundState.ON_GOING:
		_check_the_winner();

func _connect_hcz_decontamination_timer_timeout():
	var hcz = _find_containment_zone_by_id(2);
	
	if hcz:
		map_generator.decontaminate_containment_zone(hcz);
		var data = {
			x_min = hcz.zone_offset.x,
			x_max = hcz.zone_offset.x + hcz.grid_width,
			z_min = hcz.zone_offset.y,
			z_max = hcz.zone_offset.y + hcz.grid_height,
			y_min = hcz.zone_y_position,
			y_max = hcz.zone_y_position + 50,
			damage = 20,
			reason = "DECONTAMINATED",
			message = ""
		}
		zones_decontamination_process.append(data);
		_check_and_damage_players_in_area(data.x_min, data.x_max, data.z_min, data.z_max, data.y_min, data.y_max, data.reason, data.message, true);
	
	if current_round_state == RoundState.ON_GOING:
		_check_the_winner();


func _find_containment_zone_by_id(zone_id : int) -> ContainmentZone:
	for i in range(0,round_settings.zones.size()):
		if round_settings.zones[i].zone_id == zone_id:
			return round_settings.zones[i];
	
	return null;


func _check_and_damage_players_in_area(x_min : int, x_max : int, z_min : int, z_max : int, y_min : int, y_max : int, reason : String, message : String, kill : bool, damage : float = 0.0):
	pass
	#var players = [];
	
	#for i in range(0,players.keys().size()):
	#	var network_id = players.keys()[i];
	#	var player = players[network_id];
	#	if player.player_team != round_settings.teams[0]:
	#		if player.global_position.x >= x_min and player.global_position.x <= x_max \
	#			and player.global_position.z >= z_min and player.global_position.z <= z_max \
	#			and player.global_position.y >= y_min and player.global_position.y <= y_max:
	#			if kill:
	#				print("kill player")
	#				#_player_killed(network_id, player, player.team, reason, message, true);
	#			else:
	#				player.take_damage(damage);


func _connect_omega_warhead_detonation_timer_timeout() -> void:
	_check_and_damage_players_in_area(-500,500,-500,500,-100,250, "SUBJECT HAS BEEN TERMINATED", "Nothing was found from the subject. Presumably, the subject was killed during the Omega Warhead detonation.", false)
	
	if current_round_state == RoundState.ON_GOING:
		_check_the_winner();

func _connect_alpha_warhead_detonation_timer_timeout() -> void:
	_check_and_damage_players_in_area(-500,500,-500,500,250,400, "SUBJECT HAS BEEN TERMINATED", "Nothing was found from the subject. Presumably, the subject was killed during the Alpha Warhead detonation.", false)
	
	GlobalTimers.spawnwave_timer.stop();
	GlobalTimers.spawnwave_timer.wait_time = -1;
	
	if current_round_state == RoundState.ON_GOING:
		_check_the_winner();



func _check_the_winner() -> void:
	var winning_team;
	var winning_color;
	
	###
	
	if winning_team:
		end_round(winning_team, winning_color);

func end_round(winner : String, winner_color : Color) -> void:
	current_round_state = RoundState.FINISH;
	
	round_counter += 1;
	
	GlobalTimers.stop_spawnwave_timer();
	
	if winner:
		print(winner)
		# show winner screen to all players
	
	# wait 5 s
	
	current_round_state = RoundState.INTERMISSION;
	
	#_update_players_intermission_status_ui("Intermission.");
	#_show_players_intermission_ui();
	
	_clean_round();


func _clean_round() -> void:
	teams_spawn_points.clear();
	spawned_required_classes.clear();
	spawn_amount_classes.clear();
	spawnwave_teams.clear();
	spawnwave_teams_choice.clear();
	spawnwave_teams_biohazard.clear();
	spawnwave_teams_firehazard.clear();
	spawnwave_teams_reinforcements.clear();
	
	GlobalTimers.stop_lcz_decontamination_timer();
	GlobalTimers.stop_hcz_decontamination_timer();
	GlobalTimers.stop_omega_warhead_detonation_timer();
	GlobalTimers.stop_alpha_warhead_detonation_timer();
	
	AnnouncementSystem.warhead_announcement_sound_player.stop();
