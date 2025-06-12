extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	hurt
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var reload_timer: Timer = $ReloadTimer

@export var max_speed = 180.0
@export var acceleration = 400
@export var deceleration = 400

const JUMP_VELOCITY = -350.0
var direction = 0
var status: PlayerState

var is_in_corrupted_world = false
signal request_world_change

func _ready():
	go_to_idle_state()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle: idle_state(delta)
		PlayerState.walk: walk_state(delta)
		PlayerState.jump: jump_state(delta)
		PlayerState.fall: fall_state(delta)
		PlayerState.hurt: hurt_state(delta)

	move_and_slide()

# --- Estados de Animação ---
func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_hurt_state():
	if status != PlayerState.hurt:
		status = PlayerState.hurt
		anim.play("hurt")
		velocity.x = 0
		reload_timer.start()

# --- Lógica de estados ---
func idle_state(delta):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()

func walk_state(delta):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		go_to_jump_state()
	elif not is_on_floor():
		go_to_fall_state()

func jump_state(delta):
	move(delta)
	if velocity.y > 0:
		go_to_fall_state()

func fall_state(delta):
	move(delta)
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()

func hurt_state(_delta): pass

# --- Movimento e direção ---
func move(delta):
	update_direction()
	velocity.x = move_toward(velocity.x, direction * max_speed if direction else 0, (acceleration if direction else deceleration) * delta)

func update_direction():
	direction = Input.get_axis("left", "right")
	anim.flip_h = direction < 0

# --- Colisores ---
func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

# --- Detecção de dano ---
func _on_hitbox_area_entered(area: Area2D):
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func _on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("LethalArea"):
		go_to_hurt_state()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		go_to_hurt_state()

func hit_lethal_area():
	go_to_hurt_state()

func _on_reload_timer_timeout():
	get_tree().reload_current_scene()

# --- Animação de troca de mundo ---
func trigger_world_change():
	anim.play("change_world")
	await anim.frame_changed
	if anim.frame == 2:
		emit_signal("request_world_change")
	await anim.animation_finished
