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

class_name TeamSpawn
extends Resource

@export var team : Team
@export var team_class : TeamClass

@export var position : Vector3 = Vector3.ZERO;
@export var rotation : Vector3 = Vector3.ZERO; 


#class_name PlayGamesSnapshot extends RefCounted
## A snapshot.
##
## This is a GDScript representation of Google's [url=https://developers.google.com/android/reference/com/google/android/gms/games/snapshot/Snapshot]Snapshot[/url].

## Constant passed to the [method show_saved_games] method to not limit the number of displayed saved files.  
#const DISPLAY_LIMIT_NONE := -1

#var content: PackedByteArray ## A [PackedByteArray] with the contents of the snapshot.
#var metadata: PlayGamesSnapshotMetadata ## The metadata of the snapshot.

## Constructor that creates a Snapshot from a [Dictionary] containing the properties.
#func _init(dictionary: Dictionary) -> void:
#	if dictionary.has("content"): content = dictionary.content
#	if dictionary.has("metadata"): metadata = PlayGamesSnapshotMetadata.new(dictionary.metadata)

#func _to_string() -> String:
#	var result := PackedStringArray()
	
#	result.append("content: %s" % content)
#	result.append("metadata: {%s}" % metadata)
	
#	return ", ".join(result)
