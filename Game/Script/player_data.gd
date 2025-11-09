extends Resource
class_name PlayerData

@export var player_id: int
@export var username: String
@export var password: String
@export var coins: int = 0
@export var time_played: int = 0  # dalam detik
@export var item_collection: Array # ID dari Item_Base yang unlocked
@export var last_customer: int = 0    # ⬅️ TAMBAH INI
@export var last_item: int = 0        # ⬅️ TAMBAH INI

func update_from_api(api_data: Dictionary):
	# PAKE .get() DENGAN DEFAULT VALUE
	player_id = api_data.get("id", player_id)
	username = api_data.get("username", username)  # ← INI YANG BIASA ERROR
	password = api_data.get("password", password)  # ← INI JUGA
	coins = api_data.get("coins", coins)
	time_played = api_data.get("timePlayed", time_played)
	item_collection = api_data.get("itemCollection", item_collection)
	last_customer = api_data.get("lastCus", last_customer)      # ⬅️ TAMBAH
	last_item = api_data.get("lastItem", last_item)

func to_api_dict() -> Dictionary:
	return {
		"id": player_id,
		"username": username,
		"password": password,
		"coins": coins,
		"timePlayed": time_played,
		"itemCollection": item_collection,
		"lastCus": last_customer,      # ⬅️ TAMBAH
		"lastItem": last_item 
	}

# Helper functions untuk item collection
func add_to_collection(item_id: int):
	if not item_collection.has(item_id):
		item_collection.append(item_id)

func remove_from_collection(item_id: int):
	item_collection.erase(item_id)

func has_item(item_id: int) -> bool:
	return item_collection.has(item_id)

func initialize_offline(player_name: String):
	player_id = -1
	username = player_name
	password = "offline"
	coins = 1000
	time_played = 0
	item_collection = []
	last_customer = 0
	last_item = 0
