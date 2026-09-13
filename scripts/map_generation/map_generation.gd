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

class_name MapGenerator
extends Node

enum RoomType {
	TURN,INTERSECTION,T_INTERSECTION,HALLWAY,DEAD_END,EMPTY
}

class RoomTile:
	var exist : bool
	var rotation : int
	var room_type : RoomType
	var room_model : RoomModel
	var room_instance : Node3D
	
	func serialize() -> Dictionary:
		return {
			"exist": exist,
			"rotation": rotation,
			"room_type": room_type
		}

var special_turns : Array[RoomModel];
var special_intersections : Array[RoomModel];
var special_t_intersections : Array[RoomModel];
var special_hallways : Array[RoomModel];
var special_dead_ends : Array[RoomModel];

var spawned_special_rooms : Array[RoomModel];

var checkpoints : Dictionary = {};
var completed_checkpoints : Dictionary = {};

var saved_camera_monitors_enabled_rooms : Array[Dictionary] = [];

var room_counts : Dictionary = {};
var room_dead_end_counts : int = 0;

func generate_containment_zone(zone : ContainmentZone):
	#if not get_node(zone.name):
	#	var zone_node = Node3D.new();
	#	zone_node.name = zone.name;
	#	add_child(zone_node);
	
	_clean_containment_zone(zone);
	_prepare_containment_zone(zone);
	
	var starter_point = _connect_starter_points(zone);
	
	var hallways = 0;
	if zone.grid_width == zone.grid_height:
		hallways = 3 + (zone.grid_width - 5);
	else:
		hallways = abs(zone.grid_width-zone.grid_height) - 1
	
	for i in range(0,(hallways)/2):
		starter_point = _connect_points(zone, starter_point);
		
	starter_point = _connect_starter_points(zone);
	for i in range(0,(hallways)/2):
		starter_point = _connect_points(zone, starter_point);
	
	set_room_types(zone);
	visualize_rooms(zone);
	#place_doors(zone);
	#place_items(zone);

func _connect_starter_points(zone : ContainmentZone) -> Vector2:
	var width = floor((zone.grid_width-1) / 2);
	var height = floor((zone.grid_height-1) / 2);
	var random_point1 = Vector2(randi_range(0, width)*2, randi_range(0, height)*2);
	var random_point2 = Vector2(randi_range(0, width)*2, randi_range(0, height)*2);
	
	var checkpoint_point = _get_checkpoint_point(zone);
	if checkpoint_point:
		random_point1 = checkpoint_point;
	
	var points = _get_unique_points(zone, random_point1, random_point2);
	random_point1 = points[0];
	random_point2 = points[1];
	
	if randi_range(0,1) == 0:
		var previous_point1 = Vector2(random_point1.x,random_point1.y);
		for i in range(0,random_point2.x-random_point1.x,-1 if random_point2.x-random_point1.x < 0 else 1):
			zone.grid[random_point1.x+i][random_point1.y].exist = true;
			previous_point1 = Vector2(random_point1.x+i,random_point1.y);
		for i in range(0,random_point2.y-random_point1.y,-1 if random_point2.y-random_point1.y < 0 else 1):
			zone.grid[previous_point1.x][random_point1.y+i].exist = true;
	else:
		var previous_point1 = Vector2(random_point1.x,random_point1.y);
		for i in range(0,random_point2.y-random_point1.y,-1 if random_point2.y-random_point1.y < 0 else 1):
			zone.grid[random_point1.x][random_point1.y+i].exist = true;
			previous_point1 = Vector2(random_point1.x,random_point1.y+i);
		for i in range(0,random_point2.x-random_point1.x,-1 if random_point2.x-random_point1.x < 0 else 1):
			zone.grid[random_point1.x+i][previous_point1.y].exist = true;
	
	return random_point2;

func _connect_points(zone : ContainmentZone, previous_point : Vector2) -> Vector2:
	var width = floor((zone.grid_width-1)/2);
	var height = floor((zone.grid_height-1)/2);
	var random_point = Vector2(randi_range(0, width)*2, randi_range(0, height)*2);
	
	var checkpoint_point = _get_checkpoint_point(zone);
	if checkpoint_point:
		random_point = _get_checkpoint_point(zone);
	
	var points = _get_unique_points(zone, previous_point, random_point);
	random_point = points[1];
	
	if randi_range(0,1) == 0:
		var previous_point1 = Vector2(previous_point.x,previous_point.y);
		#print(random_point.x-previous_point.x);
		# rand.x=4 prev.x=8 sub=-4
		for i in range(0,random_point.x-previous_point.x,-1 if random_point.x-previous_point.x < 0 else 1):
			zone.grid[previous_point.x+i][previous_point.y].exist = true;
			previous_point1 = Vector2(previous_point.x+i,previous_point.y);
		for i in range(0,random_point.y-previous_point.y,-1 if random_point.y-previous_point.y < 0 else 1):
			zone.grid[previous_point1.x][previous_point.y+i].exist = true;
	else:
		var previous_point1 = Vector2(previous_point.x,previous_point.y);
		#print(random_point.y-previous_point.y);
		for i in range(0,random_point.y-previous_point.y,-1 if random_point.y-previous_point.y < 0 else 1):
			zone.grid[previous_point.x][previous_point.y+i].exist = true;
			previous_point1 = Vector2(previous_point.x,previous_point.y+i);
		for i in range(0,random_point.x-previous_point.x,-1 if random_point.x-previous_point.x < 0 else 1):
			zone.grid[previous_point.x+i][previous_point1.y].exist = true;
		
	return random_point;

func _get_checkpoint_point(zone : ContainmentZone):
	if zone.checkpoints.size() > 0 and completed_checkpoints.size() != zone.checkpoints.size():
		var index = randi_range(0,zone.checkpoints.size()-1);
		if completed_checkpoints.has(index):
			while completed_checkpoints.has(index):
				index = randi_range(0,zone.checkpoints.size()-1);
		completed_checkpoints[index] = zone.checkpoints[index];
		return completed_checkpoints[index];
	
	return null;

func _get_unique_points(zone : ContainmentZone, random_point1 : Vector2, random_point2 : Vector2) -> Array[Vector2]:
	if not _check_uniqueness(zone, random_point1, random_point2):
		while not _check_uniqueness(zone, random_point1, random_point2):
			var width = floor((zone.grid_width-1)/2);
			var height = floor((zone.grid_height-1)/2);
			random_point1 = Vector2(randi_range(0, width)*2, randi_range(0, height)*2);
			random_point2 = Vector2(randi_range(0, width)*2, randi_range(0, height)*2);

	var array : Array[Vector2] = [];
	array.append(random_point1);
	array.append(random_point2);
	return array;

func _check_uniqueness(zone : ContainmentZone, random_point1 : Vector2, random_point2 : Vector2) -> bool:
	if random_point1.x == random_point2.x and random_point1.y == random_point2.y:
		return false;
	
	var distance = 0;
	for i in range(0,random_point1.x - random_point2.x,-1 if random_point1.x-random_point2.x < 0 else 1):
		distance += 1;
	
	for i in range(0,random_point1.y - random_point2.y,-1 if random_point1.y-random_point2.y < 0 else 1):
		distance += 1;
	distance -= 1
	
	if distance < zone.min_hallway_length:
		return false;
	
	return true;

func set_room_types(zone : ContainmentZone):
	for x in range(0, zone.grid_width):
		for y in range(0, zone.grid_height):
			_check_corner_rooms(zone,zone.grid,x,y);
	
	for x in range(0, zone.grid_width):
		for y in range(0, zone.grid_height):
			_check_intersection_rooms(zone,zone.grid,x,y);
	
	for x in range(0, zone.grid_width):
		for y in range(0, zone.grid_height):
			_check_t_intersection_rooms(zone,zone.grid,x,y);
	
	for x in range(0, zone.grid_width):
		for y in range(0, zone.grid_height):
			_check_hallway_rooms(zone,zone.grid,x,y);
	
	for x in range(0, zone.grid_width):
		for y in range(0, zone.grid_height):
			_check_dead_end_rooms(zone,zone.grid,x,y);
	
	if special_dead_ends.size() > room_dead_end_counts:
		while special_dead_ends.size() > room_dead_end_counts:
			_fix_insufficient_dead_ends(zone,zone.grid);

func _check_corner_rooms(zone : ContainmentZone, grid, x, y):
	if not grid[x][y].exist or not grid[x][y].room_type == RoomType.EMPTY:
		return;
	
	#if _check_grid_corners(zone, x+1,y) and grid[x+1][y].exist \
	#	and _check_grid_corners(zone, x,y+1) and grid[x][y+1].exist \
	#	and (not _check_grid_corners(zone, x-1,y) or not grid[x-1][y].exist) \
	#	and (not _check_grid_corners(zone, x,y-1) or not grid[x][y-1].exist):
	#	grid[x][y].room_type = RoomType.TURN;
	#	grid[x][y].rotation = 180;
	#elif _check_grid_corners(zone, x+1,y) and grid[x+1][y].exist \
	#	and (not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) \
	#	and (not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) \
	#	and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist:
	#	grid[x][y].room_type = RoomType.TURN;
	#	grid[x][y].rotation = 270;
	#elif (not _check_grid_corners(zone, x+1,y) or not grid[x+1][y].exist) \
	#	and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist \
	#	and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist \
	#	and (not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist):
	#	grid[x][y].room_type = RoomType.TURN;
	#	grid[x][y].rotation = 90;
	#elif (not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) \
	#	and (not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) \
	#	and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist \
	#	and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist:
	#	grid[x][y].room_type = RoomType.TURN;
	#	grid[x][y].rotation = 0;
	
	if ((_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist) or (not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y))) \
		and ((_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist) or (not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1))) \
		and ((not _check_grid_corners(zone,x-1,y) and not _check_grid_checkpoints(zone,x-1,y)) or (not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) and not _check_grid_checkpoints(zone,x,y-1)) or (not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.TURN;
		grid[x][y].rotation = 180;
	elif ((_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist) or (not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y))) \
		and ((not _check_grid_corners(zone,x,y+1) and not _check_grid_checkpoints(zone,x,y+1)) or (not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) and not _check_grid_checkpoints(zone,x-1,y)) or (not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist)) \
		and ((_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist) or (not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1))):
		grid[x][y].room_type = RoomType.TURN;
		grid[x][y].rotation = 270;
	elif ((not _check_grid_corners(zone,x+1,y) and not _check_grid_checkpoints(zone,x+1,y)) or (not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist)) \
		and ((_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist) or (not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1))) \
		and ((_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist) or (not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y))) \
		and ((not _check_grid_corners(zone,x,y-1) and not _check_grid_checkpoints(zone,x,y-1)) or (not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.TURN;
		grid[x][y].rotation = 90;
	elif ((not _check_grid_corners(zone,x+1,y) and not _check_grid_checkpoints(zone,x+1,y)) or (not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) and not _check_grid_corners(zone,x,y+1)) or (not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist)) \
		and ((_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist) or (not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y))) \
		and ((_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist) or (not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1))):
		grid[x][y].room_type = RoomType.TURN;
		grid[x][y].rotation = 0;
		
		

func _check_intersection_rooms(zone : ContainmentZone, grid, x, y):
	if not grid[x][y].exist or not grid[x][y].room_type == RoomType.EMPTY:
		return;
	
	##if _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and grid[x+1][y].room_type == RoomType.TURN \
	##	and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x][y+1].room_type == RoomType.TURN \
	##	and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.TURN \
	##	and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and grid[x][y-1].room_type == RoomType.TURN:
	##	grid[x][y].room_type = RoomType.INTERSECTION;
	
	#if _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist \
	#	and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist \
	#	and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist \
	#	and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist:
	#	grid[x][y].room_type = RoomType.INTERSECTION;
	
	if ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.INTERSECTION;
	
	#if _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and grid[x+1][y].room_type == RoomType.TURN and grid[x+1][y].rotation == 0 \
	#	and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x][y+1].room_type == RoomType.TURN and grid[x][y+1].rotation == 0 \
	#	and ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.TURN and grid[x-1][y].rotation == 0)) \
	#	and ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and grid[x][y-1].room_type == RoomType.TURN and grid[x][y-1].rotation == 0)):
	#	pass;
	#elif _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and grid[x+1][y].room_type == RoomType.TURN and grid[x+1][y].rotation == 0 \
	#	and ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x][y+1].room_type == RoomType.TURN and grid[x][y+1].rotation == 0)) \
	#	and ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.TURN and grid[x-1][y].rotation == 0)) \
	#	and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and grid[x][y-1].room_type == RoomType.TURN and grid[x][y-1].rotation == 0:
	#	pass;
	#elif 

func _check_t_intersection_rooms(zone, grid, x, y):
	if not grid[x][y].exist or not grid[x][y].room_type == RoomType.EMPTY:
		return;
	
	if ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and ((grid[x+1][y].room_type == RoomType.TURN and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 90)) or grid[x+1][y].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and ((grid[x][y+1].room_type == RoomType.TURN and (grid[x][y+1].rotation == 0 or grid[x][y+1].rotation == 270)) or grid[x][y+1].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and ((grid[x-1][y].room_type == RoomType.TURN and (grid[x-1][y].rotation == 180 or grid[x-1][y].rotation == 270)) or grid[x-1][y].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and grid[x][y-1].room_type == RoomType.EMPTY)):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 180;
	elif ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and ((grid[x+1][y].room_type == RoomType.TURN and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 90)) or grid[x+1][y].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x][y+1].room_type == RoomType.EMPTY)) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and ((grid[x-1][y].room_type == RoomType.TURN and (grid[x-1][y].rotation == 180 or grid[x-1][y].rotation == 270)) or grid[x-1][y].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and ((grid[x][y-1].room_type == RoomType.TURN and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180)) or grid[x][y-1].room_type == RoomType.INTERSECTION))):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 0
	elif ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and ((grid[x+1][y].room_type == RoomType.TURN and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 90)) or grid[x+1][y].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and ((grid[x][y+1].room_type == RoomType.TURN and (grid[x][y+1].rotation == 0 or grid[x][y+1].rotation == 270)) or grid[x][y+1].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.EMPTY)) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and ((grid[x][y-1].room_type == RoomType.TURN and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180)) or grid[x][y-1].room_type == RoomType.INTERSECTION))):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 270;
	elif ((not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and grid[x+1][y].room_type == RoomType.EMPTY)) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and ((grid[x][y+1].room_type == RoomType.TURN and (grid[x][y+1].rotation == 0 or grid[x+1][y].rotation == 270)) or grid[x][y+1].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and ((grid[x-1][y].room_type == RoomType.TURN and (grid[x-1][y].rotation == 180 or grid[x-1][y].rotation == 270)) or grid[x-1][y].room_type == RoomType.INTERSECTION))) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and ((grid[x][y-1].room_type == RoomType.TURN and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180)) or grid[x][y-1].room_type == RoomType.INTERSECTION))):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 90;
	
	if ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) and not _check_grid_checkpoints(zone,x,y-1)) or ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist) and grid[x][y+1].room_type == RoomType.EMPTY)):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 180;
	elif ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) and not _check_grid_checkpoints(zone,x,y+1)) or (not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x][y+1].room_type == RoomType.EMPTY)) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 0;
	elif ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.EMPTY)) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 270;
	elif ((not _check_grid_corners(zone,x+1,y) and not _check_grid_checkpoints(zone,x+1,y)) or (not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.EMPTY)) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.T_INTERSECTION;
		grid[x][y].rotation = 90;

func _check_hallway_rooms(zone, grid, x, y):
	if not grid[x][y].exist or not grid[x][y].room_type == RoomType.EMPTY:
		return;
	
	if ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and ((grid[x+1][y].room_type == RoomType.TURN and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 270)) or grid[x+1][y].room_type == RoomType.INTERSECTION or (grid[x+1][y].room_type == RoomType.T_INTERSECTION and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 90 or grid[x+1][y].rotation == 180))))) \
		and ((not _check_grid_corners(zone,x,y+1) and not _check_grid_checkpoints(zone,x,y+1)) or ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x][y+1].room_type == RoomType.EMPTY))) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and ((grid[x-1][y].room_type == RoomType.TURN and (grid[x-1][y].rotation == 90 or grid[x-1][y].rotation == 180)) or grid[x-1][y].room_type == RoomType.INTERSECTION or (grid[x-1][y].room_type == RoomType.T_INTERSECTION and (grid[x-1][y].rotation == 0 or grid[x-1][y].rotation == 180 or grid[x-1][y].rotation == 270))))) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and grid[x][y-1].room_type == RoomType.EMPTY))):
		grid[x][y].room_type = RoomType.HALLWAY;
		grid[x][y].rotation = 90;
	elif ((not _check_grid_corners(zone,x+1,y) and not _check_grid_checkpoints(zone,x+1,y)) or ((not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and grid[x+1][y].room_type == RoomType.EMPTY))) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and ((grid[x][y+1].room_type == RoomType.TURN and (grid[x][y+1].rotation == 0 or grid[x][y+1].rotation == 270)) or grid[x][y+1].room_type == RoomType.INTERSECTION or (grid[x][y+1].room_type == RoomType.T_INTERSECTION and (grid[x][y+1].rotation == 0 or grid[x][y+1].rotation == 90 or grid[x][y+1].rotation == 270))))) \
		and ((not _check_grid_corners(zone,x-1,y) and not _check_grid_checkpoints(zone,x-1,y)) or ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.EMPTY))) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and ((grid[x][y-1].room_type == RoomType.TURN and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180)) or grid[x][y-1].room_type == RoomType.INTERSECTION or (grid[x][y-1].room_type == RoomType.T_INTERSECTION and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180 or grid[x-1][y].rotation == 270))))):
		grid[x][y].room_type = RoomType.HALLWAY;
		grid[x][y].rotation = 0;
	
	if ((not _check_grid_corners(zone,x+1,y) and _check_grid_checkpoints(zone,x+1,y)) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) and not _check_grid_checkpoints(zone,x,y+1)) or ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and grid[x-1][y].room_type == RoomType.EMPTY))) \
		and ((not _check_grid_corners(zone,x-1,y) and _check_grid_checkpoints(zone,x-1,y)) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) and not _check_grid_checkpoints(zone,x,y-1)) or ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and grid[x][y-1].room_type == RoomType.EMPTY))):
		grid[x][y].room_type = RoomType.HALLWAY;
		grid[x][y].rotation = 90;
	elif ((not _check_grid_corners(zone,x+1,y) and not _check_grid_checkpoints(zone,x+1,y)) or ((not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and grid[x+1][y].room_type == RoomType.EMPTY))) \
		and ((not _check_grid_corners(zone,x,y+1) and _check_grid_checkpoints(zone,x,y+1)) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) and not _check_grid_checkpoints(zone,x-1,y)) or ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and grid[x-1][y].room_type == RoomType.EMPTY))) \
		and ((not _check_grid_corners(zone,x,y-1) and _check_grid_checkpoints(zone,x,y-1)) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.HALLWAY;
		grid[x][y].rotation = 0;

func _check_dead_end_rooms(zone, grid, x, y):
	if not grid[x][y].exist or not grid[x][y].room_type == RoomType.EMPTY:
		return;
	
	if _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist and ((grid[x+1][y].room_type == RoomType.TURN and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 90)) or grid[x+1][y].room_type == RoomType.INTERSECTION or (grid[x+1][y].room_type == RoomType.T_INTERSECTION and (grid[x+1][y].rotation == 0 or grid[x+1][y].rotation == 90 or grid[x+1][y].rotation == 180)) or (grid[x+1][y].room_type == RoomType.HALLWAY and (grid[x+1][y].rotation == 90))) \
		and ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.DEAD_END;
		grid[x][y].rotation = 270;
	elif ((not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist and ((grid[x][y+1].room_type == RoomType.TURN and (grid[x][y+1].rotation == 0 or grid[x][y+1].rotation == 270)) or grid[x][y+1].room_type == RoomType.INTERSECTION or (grid[x][y+1].room_type == RoomType.T_INTERSECTION and (grid[x][y+1].rotation == 0 or grid[x][y+1].rotation == 90 or grid[x][y+1].rotation == 270)) or (grid[x][y+1].room_type == RoomType.HALLWAY and (grid[x][y+1].rotation == 0))) \
		and ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y-1) or not grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.DEAD_END;
		grid[x][y].rotation = 180;
	elif ((not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist and ((grid[x-1][y].room_type == RoomType.TURN and (grid[x-1][y].rotation == 180 or grid[x-1][y].rotation == 270)) or grid[x-1][y].room_type == RoomType.INTERSECTION or (grid[x-1][y].room_type == RoomType.T_INTERSECTION and (grid[x-1][y].rotation == 0 or grid[x-1][y].rotation == 180 or grid[x-1][y].rotation == 270)) or (grid[x-1][y].room_type == RoomType.HALLWAY and (grid[x-1][y].rotation == 90))) \
		and (not _check_grid_corners(zone,x,y-1) or not (grid[x][y-1].exist) or (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist)):
		grid[x][y].room_type = RoomType.DEAD_END;
		grid[x][y].rotation = 90;
	elif ((not _check_grid_corners(zone,x+1,y) or not grid[x+1][y].exist) or (_check_grid_corners(zone,x+1,y) and grid[x+1][y].exist)) \
		and ((not _check_grid_corners(zone,x,y+1) or not grid[x][y+1].exist) or (_check_grid_corners(zone,x,y+1) and grid[x][y+1].exist)) \
		and ((not _check_grid_corners(zone,x-1,y) or not grid[x-1][y].exist) or (_check_grid_corners(zone,x-1,y) and grid[x-1][y].exist)) \
		and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist and ((grid[x][y-1].room_type == RoomType.TURN and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180)) or grid[x][y-1].room_type == RoomType.INTERSECTION or (grid[x][y-1].room_type == RoomType.T_INTERSECTION and (grid[x][y-1].rotation == 90 or grid[x][y-1].rotation == 180 or grid[x][y-1].rotation == 270)) or (grid[x][y-1].room_type == RoomType.HALLWAY and (grid[x][y-1].rotation == 0))):
		grid[x][y].room_type = RoomType.DEAD_END;
		grid[x][y].rotation = 0;
		
func _check_grid_corners(zone, x, y):
	if x == -1 or x == zone.grid_width:
		return false;
	if y == -1 or y == zone.grid_height:
		return false;
	return true;

func _check_grid_checkpoints(zone, x, y):
	for i in range(0,zone.checkpoints.size()):
		if zone.checkpoints[i].grid_position.x == x and zone.checkpoints[i].grid_position.y == y:
			return true;
	return false;

func _check_turn_rotation(rot1,rot2,room):
	if room.rotation == rot1 or room.rotation == rot2:
		return true;
	
	return false;

func _check_t_intersection_rotation(rot1,rot2,rot3,room):
	if room.rotation == rot1 or room.rotation == rot2 or room.rotation == rot3:
		return true;
	
	return false;

func _fix_insufficient_dead_ends(zone : ContainmentZone, grid):
	for x in range(0,zone.grid_width):
		for y in range(0,zone.grid_height):
			if grid[x][y].exist and grid[x][y].room_type == RoomType.HALLWAY:
				if grid[x][y].rotation == 0:
					if (_check_grid_corners(zone,x+1,y) and not grid[x+1][y].exist) \
						and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist \
						and (_check_grid_corners(zone,x-1,y) and not grid[x-1][y].exist) \
						and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist:
						grid[x][y].room_type = RoomType.INTERSECTION;
						grid[x][y+1].room_type = RoomType.DEAD_END;
						grid[x][y+1].rotation = 0;
						grid[x][y-1].room_type = RoomType.DEAD_END;
						grid[x][y-1].rotation = 180;
						
						room_dead_end_counts += 2;
					if (not _check_grid_corners(zone,x+1,y) and not grid[x+1][y].exist) \
						and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist \
						and (_check_grid_corners(zone,x-1,y) and not grid[x-1][y].exist) \
						and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist:
						grid[x][y].room_type = RoomType.T_INTERSECTION;
						grid[x][y].rotation = 90;
						grid[x-1][y].room_type = RoomType.DEAD_END;
						grid[x-1][y].rotation = 270;
						
						room_dead_end_counts += 1;
					elif (_check_grid_corners(zone,x+1,y) and not grid[x+1][y].exist) \
						and _check_grid_corners(zone,x,y+1) and grid[x][y+1].exist \
						and (not _check_grid_corners(zone,x-1,y) and not grid[x][y].exist) \
						and _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist:
						grid[x][y].room_type = RoomType.T_INTERSECTION;
						grid[x][y].rotation = 270;
						grid[x+1][y].room_type = RoomType.DEAD_END;
						grid[x+1][y].rotation = 90;
						
						room_dead_end_counts += 1;
				elif grid[x][y].rotation == 90:
					if _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist \
						and (_check_grid_corners(zone,x,y+1) and not grid[x][y+1].exist) \
						and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist \
						and (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist):
						grid[x][y].room_type = RoomType.INTERSECTION;
						grid[x+1][y].room_type = RoomType.DEAD_END;
						grid[x+1][y].rotation = 90;
						grid[x-1][y].roon_type = RoomType.DEAD_END;
						grid[x-1][y].rotation = 270;
						
						room_dead_end_counts += 2;
					if _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist \
						and (not _check_grid_corners(zone,x,y+1) and not grid[x][y+1].exist) \
						and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist \
						and (_check_grid_corners(zone,x,y-1) and grid[x][y-1].exist):
						grid[x][y].room_type = RoomType.T_INTERSECTION;
						grid[x][y].rotation = 0;
						grid[x][y-1].room_type = RoomType.DEAD_END;
						grid[x][y-1].rotation = 180;
						
						room_dead_end_counts += 1;
					elif _check_grid_corners(zone,x+1,y) and grid[x+1][y].exist \
						and (_check_grid_corners(zone,x,y+1) and not grid[x][y+1].exist) \
						and _check_grid_corners(zone,x-1,y) and grid[x-1][y].exist \
						and (not _check_grid_corners(zone,x,y-1) and grid[x][y-1].exist):
						grid[x][y].room_type = RoomType.T_INTERSECTION;
						grid[x][y].rotation = 180;
						grid[x][y+1].room_type = RoomType.DEAD_END;
						grid[x][y+1].rotation = 0;
						
						room_dead_end_counts += 1;
				
				if special_dead_ends.size() <= room_dead_end_counts:
					return;

func visualize_rooms(zone : ContainmentZone):
	for x in range(0,zone.grid_width):
		for y in range(0,zone.grid_height):
			if zone.grid[x][y].exist:
				match zone.grid[x][y].room_type:
					RoomType.TURN:
						_place_random_room(zone,x,y,zone.turns,special_turns);
						#if index != -1:
						#	special_turns.remove_at(index);
					RoomType.INTERSECTION:
						_place_random_room(zone,x,y,zone.intersections,special_intersections);
						#if index != -1:
						#	special_intersections.remove_at(index);
					RoomType.T_INTERSECTION:
						_place_random_room(zone,x,y,zone.t_intersections, special_t_intersections);
						#if index != -1:
						#	special_t_intersections.remove_at(index);
					RoomType.HALLWAY:
						_place_random_room(zone,x,y,zone.hallways, special_hallways);
						#if index != -1:
						#	special_hallways.remove_at(index);
					RoomType.DEAD_END:
						_place_random_room(zone,x,y,zone.dead_ends, special_dead_ends);
						#if index != -1:
						#	special_dead_ends.remove_at(index);
	
	if zone.checkpoints.size() > 0:
		for i in range(0,zone.checkpoints.size()):
			var grid_position = zone.checkpoints[i].grid_position;
			grid_position.x = grid_position.x if grid_position.x < 0 else grid_position.x + zone.grid_width;
			grid_position.y = grid_position.y if grid_position.y < 0 else grid_position.y + zone.grid_height;
			var room = _place_room(zone, zone.checkpoints[i], grid_position.x, grid_position.y, zone.checkpoints[i].rotation.y);
			checkpoints[zone].append(room);

func _place_random_room(zone : ContainmentZone,x,y,normal_rooms : Array[RoomModel], special_rooms : Array[RoomModel]):
	var room;
	if special_rooms.size() == 0:
		room = _get_random_room(zone, normal_rooms);
	else:
		room = _get_random_room(zone, special_rooms, true);
	
	if room:
		zone.grid[x][y].room_model = room;
	else:
		room = _get_random_room(zone, normal_rooms);
		zone.grid[x][y].room_model = room;
	
	room = room.model.instantiate();
	room.position = Vector3((x + zone.zone_offset.x) * zone.room_size, zone.zone_y_position, (y + zone.zone_offset.y) * zone.room_size);
	room.rotation_degrees = Vector3(room.rotation_degrees.x, zone.grid[x][y].rotation, room.rotation_degrees.z);
	
	add_child(room,true);
	
	if room.has_method("set_model_position"):
		room.set_model_position.rpc(room.position);
	if room.has_method("set_model_rotation"):
		room.set_model_rotation.rpc(room.rotation_degrees);
	
	zone.grid[x][y].room_instance = room;
	
	for i in range(0,saved_camera_monitors_enabled_rooms.size()):
		var saved = saved_camera_monitors_enabled_rooms[i];
		var camera_special_rooms = saved.room_model.room_model.camera_special_rooms;
		for j in range(0,camera_special_rooms.size()):
			if camera_special_rooms[j].name == room.name:
				if room.has_node("surveillance_camera"):
					var camera = room.get_node("surveillance_camera").duplicate();
					saved.room_instance.get_node(str(camera_special_rooms[j].name)).add_child(camera);
	
	if zone.grid[x][y].room_model.camera_monitors_enabled:
		saved_camera_monitors_enabled_rooms.append({ "room_instance": zone.grid[x][y].room_instance, "room_model": zone.grid[x][y].room_model });

func _get_random_room(zone : ContainmentZone, rooms : Array[RoomModel], special : bool = false) -> RoomModel:
	var index = randi_range(0,rooms.size()-1);
	var room = rooms[index];
	
	if special:
		if rooms.size() == 0:
			return null;
		
		rooms.remove_at(index);
		
		#if spawned_special_rooms.has(room):
		#	
		#	return _get_random_room(zone, rooms, special);
		#else:
		#	spawned_special_rooms.append(room);
	
	if room.has_spawn_limit:
		if room_counts.has(room):
			room_counts[room] += 1;
			if room_counts[room] > room.max_spawn_amount:
				return _get_random_room(zone, rooms, special);
		else:
			room_counts[room] = 1;
	
	return room;

func _place_room(zone : ContainmentZone, room : RoomModel,x,y,rotation : int) -> Node:
	var room_ = room.model.instantiate();
	room_.position = Vector3(x * zone.room_size, zone.zone_y_position, y * zone.room_size);
	room_.rotation_degrees = Vector3(room_.rotation_degrees.x, rotation, room_.rotation_degrees.z);
	add_child(room_);
	
	return room_;

#func _check_camera_monitors(zone : ContainmentZone, room : Node3D) -> void:
#	pass;

func place_doors(zone : ContainmentZone):
	for x in range(zone.grid_width):
		for y in range(zone.grid_height):
			if zone.grid[x][y].exist and zone.grid[x][y].room_type != RoomType.EMPTY:
				#if zone.grid[x][y].room_model.cluster_enabled:
				_check_room_type(zone,zone.grid,x,y,zone.grid[x][y].room_model.cluster_enabled);

const origin_point = Vector3(0,0,0)

func _check_room_type(zone : ContainmentZone,grid,x,y,cluster_enabled):
	var door_frame;
	if cluster_enabled:
		door_frame = zone.door_frames[randi_range(0,zone.cluster_start-1)];
	else:
		door_frame = zone.door_frames[randi_range(0,zone.door_frames.size()-1)];
	match grid[x][y].room_type:
		RoomType.TURN:
			if grid[x][y].rotation == 0:
				_check_and_place_door(door_frame,grid,x-1,y,deg_to_rad(90));
				_check_and_place_door(door_frame,grid,x,y-1,0);
				
				#var position = origin_point + (door_frame.position - origin_point).rotated(Vector3(0,90,0));
				#var position = _rotate_around_point(door_frame.position, Vector3(0,deg_to_rad(90),0), origin_point);
				#if _check_other_room_types(grid,x-1,y,position):
				#	_place_door(door_frame.model, position, door_frame.rotation)
				#position = origin_point + (door_frame.position - origin_point).rotated(Vector3(0,0,0))
				#position = _rotate_around_point(door_frame.position, Vector3(0,0,0), origin_point);
				#if _check_other_room_types(grid,x,y-1,position):
				#	_place_door(door_frame.model, position, door_frame.rotation);
			elif grid[x][y].rotation == 90:
				_check_and_place_door(door_frame,grid,x-1,y,0);
				_check_and_place_door(door_frame,grid,x,y+1,deg_to_rad(90));
				
				#var position = _rotate_around_point(door_frame.position, Vector3(0,deg_to_rad(0),0), origin_point);
				#if _check_other_room_types(grid,x,y,position):
				#	_place_door(door_frame.model, position, door_frame.rotation);
				#position = _rotate_around_point(door_frame.position, Vector3(0,0,0), origin_point);
				#if _check_other_room_types(grid,x,y,position):
				#	_place_door(door_frame.model, position, door_frame.rotation);
			elif grid[x][y].rotation == 180:
				_check_and_place_door(door_frame,grid,x+1,y,deg_to_rad(90));
				_check_and_place_door(door_frame,grid,x,y+1,0);
				
				#var position = _rotate_around_point(door_frame.position, Vector3(0,deg_to_rad(0),0), origin_point);
				#if _check_other_room_types(grid,x,y,position):
				#	_place_door(door_frame.model, position, door_frame.rotation);
				#position = _rotate_around_point(door_frame.position, Vector3(0,deg_to_rad(0),0), origin_point);
				#if _check_other_room_types(grid,x,y,position):
				#	_place_door(door_frame.model, position, door_frame.rotaion);
			elif grid[x][y].rotation == 270:
				_check_and_place_door(door_frame,grid,x+1,y,0);
				_check_and_place_door(door_frame,grid,x,y-1,deg_to_rad(90));
		RoomType.INTERSECTION:
			_check_and_place_door(door_frame,grid,x+1,y,deg_to_rad(270));
			_check_and_place_door(door_frame,grid,x,y+1,deg_to_rad(180));
			_check_and_place_door(door_frame,grid,x-1,y,deg_to_rad(90));
			_check_and_place_door(door_frame,grid,x,y-1,0);
		RoomType.T_INTERSECTION:
			if grid[x][y].rotation == 0:
				_check_and_place_door(door_frame,grid,x+1,y,deg_to_rad(270));
				_check_and_place_door(door_frame,grid,x,y-1,0);
				_check_and_place_door(door_frame,grid,x-1,y,deg_to_rad(90));
			elif grid[x][y].rotation == 90:
				_check_and_place_door(door_frame,grid,x-1,y,0);
				_check_and_place_door(door_frame,grid,x,y+1,deg_to_rad(90));
				_check_and_place_door(door_frame,grid,x,y-1,deg_to_rad(270));
			elif grid[x][y].rotation == 180:
				_check_and_place_door(door_frame,grid,x+1,y,deg_to_rad(90));
				_check_and_place_door(door_frame,grid,x,y+1,0);
				_check_and_place_door(door_frame,grid,x-1,y,deg_to_rad(270));
			elif grid[x][y].rotation == 270:
				_check_and_place_door(door_frame,grid,x+1,y,0);
				_check_and_place_door(door_frame,grid,x,y+1,deg_to_rad(270));
				_check_and_place_door(door_frame,grid,x,y-1,deg_to_rad(90));
		RoomType.HALLWAY:
			if grid[x][y].rotation == 0:
				_check_and_place_door(door_frame,grid,x,y+1,deg_to_rad(180));
				_check_and_place_door(door_frame,grid,x,y-1,0);
			elif grid[x][y].rotation == 90:
				_check_and_place_door(door_frame,grid,x+1,y,deg_to_rad(180));
				_check_and_place_door(door_frame,grid,x-1,y,0);
			#elif grid[x][y].rotation == 180:
			#	_check_and_place_door(door_frame,grid,x,y,Vector3(0,0,0));
			#	_check_and_place_door(door_frame,grid,x,y,Vector3(0,0,0));
			#elif grid[x][y].rotation == 270:
			#	_check_and_place_door(door_frame,grid,x,y,Vector3(0,0,0));
			#	_check_and_place_door(door_frame,grid,x,y,Vector3(0,0,0));
		RoomType.DEAD_END:
			if grid[x][y].rotation == 0:
				_check_and_place_door(door_frame,grid,x,y-1,0);
			elif grid[x][y].rotation == 90:
				_check_and_place_door(door_frame,grid,x-1,y,0);
			elif grid[x][y].rotation == 180:
				_check_and_place_door(door_frame,grid,x,y+1,0);
			elif grid[x][y].rotation == 270:
				_check_and_place_door(door_frame,grid,x+1,y,0);

func _check_and_place_door(door_frame : DoorFrameModel,grid,x,y,rotation : int):
	var position = _rotate_around_point(door_frame.position, rotation, origin_point);
	if _check_other_room_types(grid,x,y,position):
		_place_door(grid[x][y].room_instance, door_frame.model, position, door_frame.rotation);

func _rotate_around_point(position : Vector3, rotate : int, origin : Vector3) -> Vector3:
	return origin + (position - origin).rotated(Vector3(0,1,0), rotate);

func _check_other_room_types(grid,x,y,position : Vector3) -> bool:
	match grid[x][y].room_type:
		RoomType.TURN:
			if grid[x][y].room_instance.get_node("doorframe1"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe1").position) < 2:
					return false;
			if grid[x][y].room_instance.get_node("doorframe2"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe2").position) < 2:
					return false;
			
			#if grid[x][y].rotation == 0:
			#	pass;
			#elif grid[x][y].rotation == 90:
			#	if grid[x][y].room_instance.get_node("doorframe1"):
			#		return false;
			#elif grid[x][y].rotation == 180:
			#	if grid[x][y].room_instance.get_node("doorframe2"):
			#		return false;
			#elif grid[x][y].rotation == 270:
			#	if grid[x][y].room_instance.get_node("doorframe1"):
			#		return false;
				
		RoomType.INTERSECTION:
			if grid[x][y].room_instance.get_node("doorframe1"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe1")) < 4.0:
					return false;
			if grid[x][y].room_instance.get_node("doorframe2"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe2")) < 4.0:
					return false;
			if grid[x][y].room_instance.get_node("doorframe3"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe3")) < 4.0:
					return false;
			if grid[x][y].room_instance.get_node("doorframe4"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe4")) < 4.0:
					return false;
		RoomType.T_INTERSECTION:
			if grid[x][y].room_instance.get_node("doorframe1"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe1")) < 4.0:
					return false;
			if grid[x][y].room_instance.get_node("doorframe2"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe2")) < 4.0:
					return false;
			if grid[x][y].room_instance.get_node("doorframe3"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe3")) < 4.0:
					return false;
		RoomType.HALLWAY:
			if grid[x][y].room_instance.get_node("doorframe1"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe1")) < 4.0:
					return false;
			if grid[x][y].room_instance.get_node("doorframe2"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe2")) < 4.0:
					return false;
		RoomType.DEAD_END:
			if grid[x][y].room_instance.get_node("doorframe1"):
				if _distance(position, grid[x][y].room_instance.get_node("doorframe1")) < 4.0:
					return false;
	
	return true;

func _distance(point1 : Vector3, point2 : Vector3) -> float:
	#return sqrt(pow(point2.x-point1.x,2)+pow(point2.y-point1.y,2)+pow(point2.z-point1.z,2))
	return point1.distance_squared_to(point2);

func _place_door(room, doorframe : PackedScene, doorframe_position : Vector3, doorframe_rotation : Vector3):
	var doorframe_ = doorframe.instantiate();
	doorframe_.position = Vector3(doorframe_position.x, doorframe_position.y, doorframe_position.z);
	doorframe_.rotation_degrees = Vector3(doorframe_rotation.x, doorframe_rotation.y, doorframe_rotation.z);
	room.add_child(doorframe_);

func place_items(zone : ContainmentZone):
	for x in range(zone.grid_width):
		for y in range(zone.grid_height):
			if zone.grid[x][y].exist:
				var item_spawn = zone.grid[x][y].room_model.item_spawn;
				for i in range(0,item_spawn.size()):
					var item = item_spawn[i].item_model.instantate();
					item.position = Vector3(item_spawn[i].item_spawn_position.x, item_spawn[i].item_spawn_position.y, item_spawn[i].item_spawn_position.z);
					item.rotation_degrees = Vector3(item_spawn[i].item_spawn_rotation.x, item_spawn[i].item_spawn_rotation.y, item_spawn[i].item_spawn_rotation.z);
					zone.grid[x][y].room_instance.add_child(item);
					#item.item_data = item_spawn[i];

func connect_cameras(zone : ContainmentZone):
	for x in range(zone.grid_width):
		for y in range(zone.grid_height):
			if zone.grid[x][y].exist:
				if zone.grid[x][y].room_model.camera_monitors_enabled:
					var room = zone.grid[x][y].room_instance;
					

func _prepare_containment_zone(zone : ContainmentZone):
	if not get_node_or_null(zone.zone_name):
		var node = Node3D.new();
		node.name = zone.zone_name;
		add_child(node);
	
	for x in range(zone.grid_width):
		zone.grid.append([]);
		for y in range(zone.grid_height):
			zone.grid[x].append(RoomTile.new());
			zone.grid[x][y].exist = false;
			zone.grid[x][y].rotation = 0;
			zone.grid[x][y].room_type = RoomType.EMPTY;
			zone.grid[x][y].room_model = null;
			zone.grid[x][y].room_instance = null;
	
	special_turns = zone.turns.duplicate().filter(_check_room_special);
	special_intersections = zone.intersections.duplicate().filter(_check_room_special);
	special_t_intersections = zone.t_intersections.duplicate().filter(_check_room_special);
	special_hallways = zone.hallways.duplicate().filter(_check_room_special);
	special_dead_ends = zone.dead_ends.duplicate().filter(_check_room_special);
	spawned_special_rooms = [];
	
	checkpoints[zone] = [];
	#for i in range(0,zone.checkpoints.size()):
	#	checkpoints[zone].append();

func decontaminate_containment_zone(zone : ContainmentZone):
	for x in range(0,zone.grid_width-1):
		for y in range(0,zone.grid_height-1):
			if zone.grid[x][y].room_type != RoomType.EMPTY:
				if zone.grid[x][y].room_model.enabled_decontamination:
					for i in range(0,zone.grid[x][y].room_instance.get_node("decontamination").get_children()):
						zone.grid[x][y].room_instance.get_node("decontamination").get_children()[i].emitting = true;
	
	for i in range(0,checkpoints[zone].size()):
		checkpoints[zone][i].get_node("doors").open = false;
		checkpoints[zone][i].get_node("doors").locked = true;

func get_containment_zone_spawn_points(zone : ContainmentZone) -> Array[TeamSpawn]:
	var result : Array[TeamSpawn] = [];
	
	for x in range(0,zone.grid_width-1):
		for y in range(0,zone.grid_height-1):
			if zone.grid[x][y].room_type != RoomType.EMPTY:
				if zone.grid[x][y].room_model.team_spawn.size() > 0:
					for i in range(0,zone.grid[x][y].room_model.team_spawn.size()):
						var team_spawn = zone.grid[x][y].room_model.team_spawn[i].duplicate();
						team_spawn.position = zone.grid[x][y].room_instance.global_transform.origin + team_spawn.position;
						result.append(team_spawn);
	
	return result;

func _check_room_special(room):
	return room.special_room;

func _clean_containment_zone(zone):
	zone.grid.clear();
	
	special_turns.clear();
	special_intersections.clear();
	special_t_intersections.clear();
	special_hallways.clear();
	special_dead_ends.clear();
	spawned_special_rooms.clear();
	
	if checkpoints.has(zone):
		checkpoints[zone].clear();
	completed_checkpoints.clear();
	
	room_counts.clear();
	room_dead_end_counts = 0;
	
	if get_node_or_null(zone.zone_name):
		for node in get_node(zone.zone_name).get_children():
			node.queue_free();
	
	#for x in range(0,zone.grid_width-1):
	#	for y in range(0,zone.grid_height-1):
	#		if zone.grid[x][y].room_type != RoomType.EMPTY:
	#			if zone.grid[x][y].room_instance:
	#				zone.grid[x][y].room_instance.queue_free();
	
	#for node in get_children():
	#	node.queue_free();


#extends Sprite2D

#@export var speed : float = 100

#@export var joystick_left : VirtualJoystick

#@export var joystick_right : VirtualJoystick

#var move_vector := Vector2.ZERO

#func _process(delta: float) -> void:
	## Movement using the joystick output:
#	if joystick_left and joystick_left.is_pressed:
#		position += joystick_left.output * speed * delta
	
	
	## Movement using Input functions:
#	move_vector = Vector2.ZERO
#	move_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
#	position += move_vector * speed * delta
	
	# Rotation:
#	if joystick_right and joystick_right.is_pressed:
#		rotation = joystick_right.output.angle()
