extends Area2D
class_name Bullet
## A node used for [Gun]
##
## This node is used for [Gun], acts like a bullet with configurable speed and angle( for gun )

@export_category("Bullet")

## The time in seconds where this bullet is deleted
@export var delete_after : int = 30 

## speed of the bullet in pixels per second
var speed : float=2000.0

## angle of the bullet when fired
var angle : float = 0.0

## used to track time for [delete_after], best not to change it to avoid errors
var time = 0

func _ready():
	if delete_after == 0:
		var screen_checker = VisibleOnScreenNotifier2D.new()
		add_child(screen_checker)
		screen_checker.connect("screen_exited()",on_screen_exited)


func _physics_process(delta):
	rotation_degrees = angle
	position += (Vector2.from_angle(rotation) * speed) * delta
	if delete_after > 0:
		time += delta
		if time >= delete_after:
			queue_free()

# Erase Bullet instance when bullet exited from screen
func on_screen_exited():
	queue_free()

# Erase Bullet instance when bullet enters on a body
func _on_body_entered(_body):
	queue_free()

# Erase Bullet when collides with an enemy.
# Certain enemies could be 2D Areas instead of bodies. This function prevents errors with this type of enemy.
func _on_area_entered(area):
	if area.is_in_group("EnemiesCollisions"):
		queue_free()
