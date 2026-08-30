class_name TeamClass
extends Resource

@export_group("General")
@export var team_class_name : String = "";
@export var primary_color : Color = Color.WHITE;
@export var secondary_color : Color = Color.WHITE;

@export var direction_one : String = "";
@export var direction_two : String = "";
@export var direction_three : String = "";

@export var spawn_only_once : bool = false;
@export var spawn_chance : float = 50.0;
@export var spawn_only_if_other_classes_present : bool = false;

@export var inventory_data : Array[ItemData] = [];

# NOTE: It was planned as an abilities system for SCPs
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

@export_group("Spawnwave Altering")
@export var spawn_biohazard : bool = false;
@export var spawn_firehazard : bool = false;
@export var spawn_reinforcements : bool = false;

@export_group("Infection Team Class Type")
@export var scp008 : bool = false;
@export var scp610 : bool = false;
@export var zombie : bool = false;

func serialize() -> Dictionary:
	return {
		"name": team_class_name,
		"primary_color": primary_color,
		"secondary_color": secondary_color,
		"direction_one": direction_one,
		"direction_two": direction_two,
		"direction_three": direction_three
	}
