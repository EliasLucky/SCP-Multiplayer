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

#class_name AnnouncementSystem
extends Node

@export var announcement_sound_player : AudioStreamPlayer3D
@export var warhead_announcement_sound_player : AudioStreamPlayer3D

enum AnnouncementType {
	CONTAINMENT_BREACHES,
	SCP_008_CONTAINMENT_BREACH,
	SCP_610_CONTAINMENT_BREACH,
	SCP_682_SURFACE_CONTAINMENT_BREACH,
	ALL_SCPS_SURFACE_CONTAINMENT_BREACH,
	
	SCP_008_RECONTAINED,
	SCP_035_RECONTAINED,
	SCP_049_RECONTAINED,
	SCP_079_RECONTAINED,
	SCP_096_RECONTAINED,
	SCP_106_RECONTAINED,
	SCP_173_RECONTAINED,
	SCP_457_RECONTAINED,
	SCP_610_RECONTAINED,
	SCP_682_RECONTAINED,
	SCP_745_RECONTAINED,
	SCP_939_RECONTAINED,
	
	LCZ_DECONTAMINATION_10_MINUTES_ACTIVATE,
	LCZ_DECONTAMINATION_8_MINUTES_ACTIVATE,
	LCZ_DECONTAMINATION_8_MINUTES,
	LCZ_DECONTAMINATION_5_MINUTES_ACTIVATE,
	LCZ_DECONTAMINATION_5_MINUTES,
	LCZ_DECONTAMINATION_3_MINUTES,
	LCZ_DECONTAMINATION_1_MINUTE,
	LCZ_DECONTAMINATION_30_SECONDS,
	LCZ_DECONTAMINATION_START,
	
	HCZ_DECONTAMINATION_8_MINUTES_ACTIVATE,
	HCZ_DECONTAMINATION_5_MINUTES_ACTIVATE,
	HCZ_DECONTAMINATION_5_MINUTES,
	HCZ_DECONTAMINATION_3_MINUTES,
	HCZ_DECONTAMINATION_1_MINUTE,
	HCZ_DECONTAMINATION_30_SECONDS,
	HCZ_DECONTAMINATION_START,
	
	BLACKOUT,
	
	OMEGA_WARHEAD_WILL_BE_DETONATED_IN_180_SECONDS,
	OMEGA_WARHEAD_WILL_BE_DETONATED_IN_120_SECONDS,
	ALPHA_WARHEAD_WILL_BE_DETONATED_IN_180_SECONDS,
	ALPHA_WARHEAD_WILL_BE_DETONATED_IN_120_SECONDS,
	ALPHA_WARHEAD_WILL_BE_DETONATED_IN_90_SECONDS,
	DETONATION_CANCELLED,
	DETONATION_RESUMED,
	OMEGA_WARHEAD_DETONATION,
	ALPHA_WARHEAD_DETONATION,
	
	MTF_EPSILON_11_ARRIVED,
	MTF_EPSILON_9_ARRIVED,
	MTF_BETA_7_ARRIVED,
	MTF_NU_7_ARRIVED,
	
	CI_ARRIVED
}

## Put your announcement audio files here as according to the order in AnnouncementType enum.
## Enum value is basically an integer. Therefore we can use it as an index from announcements array.
@export var announcements : Array[AudioStream] = [];
var warhead_announcements_position : Dictionary = {};

var play_announcement_queue : Array[AudioStream] = [];

func _ready() -> void:
	announcement_sound_player.finished.connect(_on_finished_playing);

func play_announcement(announcement : AnnouncementType):
	var sound : AudioStream = announcements[announcement];
	
	if _check_warhead_announcements(announcement):
		if warhead_announcement_sound_player.playing:
			warhead_announcements_position[sound] = warhead_announcement_sound_player.get_playback_position();
			warhead_announcement_sound_player.stop();
		
		warhead_announcement_sound_player.stream = sound
		
		if warhead_announcements_position[sound]:
			warhead_announcement_sound_player.play(warhead_announcements_position[sound]);
		else:
			warhead_announcement_sound_player.play();
		
		warhead_announcements_position.erase(sound);
		return;
	
	play_announcement_queue.append(sound);
	if play_announcement_queue.size() == 1:
		announcement_sound_player.stream = sound;
		announcement_sound_player.play();

#func pause_warhead_announcement():
#	var sound = warhead_announcement_sound_player.stream;
#	warhead_announcements_position[sound] = warhead_announcement_sound_player.get_playback_position();
#	warhead_announcement_sound_player.stop();

func _check_warhead_announcements(announcement : AnnouncementType):
	if announcement == AnnouncementType.OMEGA_WARHEAD_WILL_BE_DETONATED_IN_180_SECONDS \
		or announcement == AnnouncementType.OMEGA_WARHEAD_WILL_BE_DETONATED_IN_120_SECONDS \
		or announcement == AnnouncementType.ALPHA_WARHEAD_WILL_BE_DETONATED_IN_120_SECONDS \
		or announcement == AnnouncementType.ALPHA_WARHEAD_WILL_BE_DETONATED_IN_90_SECONDS \
		or announcement == AnnouncementType.DETONATION_CANCELLED \
		or announcement == AnnouncementType.DETONATION_RESUMED \
		or announcement == AnnouncementType.OMEGA_WARHEAD_DETONATION \
		or announcement == AnnouncementType.ALPHA_WARHEAD_DETONATION:
		return true;
	return false;

func _on_finished_playing():
	if play_announcement_queue.size() > 0:
		var sound = play_announcement_queue.pop_front();
		announcement_sound_player.stream = sound;
		announcement_sound_player.play();
