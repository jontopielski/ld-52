extends Panel

export(Texture) var empty_loop = null
export(Texture) var active_loop = null
export(Texture) var finished_loop = null

var percent_complete = 0.0
var moused_over = false

func _ready():
	if len(Globals.node_queue_positions) > 0:
		var node_count = len(Globals.node_queue_positions)
		var current_value = (float(Globals.node_index) / float(node_count)) * 100.0
		percent_complete = current_value

func _process(delta):
	if moused_over and $Tween.is_active() and get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
		get_tree().call_group("Terminal", "set_terminal_text", ("%.2f" % percent_complete) + '%' + " through day %d" % [Globals.loop_index])

func update_ui():
	var node_count = len(Globals.node_queue_positions)
	match Globals.loop_index:
		1:
			$HBox/Loop_01.texture = active_loop
			$HBox/Loop_02.texture = empty_loop
			$HBox/Loop_03.texture = empty_loop
			$HBox/Loop_01/Progress.value = (float(Globals.node_index) / float(node_count)) * 100.0
			$HBox/Loop_02/Progress.value = 0
			$HBox/Loop_03/Progress.value = 0
		2:
			$HBox/Loop_01.texture = finished_loop
			$HBox/Loop_02.texture = active_loop
			$HBox/Loop_03.texture = empty_loop
			$HBox/Loop_01/Progress.value = 0
			$HBox/Loop_02/Progress.value = (float(Globals.node_index) / float(node_count)) * 100.0
			$HBox/Loop_03/Progress.value = 0
		3:
			$HBox/Loop_01.texture = finished_loop
			$HBox/Loop_02.texture = finished_loop
			$HBox/Loop_03.texture = active_loop
			$HBox/Loop_01/Progress.value = 0
			$HBox/Loop_02/Progress.value = 0
			$HBox/Loop_03/Progress.value = (float(Globals.node_index) / float(node_count)) * 100.0
		4:
			$HBox/Loop_01.texture = finished_loop
			$HBox/Loop_02.texture = finished_loop
			$HBox/Loop_03.texture = finished_loop

func tween_progress_to_next_node(tween_time):
	var node_count = len(Globals.node_queue_positions)
	var current_value = (float(Globals.node_index) / float(node_count)) * 100.0
	var next_value = (float(Globals.node_index + 1) / float(node_count)) * 100.0
	match Globals.loop_index:
		1:
			$Tween.interpolate_property($HBox/Loop_01/Progress, "value", current_value, next_value, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, "percent_complete", current_value, next_value, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		2:
			$Tween.interpolate_property($HBox/Loop_02/Progress, "value", current_value, next_value, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, "percent_complete", current_value, next_value, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		3:
			$Tween.interpolate_property($HBox/Loop_03/Progress, "value", current_value, next_value, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, "percent_complete", current_value, next_value, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()

func _on_LoopProgress_mouse_entered():
	moused_over = true
	get_tree().call_group("Terminal", "set_terminal_text", ("%.2f" % percent_complete) + '%' + " through day %d" % [Globals.loop_index])

func _on_LoopProgress_mouse_exited():
	moused_over = false
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_Tween_tween_step(object, key, elapsed, value):
	if key == ":percent_complete":
		return
		CRTManager.set_darkness(value / 100.0)

func _on_Boss_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "Boss: appears at end of day 3", $HBox/Boss.texture)

func _on_Boss_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")
