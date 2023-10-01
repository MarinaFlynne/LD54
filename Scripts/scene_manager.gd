# Adapted from https://www.nightquestgames.com/changing-scenes-in-godot-4-is-easy/ 
# This script manages scene switching within the game.
# When the current scene needs to switch to a different scene, they can send a request
# to this scene manager.
# The scene manager is added as an autoload in project settings.
extends Node
class_name NSceneManager

# A collection of scenes in the game. Scenes are added through the Inspector panel
# Key: scene alias as a String, value: path to scene (MUST be of StringName type)
@export var Scenes : Dictionary = {}
@export var fadePath: NodePath

# Alias of the currently selected scene
var m_CurrentSceneAlias: String = ""

# Description: Find the initial scene as defined in the project settings
func _ready() -> void:
	var mainScene : StringName = ProjectSettings.get_setting("application/run/main_scene")
	m_CurrentSceneAlias = Scenes.find_key(mainScene)

# Description: Add a new scene to the scene collection
# Parameter sceneAlias: The alias used for finding the scene in the collection
# Parameter scenePath: The full path to the scene file in the file system
func AddScene(sceneAlias : String, scenePath : String) -> void:
	Scenes[sceneAlias] = scenePath
	
# Description: Remove an existing scene from the scene collection
# Parameter sceneAlias: The scene alias of the scene to remove from the collection
func RemoveScene(sceneAlias : String) -> void:
	Scenes.erase(sceneAlias)
	
# Description: Switch to the requested scene based on its alias
# Parameter sceneAlias: The scene alias of the scene to switch to
func SwitchScene(sceneAlias : String, fade = true) -> void:
	var fadeNode = get_node(fadePath)
	if fade:
		fadeNode.play("Fade")
		await fadeNode.animation_finished
	get_tree().change_scene_to_file(Scenes[sceneAlias])
	if fade:
		await get_tree().create_timer(0.7).timeout
		fadeNode.play_backwards("Fade")
 
# Description: Restart the current scene
func RestartScene() -> void:
	get_tree().reload_current_scene()
	
# Description: Quit the game
func QuitGame() -> void:
	get_tree().quit()
	
# Description: Return the number of scenes in the collection
func GetSceneCount() -> int:
	return Scenes.size()
	
# Description: Returns the alias of the current scene
func GetCurrentSceneAlias() -> String:
	return m_CurrentSceneAlias
