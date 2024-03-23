extends Node
class_name SceneManager

var currentWorld : Node

func loadGame(scene : PackedScene):
	var newWorld : Node = scene.instantiate()
	add_child(newWorld)
	currentWorld = newWorld
