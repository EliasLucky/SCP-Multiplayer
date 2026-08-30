class_name RoundControl
extends Node

@export var round_system : RoundSystem

var previous_state;
@rpc("any_peer","reliable")
func admin_lock_round():
	previous_state = round_system.current_round_state;
	round_system.current_round_state = round_system.RoundState.LOCKED;

@rpc("any_peer","reliable")
func admin_unlock_round():
	if previous_state:
		round_system.current_round_state = previous_state;

@rpc("any_peer","reliable")
func admin_force_round_start():
	round_system.attempt_start_round(true);

@rpc("any_peer","reliable")
func admin_force_end_round():
	round_system.end_round("ROUND FORCED TO END", Color.WHITE);

func start_omega_warhead():
	GlobalTimers.start_omega_warhead_detonation_timer(round_system.round_settings.omega_warhead_detonation_waiting_time);

func stop_omega_warhead():
	GlobalTimers.stop_omega_warhead_detonation_timer();

func switch_remote_control_omega_warhead():
	pass;

@rpc("reliable")
func admin_lock_omega_warhead():
	pass;

func detonate_omega_warhead():
	pass;


func start_alpha_warhead():
	GlobalTimers.start_alpha_warhead_detonation_timer();

func stop_alpha_warhead():
	GlobalTimers.stop_alpha_warhead_detonation_timer();

func switch_remote_control_alpha_warhead():
	pass;

func lock_alpha_warhead():
	pass;

func detonate_alpha_warhead():
	pass;


func enable_lcz_decontamination():
	GlobalTimers.start_lcz_decontamination_timer();

func disable_lcz_decontamination():
	GlobalTimers.stop_lcz_decontmaination_timer();

func start_lcz_decontamination():
	pass;

func enable_hcz_decontamination():
	pass;

func disable_hcz_decontamination():
	pass;

func activate_timer_hcz_decontamination():
	pass;

func start_hcz_decontamination():
	pass;


func enable_friendly_fire():
	pass;

func disable_friendly_fire():
	pass;
