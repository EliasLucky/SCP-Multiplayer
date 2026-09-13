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

class_name RoomModel
extends Resource

@export var name : String
@export var model : PackedScene
## Room icon for SCP-079
@export var room_icon : Texture2D
@export_range(1,100) var spawn_chance : float = 100;

@export var cluster_enabled : bool = false;

@export var special_room : bool = false;
@export var has_spawn_limit : bool = false;
@export var max_spawn_amount : int = 1;

@export var item_spawn : Array[ItemData] = [];

@export var team_spawn : Array[TeamSpawn] = [];

#@export var camera_monitors_node_paths : Array[String] = [];
@export var camera_monitors_enabled : bool = false;
@export var camera_special_rooms : Array[String] = [];
