extends Control

# Perfect 00e2fc
# Good 00ff00
# OK f2b800
# Miss f30000

func SetTextInfo(text: String):
	$HitAccText.text = "[center]" + text
	
	match text:
		"PERFECT":
			$HitAccText.set("theme_override_colors/default_color", Color("00e2fc"))
		"GOOD":
			$HitAccText.set("theme_override_colors/default_color", Color("00ff00"))
		"OK":
			$HitAccText.set("theme_override_colors/default_color", Color("f2b800"))
		_:
			$HitAccText.set("theme_override_colors/default_color", Color("f30000"))
