extends Resource

export(String) var name = ""
export(String) var description = ""
export(Enums.Rarity) var rarity = Enums.Rarity.NONE

export(int) var cost = 0

export(int) var damage = 0
export(int) var shield = 0
export(int) var gold = 0

export(Array, Resource) var effects = []
