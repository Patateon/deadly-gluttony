extends Label

var elapsed_time = 0.0
var transition_duration = 1.50 # Duration of one full color cycle in seconds

func _process(delta):
	elapsed_time += delta
	
	var hue = fmod((elapsed_time / transition_duration), 1.0 ) 
	var color = Color.from_hsv(hue, 1.0, 1.0)  
	
	self.modulate = color  
	
	if elapsed_time >= transition_duration:
		elapsed_time = 0.0
