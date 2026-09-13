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

class_name Player
extends CharacterBody3D

@export_category("Team")
@export var player_team : Team;
@export var player_team_class : TeamClass;

## NOTE: It is important to note that these values may be replaced by those from Team and TeamClass during player spawn from round system.
@export_category("Default speeds")
@export var default_walk_speed : float = 5.0;
@export var default_sprint_speed : float = 7.5;
@export var default_jump_velocity : float = 6.0;
@export var default_can_sprint : bool = true;

var walk_speed : float = default_walk_speed; # 7
var sprint_speed : float = default_sprint_speed; # 8.5
var jump_velocity : float = default_jump_velocity;
var acceleration : float = 16.0;
var deceleration : float = 32.0;

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var look_sensitivity : float = 0.05;

@export var can_walk : bool = true;
## Not implemented
@export var can_sprint : bool = default_can_sprint;
@export var can_jump : bool = true;
## Not implemented
@export var can_crouch : bool = true;
## Not implemented
@export var can_noclip : bool = false;

var default_health : float = 100.0;
var default_max_health : float = 100.0;

var health : float = 100.0;
var max_health : float = 100.0;

## NOTE: It was made so e.g. Player can have his base health and his armor health
var additional_health : Dictionary = {};
var special_progress_bars : Array[Dictionary] = [];


func take_damage(damage : float, player : Player, damage_type : String, reason : String):
	if not additional_health.is_empty():
		var highest_priority = 0;
		
		for i in range(0,additional_health.keys().size()-1):
			var key = additional_health.keys()[i];
			if key > highest_priority:
				if additional_health[key].health > 0:
					highest_priority = key;
		
		var resulting_damage = damage;
		if not additional_health[highest_priority].damage_type_affection.is_empty():
			if additional_health[highest_priority].damage_type_affection.has(damage_type):
				resulting_damage = damage - additional_health[highest_priority].damage_type_affection[damage_type];
				if resulting_damage < 0:
					resulting_damage = 0;
				
		additional_health[highest_priority].health -= resulting_damage;
	
	health -= damage;
	
	if health <= 0:
		if player:
			print("player killed by other player")
			#rpc("player_killed_by_other_player", self, player, self.team, player.team, _effects_processor.current_effects);
			#player_killed_by_other_player.emit(self, player, self.team, player.team);
		elif reason:
			print("player killed")
			#rpc("player_killed",  self, self.team, reason, _effects_processor.current_effects);
			#player_killed.emit(self, self.team, reason);

func give_additional_health(health_priority : int, node_name : String, max_health_ : int, current_health_ : float, damage_type_affection : Dictionary = {}) -> void:
	if additional_health.has(health_priority):
		print("Assigning additional health with the priority that has already been assigned.");
		return;
	additional_health[health_priority] = {};
	additional_health[health_priority].node_name = node_name;
	additional_health[health_priority].health = current_health_;
	additional_health[health_priority].max_health = max_health_;
	additional_health[health_priority].damage_type_affection = damage_type_affection;

func give_special_progress_bar(node_name : String, max_value : int, value : float):
	var data = {};
	data.node_name = node_name;
	data.value = value;
	data.max_value = max_value;
	
	special_progress_bars.append(data);



func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("KEY_SPACE") and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir := Input.get_vector("KEY_A", "KEY_D", "KEY_W", "KEY_S")
	var direction := (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * walk_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * walk_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)
	
	move_and_slide()

var look_sensetivity = 0.005;

var captured : bool = true;

func _unhandled_input(event):
	if captured:
		var input = event is InputEventMouseMotion;
		
		if input:
			rotate_y(-event.relative.x * look_sensetivity);
			$head/neck/camera.rotate_x(-event.relative.y * look_sensetivity);
			$head/neck/camera.rotation.x = clamp($head/neck/camera.rotation.x, deg_to_rad(-90), deg_to_rad(90));
	
	if Input.is_action_just_pressed("KEY_ESCAPE"):
		captured = !captured;
	
	if captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);


func serialize() -> Dictionary:
	return {
		"network_id": str(name).to_int(),
		#"platform": platform,
		"team": player_team.serialize() if player_team else {},
		"team_class": player_team_class.serialize() if player_team_class else {},
		"health": health,
		"max_health": max_health,
		#"stamina": _player_controller.stamina,
		#"max_stamina": _player_controller.stamina,
	}
