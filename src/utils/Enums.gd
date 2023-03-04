extends Node

enum ItemType {
	NONE,
	CARD,
	MAP_NODE,
	RELIC,
	REROLL,
	REWARD,
}

enum MapNodePosition {
	TOP,
	MIDDLE,
	BOTTOM
}

enum ModifyType {
	NONE,
	REMOVE,
	UPGRADE,
	IMBUE,
	FUSION,
	SWAP,
}

enum MapNodeType {
	# Nodes:
	NONE,
	HOME,
	ENEMY,
	ELITE,
	BOSS,
	RANDOM,
	BONUS,
	RELIC,
	REMOVE,
	FUSION,
	UPGRADE,
	IMBUE,
	# Edges:
	DASH,
	EQUALS,
	LESS_THAN,
	CROSS,
	GREATER_THAN
}
