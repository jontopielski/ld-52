extends Resource

export(String) var name = ""
export(String) var description = ""
export(Enums.NodeType) var node_type = 0
export(Texture) var texture = null 

export(int) var cost = 0

export(Array, Resource) var enemies = []
export(Array, float) var spawn_rates = []
