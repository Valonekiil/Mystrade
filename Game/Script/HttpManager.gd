extends Node

const BASE_URL = "https://localhost:7025"  # Ganti dengan URL API Anda

signal request_completed(result, error)
signal login_success(player_data)
signal login_failed(error_message)
signal get_player_completed(player_data, error_message)
signal get_all_players_completed(players_data, error_message)  
signal update_player_completed(updated_player, error_message)
signal update_items_completed(updated_player, error_message)

func register_player(username: String, password: String) -> void:
	var url = BASE_URL + "/Players"
	
	var json_data = JSON.stringify({
		"username": username,
		"password": password,
		"item": 0  # Default value
	})
	
	# Create HTTP request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_register_completed.bind(http_request))
	
	# Headers
	var headers = ["Content-Type: application/json"]
	
	# Send POST request
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_register_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 201: 
			var response = JSON.parse_string(body.get_string_from_utf8())
			request_completed.emit(response, "")
			print("Player registered successfully: ", response)
		else:
			var error_message = "Registration failed. Status code: " + str(response_code)
			request_completed.emit(null, error_message)
			print(error_message)
	else:
		var error_message = "HTTP request failed: " + str(result)
		request_completed.emit(null, error_message)
		print(error_message)

func get_player_by_id(player_id: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_get_player_completed.bind(http_request))
	
	var error = http_request.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		push_error("GET request failed")

func _on_get_player_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 200:
			var response = JSON.parse_string(body.get_string_from_utf8())
			get_player_completed.emit(response, "")
			print("Player data: ", response)
		else:
			get_player_completed.emit(null, "Player not found")
	else:
		get_player_completed.emit(null, "GET request failed")

func get_all_players() -> void:
	var url = BASE_URL + "/players"
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_get_all_players_completed.bind(http_request))
	
	var error = http_request.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		push_error("GET all players failed")

func _on_get_all_players_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		get_all_players_completed.emit(response, "")
	else:
		get_all_players_completed.emit([], "Failed to get players")

func update_player(player_id: int, player_data: Dictionary) -> void:
	var url = BASE_URL + "/players/" + str(player_id)
	
	var json_data = JSON.stringify(player_data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_update_player_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, json_data)
	
	if error != OK:
		push_error("PUT request failed")

func _on_update_player_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 200:
			var response = JSON.parse_string(body.get_string_from_utf8())
			update_player_completed.emit(response, "")
			print("Player updated successfully!")
		elif response_code == 404:
			update_player_completed.emit(null, "Player not found")
		else:
			update_player_completed.emit(null, "Update failed: " + str(response_code))
	else:
		update_player_completed.emit(null, "HTTP request failed: " + str(result))

func update_player_items(player_id: int, new_items: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id) + "/items"
	
	var json_data = JSON.stringify({
		"item": new_items
	})
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_update_items_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_PATCH, json_data)
	
	if error != OK:
		push_error("PATCH request failed")

func _on_update_items_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		update_items_completed.emit(response, "")
		print("Items updated: ", response)
	else:
		update_items_completed.emit(null, "Failed to update items")

func update_player_data(player_data: Dictionary) -> void:
	var player_id = player_data["id"]
	var url = BASE_URL + "/players/" + str(player_id)
	
	var json_data = JSON.stringify(player_data)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_update_player_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, json_data)
	
	if error != OK:
		push_error("PUT request failed")

func login_player(username: String, password: String) -> void:
	var url = BASE_URL + "/players/login"
	
	var json_data = JSON.stringify({
		"username": username,
		"password": password
	})
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_login_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	
	if error != OK:
		push_error("Login request failed")

func _on_login_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 200:
			var response = JSON.parse_string(body.get_string_from_utf8())
			login_success.emit(response)
			print("Login berhasil! Player data: ", response)
		elif response_code == 401:
			login_failed.emit("Username atau password salah")
		else:
			login_failed.emit("Login gagal: " + str(response_code))
	else:
		login_failed.emit("HTTP request failed")

func start_game_session(player_id: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id) + "/start-game"
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_start_game_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST)
	
	if error != OK:
		push_error("Start game request failed")

func _on_start_game_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("Game session started successfully")

# End game session (POST /players/{id}/end-game)  
func end_game_session(player_id: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id) + "/end-game"
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_end_game_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST)
	
	if error != OK:
		push_error("End game request failed")

func _on_end_game_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("Game session ended successfully")

# Add item to collection (PATCH /players/{id}/items/add)
func add_item_to_collection(player_id: int, item_id: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id) + "/items/add"
	var json_data = JSON.stringify({"newItem": item_id})
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_add_item_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_PATCH, json_data)
	
	if error != OK:
		push_error("Add item request failed")

func _on_add_item_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("Item added to collection successfully")

# Update coins (PATCH /players/{id}/coins)
func update_player_coins(player_id: int, coins: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id) + "/coins"
	
	var json_data = JSON.stringify({
		"coins": coins
	})
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_update_coins_completed.bind(http_request))
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(url, headers, HTTPClient.METHOD_PATCH, json_data)
	
	if error != OK:
		push_error("Update coins request failed")

func _on_update_coins_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest):
	http_request.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("Coins updated successfully")
