# Round System Structure

`RoundSystem` class is responsible for all the things that are related to rounds. Round System can be easily customized through `RoundSettings` resources.

## Round Settings

`RoundSettings` resource file consists of multiple `@export var`(s) fields.

**Round**
- `containment_zones` (Array[ContainmentZone]) Array of `ContainmentZone` `.tres` resources. These are the containment zones that will be generated and present in round.
- `spawn_team_order` (String) A series of numbers in which each number represents a team. During initial player spawn the `RoundSystem` goes through each number from start to the amount of players present in-game and assigns players to the specific team that the number represents (if there are 3 players in-game and if the order is `401431304134` then there will be 3 players spawned as teams with IDs `4`,`0`,`1` because going through the start). All IDs in spawn_team_order are supposed to be: `0 - SCP, 1 - Guard, 4 - CD, 3 - Scientist, 2 - Any other team`. In addition, you may add new numbers to the `spawn_team_order` but be careful because `spawn_team_order` heavily depends on the amount of players present in the lobby. You must ensure that important teams (SCPs, ClassD and etc.) will spawn even if the amount of players is small in the game.
- `teams` (Array[Team]) is an Array of `Team` `.tres` resources. There are the teams that will be present in the round. 0th index of teams array is expected to be Spectator team.
- `event_rounds` (Array[RoundSettings]) Array of `RoundSettings` `.tres` resources. It was made so it would be possible for special `EVENT` rounds to appear.

**Map**
- `spawnwaves_enabled` (bool) Whether spawnwaves will be present in the round or not.
- `spawnwave_waiting_time` (String) The amount of time in seconds that needs to be passed for next spawnwave to occur. Only these choices are available: `600`,`400`,`300`,`180`,`120`,`60` for good in-game experience.
- `lcz_decontamination_enabled` (bool) LCZ Decontamination will be in the round from the start or not. LCZ Decontamination sequence can still be started through Admin Panel.
- `lcz_decontamination_waiting_time` (String) The amount of time in seconds that needs to be passed for LCZ Decontamination process to start. Only these choices are available: `600`,`480`,`300` for good in-game experience.
- `hcz_decontamination_enabled` (bool) HCZ Decontamination will be in the round from the start or not.
- `hcz_decontamination_waiting_time` (String) The amount of time in seconds that needs to be passed for HCZ Decontamination process to start. Only these choices are available: `480`,`300` for good in-game experience.
- `can_activate_hcz_decontamination` (bool) Whether or not HCZ Decontamination can be activated manually from the Heavy Containment Zone by players. It was planned as a special feature for the game in which a special control room would spawn. HCZ Decontamination may require a condition for it to be enabled manually if biohazard SCPs (SCP-008,SCP-610 and etc.) are present.
- `activate_hcz_decontamination_only_on_biohazard` (bool) Whether or not HCZ Decontamination can be activated manually only if biohazard SCPs (SCP-008,SCP-610 and etc.) are present.
- `ocz_enabled` (bool) Whether or not Organic Containment Zone (OCZ) will be generated in round. It was planned as a special new fourth containment zone.
- `custom_map` (PackedScene) If set then no facility will be generated and instead the custom map will be used.
- `custom_map_team_spawn` (Array[TeamSpawn) Replaces `teams` option if `custom_map` is present.

**Warhead**
Clarifications: Omega Warhead supposed to detonate underground sections of the facility. Alpha Warheads supposed to detonate facility surface. If Alpha Warhead was detonated spawnwaves are disabled.
- `omega_warhead_enabled` (bool) Can Omega Warhead be detonated by players or not.
- `alpha_warhead_enabled` (bool) Can Alpha Warheads be detonated by players or not.
- `omega_warhead_waiting_time` (String) The amount of time in seconds that needs to be passed for Omega Warhead detonation to occur. Only these choices are available: `180`,`120`.
- `alpha_warhead_waiting_time` (String) The amount of time in seconds that needs to be passed for Alpha Warhead detonation to occur. Only these choices are available `180`,`120`,`90`.
- `omega_warhead_initial_detonation` (bool) Will Omega Warhead detonation sequence activate from the start of the round or not.
- `alpha_warhed_initial_detonation` (bool) Will Alpha Warhead detonation sequence activate from the start of the round or not.

**Infections**
- `scp008_enabled` (bool) Will players with SCP-008 `TeamClass` be able to infect other players or not. If false then the SCP-008 in the SCP-008 Containment Chamber should (supposed) not infect players either.
- `scp610_enabled` (bool) Will players with SCP-610 `TeamClass` be able to infect other players or not.

## Stages

Round System consists of multiple stages `INTERMISSION, LOADING, ON_GOING, FINISHED, LOCKED`.
- `INTERMISSION` During this stage Round System re-tries after every 8 seconds to start the round. Starting the round requires atleast 3 players to be present in the lobby. In addition round start can be forced through Admin Panel (`if players.size() >= 3 and force:` the `force` variable is responsible for this).
- `LOADING` During this stage Round System checks if it is possible to start `EVENT` round (If `event_rounds` array in `RoundSettings` is not empty then after every 3 rounds there is 50/50 chance to start one.). After checking for event rounds, facility is being generated and teams are being spawned.
- `ON_GOING` During this stage the game is on going.
- `FINISHED` During this stage a *Winner* screen appears to all the players for period of time and then everything is being reset.
- `LOCKED` During this stage it is not possible to have a *Winner* in round. Round can be locked through Admin Panel.

