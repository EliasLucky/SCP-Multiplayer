#class_name GlobalTimers
extends Node

signal spawnwave_timer_timeout
signal spawnwave_timer_animation_start
signal lcz_decontamination_timer_timeout
signal hcz_decontamination_timer_timeout
signal lcz_prevent_stalling_timer_timeout
signal omega_warhead_detonation_timer_timeout
signal omega_warhead_detonation_animation_start
signal alpha_warhead_detonation_timer_timeout
signal alpha_warhead_detonation_animation_start

@export var spawnwave_timer : Timer
@export var lcz_decontamination_timer : Timer
@export var hcz_decontamination_timer : Timer
@export var lcz_prevent_stalling_timer : Timer
@export var omega_warhead_detonation_timer : Timer
@export var alpha_warhead_detonation_timer : Timer

@export var lcz_decontamination_wait_before_activation : int = 10;
@export var hcz_decontamination_wait_before_activation : int = 40;

var saved_spawnwave_timer_waiting_time : int = 0;
var saved_lcz_decontamination_timer_waiting_time : int = 0;
var saved_hcz_decontamination_timer_waiting_time : int = 0;
var saved_omega_warhead_detonation_timer_waiting_time : int = 0;
var saved_alpha_warhead_detonation_timer_waiting_time : int = 0;

#var lcz_decontamination_timer_stalling_flag : bool = false;

func _ready() -> void:
	spawnwave_timer.timeout.connect(_spawnwave_timer_timeout);
	lcz_decontamination_timer.timeout.connect(_lcz_decontamination_timer_timeout);
	hcz_decontamination_timer.timeout.connect(_hcz_decontamination_timer_timeout);
	lcz_prevent_stalling_timer.timeout.connect(_lcz_prevent_stalling_timer_timeout);
	omega_warhead_detonation_timer.timeout.connect(_omega_warhead_detonation_timer_timeout);
	alpha_warhead_detonation_timer.timeout.connect(_alpha_warhead_detonation_timer_timeout);

func _process(_delta: float) -> void:
	_check_spawnwave_timer();
	_check_lcz_decontamination_timer();
	_check_hcz_decontamination_timer();
	_check_omega_warhead_detonation_timer();
	_check_alpha_warhead_detonation_timer();

func _check_spawnwave_timer():
	if spawnwave_timer.time_left == 20: #saved_spawnwave_timer_waiting_time:
		spawnwave_timer_animation_start.emit();

func _check_lcz_decontamination_timer():
	if lcz_decontamination_timer.time_left == 600:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_10_MINUTES_ACTIVATE);
	elif lcz_decontamination_timer.time_left == 480:
		if saved_lcz_decontamination_timer_waiting_time == 480:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_8_MINUTES_ACTIVATE);
		else:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_8_MINUTES);
	elif lcz_decontamination_timer.time_left == 300:
		if saved_lcz_decontamination_timer_waiting_time == 300:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_5_MINUTES_ACTIVATE);
		else:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_5_MINUTES);
	elif lcz_decontamination_timer.time_left == 180:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_3_MINUTES);
	elif lcz_decontamination_timer.time_left == 60:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_1_MINUTE);
	elif lcz_decontamination_timer.time_left == 30:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_30_SECONDS);

func _check_hcz_decontamination_timer():
	#if hcz_decontamination_timer.time_left == 600:
	#	pass;
	if hcz_decontamination_timer.time_left == 480:
		if saved_hcz_decontamination_timer_waiting_time == 480:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_8_MINUTES_ACTIVATE);
		#else:
		#	AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_8_MINUTES);
	elif hcz_decontamination_timer.time_left == 300:
		if saved_hcz_decontamination_timer_waiting_time == 300:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_5_MINUTES_ACTIVATE);
		else:
			AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_5_MINUTES);
	elif hcz_decontamination_timer.time_left == 180:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_3_MINUTES);
	elif hcz_decontamination_timer.time_left == 60:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_1_MINUTE);
	elif hcz_decontamination_timer.time_left == 30:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_30_SECONDS);

func _check_omega_warhead_detonation_timer():
	if saved_omega_warhead_detonation_timer_waiting_time == 180:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.OMEGA_WARHEAD_WILL_BE_DETONATED_IN_180_SECONDS);
	elif saved_omega_warhead_detonation_timer_waiting_time == 120:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.OMEGA_WARHEAD_WILL_BE_DETONATED_IN_120_SECONDS);
	
	if omega_warhead_detonation_timer.time_left == 30:
		omega_warhead_detonation_animation_start.emit();

func _check_alpha_warhead_detonation_timer():
	#if saved_omega_warhead_detonation_timer_waiting_time == 180:
	#	AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.ALPHA_WARHEAD_DETONATION_3_MINUTES);
	if saved_alpha_warhead_detonation_timer_waiting_time == 120:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.ALPHA_WARHEAD_WILL_BE_DETONATED_IN_120_SECONDS);
	elif saved_alpha_warhead_detonation_timer_waiting_time == 90:
		AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.ALPHA_WARHEAD_WILL_BE_DETONATED_IN_90_SECONDS);
		
	if alpha_warhead_detonation_timer.time_left == 15:
		alpha_warhead_detonation_animation_start.emit();

func start_spawnwave_timer(start_time = null):
	if start_time:
		saved_spawnwave_timer_waiting_time = start_time;
		
		spawnwave_timer.stop();
		spawnwave_timer.wait_time = start_time;
		spawnwave_timer.start();
	else:
		spawnwave_timer.paused = false;

func stop_spawnwave_timer():
	spawnwave_timer.paused = true;

func _spawnwave_timer_timeout():
	spawnwave_timer_timeout.emit();
	
	#start_spawnwave_timer(saved_spawnwave_timer_waiting_time);
	spawnwave_timer.start();

## TO start LCZ decontamination use this function
func start_lcz_decontamination_timer(start_time = null):
	if start_time:
		saved_lcz_decontamination_timer_waiting_time = start_time - lcz_decontamination_wait_before_activation;
		
		lcz_decontamination_timer.stop();
		lcz_decontamination_timer.wait_time = start_time;
		lcz_decontamination_timer.start();
	else:
		lcz_decontamination_timer.paused = false;

## To stop LCZ decontamination use this function
func stop_lcz_decontamination_timer():
	lcz_decontamination_timer.paused = true;

func _lcz_decontamination_timer_timeout():
	AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.LCZ_DECONTAMINATION_START);
	
	lcz_decontamination_timer_timeout.emit(false);
	lcz_decontamination_timer.stop();

## To start HCZ decontamination use this function
func start_hcz_decontamination_timer(start_time = null):
	if start_time:
		saved_hcz_decontamination_timer_waiting_time = start_time - hcz_decontamination_wait_before_activation;
		
		hcz_decontamination_timer.stop();
		hcz_decontamination_timer.wait_time = start_time;
		hcz_decontamination_timer.start();
	else:
		hcz_decontamination_timer.paused = false;

## To stop HCZ decontamination use this function
func stop_hcz_decontamination_timer():
	hcz_decontamination_timer.paused = true;

func _hcz_decontamination_timer_timeout():
	AnnouncementSystem.play_announcement(AnnouncementSystem.AnnouncementType.HCZ_DECONTAMINATION_START);
	
	if saved_hcz_decontamination_timer_waiting_time < saved_lcz_decontamination_timer_waiting_time:
		lcz_prevent_stalling_timer.start();
	
	hcz_decontamination_timer_timeout.emit();

func _lcz_prevent_stalling_timer_timeout():
	lcz_decontamination_timer_timeout.emit(true)

## To start omega warhead detonation sequence use this function.
func start_omega_warhead_detonation_timer(start_time = null):
	if start_time:
		saved_omega_warhead_detonation_timer_waiting_time = start_time;
		
		omega_warhead_detonation_timer.stop();
		omega_warhead_detonation_timer.wait_time = start_time;
		omega_warhead_detonation_timer.start();
	else:
		AnnouncementSystem.play_announcement(AnnouncementSystem.DETONATION_RESUMED);
		
		omega_warhead_detonation_timer.paused = false;

## To stop omega warhead detonation sequence use this function.
func stop_omega_warhead_detonation_timer():
	AnnouncementSystem.play_announcement(AnnouncementSystem.DETONATION_CANCELLED);
	
	omega_warhead_detonation_timer.paused = true;

func _omega_warhead_detonation_timer_timeout():
	AnnouncementSystem.play_announcement(AnnouncementSystem.OMEGA_WARHEAD_DETONATION);
	
	omega_warhead_detonation_timer_timeout.emit();

## To start alpha warhead detonation sequence use this function
func start_alpha_warhead_detonation_timer(start_time = null):
	if start_time:
		saved_alpha_warhead_detonation_timer_waiting_time = start_time;
		
		alpha_warhead_detonation_timer.stop();
		alpha_warhead_detonation_timer.wait_time = start_time;
		alpha_warhead_detonation_timer.start();
	else:
		AnnouncementSystem.play_announcement(AnnouncementSystem.DETONATION_RESUMED);
		
		alpha_warhead_detonation_timer.paused = false;

## To stop alpha warhead detonation sequence use this function
func stop_alpha_warhead_detonation_timer():
	AnnouncementSystem.play_announcement(AnnouncementSystem.DETONATION_CANCELLED);
	
	alpha_warhead_detonation_timer.paused = true;

func _alpha_warhead_detonation_timer_timeout():
	AnnouncementSystem.play_announcement(AnnouncementSystem.ALPHA_WARHEAD_DETONATION);
	
	alpha_warhead_detonation_timer_timeout.emit();
