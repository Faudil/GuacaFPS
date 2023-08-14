class_name PlayerInfo extends Object

var pseudo: String 
var avatar_color: String

func set_pseudo(new_pseudo: String):
	pseudo = new_pseudo

func get_pseudo() -> String:
	return pseudo

func set_avatar_color(new_avatar_color: String):
	avatar_color = new_avatar_color

func get_avatar_color() -> String:
	return avatar_color

func serialize() -> Dictionary:
	return {"pseudo": pseudo, "avatar_color": avatar_color}
