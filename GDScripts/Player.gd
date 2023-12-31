extends CharacterBody2D

class_name Player
signal healthChanged

const NORMAL_SPEED=350.0
var SPEED = NORMAL_SPEED
const JUMP_VELOCITY = -450.0
#Preload for the "Bullet" scene. Required to instance bullets.
const bulletPath = preload("res://GDScenes/bullet.tscn")
const scythePath = preload("res://GDScenes/weapon_scythe.tscn")
var JUMP_COUNTER=2 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")+100
var canMelee : bool = true
@onready var cooldownBullet=$CooldownBullet
@onready var cooldownScythe=$CooldownScythe

@export var maxHealth = 20
@export var currentHealth = maxHealth


func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
		# If defined for when the player is on air whithout jumping previously, not keeping two jumps on air and instead just be able jump once
		if JUMP_COUNTER==2:
			JUMP_COUNTER=JUMP_COUNTER-1;
	else:
		JUMP_COUNTER=2
	
	if Input.is_action_pressed("go_right") and $Sprite2D.flip_h==true:
		$Sprite2D.flip_h=false
	if Input.is_action_pressed("go_left") and $Sprite2D.flip_h==false:
		$Sprite2D.flip_h=true
	# Get the input direction and handle the movement/deceleration.
	var directionH = Input.get_axis("go_left", "go_right")
	if directionH:
		velocity.x = directionH * SPEED
		$PlayerAnim.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$PlayerAnim.play("walk")
		
	
	# Jump.
	if Input.is_action_just_pressed("jump") and JUMP_COUNTER>0:
		if Input.is_action_pressed("sprint") and velocity.x!=0:
			velocity.y = JUMP_VELOCITY*1.15
		else:
			velocity.y = JUMP_VELOCITY
		JUMP_COUNTER=JUMP_COUNTER-1
		
	# Sprint code.
	# Keep "shift" pressed for sprint. Release for default speed.
	if Input.is_action_just_pressed("sprint"):
		SPEED=SPEED+200
	if Input.is_action_just_released("sprint") and SPEED!=NORMAL_SPEED:
		SPEED=NORMAL_SPEED
	# Press "S" when on air for fast fall. Increases fall velocity.
	if Input.is_action_just_pressed("go_down") and not is_on_floor():
		velocity.y=-(JUMP_VELOCITY*1.75)+(JUMP_VELOCITY/1.5)
	#Stop pressing "S" for returning to normal fall velocity.
	if Input.is_action_just_released("go_down") and not is_on_floor():
		velocity.y=-JUMP_VELOCITY
	#Invoke the shoot function
	if Input.is_action_pressed("shoot") and cooldownBullet.is_stopped():
		shoot()
	if Input.is_action_just_pressed("melee_attack") and canMelee==true:
		if is_on_floor():
			melee_attack(true)
		if !is_on_floor():
			melee_attack(false)
	move_and_slide()
	
# Shooting bullets
func shoot():
	var _Bullet=bulletPath.instantiate()
	add_child(_Bullet)
	if $Sprite2D.flip_h==true:
		_Bullet.global_position=self.position+Vector2(-40,0)
		_Bullet.angle=180.0
	if $Sprite2D.flip_h==false:
		_Bullet.global_position=self.position+Vector2(40,0)
		_Bullet.angle=0.0
	cooldownBullet.start()
	InputHelper.rumble_small()

# Melee attack
func melee_attack(onGround):
	var _Scythe = scythePath.instantiate()
	add_child(_Scythe)
	_Scythe.global_position=self.position
	_Scythe._animations(onGround)
	cooldownScythe.start()
	canMelee=false

func _on_cooldown_scythe_timeout():
	canMelee=true

func _on_player_area_area_entered(area):
	var areaName=area.get_name()
	if area.is_in_group("EnemiesCollisions"):
		currentHealth-=10
		healthChanged.emit()
		InputHelper.rumble_medium()
		if currentHealth<=0:
			InputHelper.rumble_large()
			get_tree().reload_current_scene()
