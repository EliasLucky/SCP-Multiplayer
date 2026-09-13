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

class_name ProgressionCondition
extends Resource

@export var progression_condition_name : String = "";
@export var xp_increase : float = 0;

func serialize() -> Dictionary:
	return {
		"name": progression_condition_name,
		"xp_increase": xp_increase
	}

#class_name PlayGamesSnapshotConflict extends RefCounted
## A class representing a conflict when saving or loading data.
##
## This is a GDSCript representation of Google's [url=https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.SnapshotConflict]SnapshotConflict[/url].

#var origin: String ## The original caller of the method, either "SAVE" or "LOAD"
#var conflict_id: String ## The conflict id.
#var conflicting_snapshot: PlayGamesSnapshot ## The modified version of the Snapshot in the case of a conflict. This may not be the same as the version that you tried to save.
#var server_snapshot: PlayGamesSnapshot ## The most-up-to-date version of the Snapshot known by Google Play games services to be accurate for the player’s device.

## Constructor that creates a SnapshotConflict from a [Dictionary] containing the properties.
#func _init(dictionary: Dictionary) -> void:
#	if dictionary.has("origin"): origin = dictionary.origin
#	if dictionary.has("conflictId"): conflict_id = dictionary.conflictId
#	if dictionary.has("conflictingSnapshot"): conflicting_snapshot = PlayGamesSnapshot.new(dictionary.conflictingSnapshot)
#	if dictionary.has("serverSnapshot"): server_snapshot = PlayGamesSnapshot.new(dictionary.serverSnapshot)

#func _to_string() -> String:
#	var result := PackedStringArray()
	
#	result.append("origin: %s" % origin)
#	result.append("conflict_id: %s" % conflict_id)
#	result.append("conflicting_snapshot: {%s}" % conflicting_snapshot)
#	result.append("server_snapshot: {%s}" % server_snapshot)
	
#	return ", ".join(result)
