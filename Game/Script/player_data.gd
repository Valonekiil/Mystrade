extends Resource
class_name PlayerData

@export var player_id: int
@export var username: String
@export var password: String
@export var items: int
@export var current_customer: int 
@export var current_item: int 
@export var gold: int 
@export var last_login: String

# Fungsi untuk update data
func update_from_api(api_data: Dictionary):
	player_id = api_data.get("id", player_id)
	username = api_data.get("username", username)
	password = api_data.get("password", password)
	items = api_data.get("item", items)
	gold = api_data.get("gold", gold)

# Fungsi untuk convert ke dictionary (buat API)
func to_api_dict() -> Dictionary:
	return {
		"id": player_id,
		"username": username,
		"password": password,
		"item": items,
		"gold": gold
	}
