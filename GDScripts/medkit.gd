extends Area2D

@onready var interaction_area=$InteractionArea
@onready var player=get_tree().get_first_node_in_group("Player")
@export var cureValue = 5

# This object is meant to recover a small amount of the players life points.
# Based on the InteractManager autoload

func _ready():
	interaction_area.interact=Callable(self, "_use_medkit")

func _use_medkit():
	player.currentHealth+=cureValue
	player.healthChanged.emit()
	queue_free()
