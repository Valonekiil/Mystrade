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

# GET semua players
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

func update_player(player_id: int, username: String, password: String, items: int) -> void:
	var url = BASE_URL + "/players/" + str(player_id)
	
	var json_data = JSON.stringify({
		"id": player_id,
		"username": username,
		"password": password,
		"item": items
	})
	
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
			print("Player updated: ", response)
		elif response_code == 404:
			update_player_completed.emit(null, "Player not found")
		else:
			update_player_completed.emit(null, "Update failed: " + str(response_code))
	else:
		update_player_completed.emit(null, "PUT request failed")

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
