extends HBoxContainer

const Icon = preload("res://src/cards/Icon.tscn")

func _ready():
	update_relics()

func update_relics():
	var current_relics = []
	for i in range(0, get_child_count()):
		current_relics.push_back(get_child(i).icon)
	var next_relics = Globals.relics
	
	for relic in current_relics:
		if !relic in next_relics:
			remove_relic_child(relic)
	
	for relic in next_relics:
		if !relic in current_relics:
			add_relic_child(relic)

func add_relic_child(relic):
	var next_icon = Icon.instance()
	add_child(next_icon)
	next_icon.set_icon(relic)
	next_icon.inverted = true
	next_icon.render_current_icon()

func remove_relic_child(relic):
	for relic_obj in get_children():
		if relic_obj.icon == relic:
			relic_obj.queue_free()
