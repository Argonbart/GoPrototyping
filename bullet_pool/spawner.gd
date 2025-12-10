extends Node2D


@export var timer: Timer
@export var bullet: PackedScene
@export var bullet_label: RichTextLabel
@export var fps_label: RichTextLabel

var pool: Pool
var bullet_counter: int = 0


func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	
	pool = Pool.new()
	
	var create: Callable = func(): 
		var new_bullet: Bullet = bullet.instantiate() as Bullet
		self.add_child(new_bullet)
		new_bullet.owner = self
		new_bullet.pool = pool
		return new_bullet
		
	var reset: Callable = func(object: Bullet): 
		self.remove_child(object)
		object.num_collisions = 0
	
	pool.setup(create, reset, 128)	


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	bullet_label.text = ("Pool: " + str(pool.objects.size()) + "\n" +
						 "Bullets: " + str(self.get_child_count()))


func _on_timeout() -> void:
	for i in 10:
		pool.request()
		#var new_bullet: Bullet = bullet.instantiate() as Bullet
		#self.add_child(new_bullet)
		#new_bullet.owner = self
