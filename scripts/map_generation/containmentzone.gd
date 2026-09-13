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

class_name ContainmentZone
extends Resource

@export var zone_id : int = 0;
@export var zone_name : String = "";

@export var grid_width : int = 10;
@export var grid_height : int = 10;

@export var grid : Array[Array] = [];

@export var min_hallway_length : int = 4;

@export var room_size : float = 15;
@export var zone_y_position : int = 10;
@export var zone_offset : Vector2 = Vector2.ZERO;

@export var dead_ends : Array[RoomModel] = [];
@export var hallways : Array[RoomModel] = [];
@export var checkpoints : Array[CheckpointRoomModel] = [];
@export var turns : Array[RoomModel] = [];
@export var t_intersections : Array[RoomModel] = [];
@export var intersections : Array[RoomModel] = [];

@export var door_frames : Array[DoorFrameModel] = [];
@export var cluster_start : int = 1;

#@export var has_checkpoints_between_grids : bool = false;
