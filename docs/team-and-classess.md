# Team and Classess

# Round System Structure

`Team` and `TeamClass` classess are responsible for all the things that are related to teams.

## Team Settings

`Team` resource file consists of multiple `@export var`(s) fields.

**General**
- `team_id` (int) Team Id which is used for `RoundSettings` `spawn_team_order`. All IDs in spawn_team_order are supposed to be: `0 - SCP, 1 - Guard, 4 - CD, 3 - Scientist, 2 - Any other team`.
- `team_name` (String) Name of the team
- `team_primary_color` (Color) Primary color of the team that can be used to color UI messages.
- `team_secondary_color` (Color) Secondary color of the team that can be used to color UI messages.
- `team_direction_one` (String) Team direction one which will be shown for the player in the "You spawned as" UI.
- `team_direction_two` (String) Team direction one which will be shown for the player in the "You spawned as" UI.
- `team_direction_three` (String) Team direction one which will be shown for the player in the "You spawned as" UI.

- `classes` (Array[TeamClass]) Team classess. Team does not require any Team Classess but it can. For example, `Team` MTF; `TeamClass` MTF Commander, `TeamClass` MTF Liutenant, `TeamClass` MTF Cadet.
- `friendly_teams` (Array[Team]) Array of Teams that this Team is friendly with. Used for combat part of the game.
- `inventory_data` (Array[ItemData]) Array of items that will appear in player's inventory after spawn.

**Rank and Abiltiy System**
- `use_ranks` (bool) Whether `ProgressionRank`(s) will be present in the team or not. It was planned as an abilities system for SCPs. Player would get more abilities after completing specific quotas.
- `ranks` (Array[ProgressionRank]) Array of progression ranks that are available for this team. `ProgressionRank` contains abilities that will be opened and progress conditions. For more info scroll down.
- `abilities` (Array[Ability]) Array of abilities that the team have.

**Player Stats**
- `custom_walk_speed` (int) Custom walk speed for the players spawned as this team. If set as -1 then player's default walking speed will be used.
- `custom_sprint_speed` (int) Custom sprint speed for the players spawned as this team. If set as -1 then player's default sprint speed will be used.
- `custom_jump_velocity` (int) Custom jump velocity for the players spawned as this team. If set as -1 then player's default jump velocity will be used.
- `can_walk` (bool) Whether or not can the players spawned as this team walk.
- `can_sprint` (bool) Whether or not can the players spawned as this team sprint.
- `can_jump` (bool) Whether or not can the players spawned as this team jump.
- `can_crouch` (bool) Whether or not can the players spawned as this team crouch.
- `custom_health` (float) Custom health for the players spawned as this team. If set as -1.0 then player's default health will be used.
- `custom_max_health` (float) Custom max health for the players spawned as this team. If set as -1.0 then player's default max health will be used.
- `custom_stamina` (float) Custom stamina for the players spawned as this team. If set as -1.0 then player's default stamina will be used.
- `custom_max_stamina` (float) Custom max stamina for the players spawned as this team. If set as -1.0 then player's default max stamina will be used.
- `player_model` (String) Custom player.

**Custom HUD**
- `hud` (String) This property depends on how multiplayer will be made in the future. Supposedly, `Player` class and scene have HUD with specific names that can be shown and hidden. Supposedly, it could be an `PackedScene` with `Control` node as the root containing HUD of the team BUT it is not possible to send through RPC signals a `PackedScene`.

**Escapee**
- `escapee` (bool) Whether or not the team is an escapee team (e.g. Class-D or Scientists)
- `escaped_spawn_team` (Team) Team that the player will spawn as after escape.
- `escaped_spawn_class` (TeamClass) Team Class that the player will spawn as after escape.
- `count_escape_as_classd` (bool) Whether or not count the player's escape as Class-D escapes in the `RoundSystem` round stats.
- `count_escape_as_foundation` (bool) Whether or not count the player's escape as Foundation escapes in the `RoundSystem` round stats.

**Spawnwave**
- `initial_spawn_enabled` (bool) 
- `spawnwave` (bool) Whether or not the team is a spawnwave team. It is important to set for `RoundSystem` which checks for available spawnwave teams.
- `unit_of` (String)

**Spawnwave Properties** (NOT yet IMPLEMENTED)
- `spawn_for_biohazard` (bool) Spawnwave team property which implies that if biohazard danger is present in the faciltiy (e.g. SCP-008 or SCP-610 containment breach is present) then this team is preferable for spawn.
- `spawn_for_firehazard` (bool) Spawnwave team property which implies that if firehazard danger is present in the faciltiy (e.g. SCP-457 containment breach is present) then this team is preferable for spawn.
- `spawn_for_reinforcements` (bool) Spawnwave team property which implies that if serious danger is present in the faciltiy (e.g. SCP-682 containment breach is present) then this team is preferable for spawn.

**Spawnwave Altering** (NOT yet IMPLEMENTED)
- `spawn_biohazard` (bool) ???
- `spawn_firehazard` (bool) ???
- `spawn_reinforcements` (bool) ???

**Infection Team Type**
- `scp008` (bool) Whether or not the Team is an SCP-008 infection team.
- `scp610` (bool) Whether or not the Team is an SCP-610 infection team.
- `zombie` (bool) Whether or not the Team is an zombie infection team. This parameter is used for custom infection teams (e.g. for EVENT rounds).


## Team Class Settings

Most properties are the same as the ones from `Team` class but with some additions.
- `spawn_only_once` (bool) Whether or not the Team Class should spawn only once. For example, `Team` - SCP; `TeamClass` - SCP-096 (spawn_only_once=true).
- `spawn_chance` (float) The spawn chance of the Team Class to be spawned. **NOT USED**
- `spawn_only_if_other_classess_present` (bool) Whether or not the Team Class should spawn only if other classess has been already spawned. **NOT USED**

## Team Spawn Settings

`TeamSpawn` class is used to allow `Team` to be spawned in the specific room where `TeamSpawn` is attached to.
In order to attach `TeamSpawn` to your `RoomModel` resource: Use `team_spawn` (Array[TeamSpawn]) property and set the properties you need.

**NOTE:** Do not create new `Team` `.tres` resource for `TeamSpawn`. Use the one you already created and the one that is present in `RoundSettings`!

Properties of `TeamSpawn` are:
- `team` (Team) Team related to this `TeamSpawn`.
- `team_class` (TeamClass) Team Class related to this `TeamSpawn`.
- `position` (Vector3) Position at which the player will spawn. Position is local because `TeamSpawn` is attached to the room.
- `rotation` (Vector3) Rotation at which the player will spawn.
