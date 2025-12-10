class_name Bullet
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var direction: Vector2
var num_collisions: int = 0
var pool: Pool

func _ready() -> void:
	direction = Vector2(randf() - .5, randf() - .5).normalized()
	collision_mask = 1

func _physics_process(delta: float) -> void:
	velocity = direction * SPEED * delta

	var collision: KinematicCollision2D = move_and_collide(velocity)
	if collision:
		if num_collisions == 0:
			collision_mask = 3
		num_collisions += 1
		if num_collisions > 10:
			pool.refund(self)
		direction = direction.bounce(collision.get_normal())
