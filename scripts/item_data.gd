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

class_name ItemData
extends Resource

@export var item_name : String
@export var item_inventory_texture : Texture2D
@export var item_amount : int = 1

@export var item_model : PackedScene

#@export var item : ViewmodelResource

@export var item_spawn_position : Vector3
@export var item_spawn_rotation : Vector3
