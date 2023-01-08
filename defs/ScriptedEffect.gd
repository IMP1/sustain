extends ItemEffect
class_name ScriptedItemEffect

export(Script) var effect_script: Script
export(String) var function_name: String = "act"

func activate(user) -> void:
	# TODO: Test this. What is a `Script`? Does it need initialising?
	print(effect_script)
	effect_script.call(function_name, user)
