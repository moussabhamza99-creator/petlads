# petal_ads_wrapper.gd
# Single-entry wrapper for Huawei Petal Ads integration in Godot 4.
# Handles native Java plugin calls on Android or mock behavior on desktop/editor.
# Dynamically loads Ad Slot IDs from res://petal_ads_config.json

extends Node

# Signals
signal banner_loaded
signal banner_failed(error_code, error_msg)
signal banner_clicked

signal interstitial_loaded
signal interstitial_failed(error_code, error_msg)
signal interstitial_opened
signal interstitial_closed

signal reward_loaded
signal reward_failed(error_code, error_msg)
signal reward_opened
signal reward_closed
signal reward_earned(type, amount)

const CONFIG_FILE_PATH: String = "res://petal_ads_config.json"
const PLUGIN_NAME: String = "GodotPetalAds"

# Default HMS Petal Ads Test Slot IDs
var app_id: String = "testq63x296kg1"
var banner_ad_id: String = "testw6ac88gbe3"
var banner_position: String = "BOTTOM"
var interstitial_ad_id: String = "testb4z2vhch44"
var rewarded_ad_id: String = "testx9dtjw2sp5"

var _plugin_singleton: Object = null
var _is_initialized: bool = false

# Dictionnaire des codes d'erreur officiels Huawei HMS Ads
const ERROR_CODES = {
	0: "SUCCESS - Requete reussie",
	1: "INNER_ERROR - Erreur interne du SDK HMS Ads",
	2: "INVALID_REQUEST - Parametres de requete invalides ou ID d'emplacement d'annonce incorrect",
	3: "NETWORK_ERROR - Erreur de connexion Internet (Vérifiez le Wifi/Donnees ou permissions INTERNET)",
	4: "NO_AD - Pas d'annonce disponible (Pas de remplissage / No Fill pour cet emplacement)",
	5: "LOW_API - Version API non supportee",
	6: "BANNER_SIZE_INVALID - Taille de banniere invalide",
	7: "HMS_CORE_UNAVAILABLE - HMS Core non installe ou non mis a jour sur cet appareil",
	800: "HMS_CORE_INTERNAL_ERROR - Service HMS Core inaccessible"
}

func _ready() -> void:
	load_config_from_json()

	if Engine.has_singleton(PLUGIN_NAME):
		_plugin_singleton = Engine.get_singleton(PLUGIN_NAME)
		_connect_signals()
		print("[PetalAdsWrapper] Native Huawei Petal Ads Plugin detected.")
	else:
		print("[PetalAdsWrapper] Running in editor/desktop. Using Mock Ads implementation.")

	init_ads()

func load_config_from_json(path: String = CONFIG_FILE_PATH) -> void:
	if not FileAccess.file_exists(path):
		print("[PetalAdsWrapper] Config JSON file not found at: ", path, ". Using default test IDs.")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("[PetalAdsWrapper] Error opening JSON config file: ", path)
		return

	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result != OK:
		print("[PetalAdsWrapper] JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return

	var config_data = json.data
	if typeof(config_data) == TYPE_DICTIONARY:
		if config_data.has("app_id"):
			app_id = config_data["app_id"]

		if config_data.has("banner") and typeof(config_data["banner"]) == TYPE_DICTIONARY:
			var banner_data = config_data["banner"]
			if banner_data.has("ad_id"): banner_ad_id = banner_data["ad_id"]
			if banner_data.has("position"): banner_position = banner_data["position"]

		if config_data.has("interstitial") and typeof(config_data["interstitial"]) == TYPE_DICTIONARY:
			var inter_data = config_data["interstitial"]
			if inter_data.has("ad_id"): interstitial_ad_id = inter_data["ad_id"]

		if config_data.has("rewarded_video") and typeof(config_data["rewarded_video"]) == TYPE_DICTIONARY:
			var reward_data = config_data["rewarded_video"]
			if reward_data.has("ad_id"): rewarded_ad_id = reward_data["ad_id"]

		print("[PetalAdsWrapper] Config JSON loaded successfully!")
		print(" - App ID: ", app_id)
		print(" - Banner Ad ID: ", banner_ad_id, " Position: ", banner_position)
		print(" - Interstitial Ad ID: ", interstitial_ad_id)
		print(" - Rewarded Ad ID: ", rewarded_ad_id)

func get_error_message(error_code: int) -> String:
	if ERROR_CODES.has(error_code):
		return "Code %d: %s" % [error_code, ERROR_CODES[error_code]]
	return "Code %d: Erreur inconnue HMS Ads" % error_code

func init_ads() -> void:
	if _plugin_singleton:
		_plugin_singleton.initAds()
		_is_initialized = true
		print("[PetalAdsWrapper] Initialized native Petal Ads SDK.")
	else:
		_is_initialized = true
		print("[PetalAdsWrapper] Initialized Mock Petal Ads SDK.")

# --- BANNER ADS ---

func load_banner(ad_id: String = "", position: String = "") -> void:
	var final_ad_id = ad_id if ad_id != "" else banner_ad_id
	var final_position = position if position != "" else banner_position

	if _plugin_singleton:
		_plugin_singleton.loadBanner(final_ad_id, final_position)
	else:
		print("[Mock] Loading Banner Ad ID: ", final_ad_id, " at position: ", final_position)
		get_tree().create_timer(1.0).timeout.connect(func():
			print("[Mock] Banner Loaded!")
			banner_loaded.emit()
		)

func show_banner() -> void:
	if _plugin_singleton:
		_plugin_singleton.showBanner()
	else:
		print("[Mock] Show Banner")

func hide_banner() -> void:
	if _plugin_singleton:
		_plugin_singleton.hideBanner()
	else:
		print("[Mock] Hide Banner")

# --- INTERSTITIAL ADS ---

func load_interstitial(ad_id: String = "") -> void:
	var final_ad_id = ad_id if ad_id != "" else interstitial_ad_id

	if _plugin_singleton:
		_plugin_singleton.loadInterstitial(final_ad_id)
	else:
		print("[Mock] Loading Interstitial Ad ID: ", final_ad_id)
		get_tree().create_timer(1.0).timeout.connect(func():
			print("[Mock] Interstitial Loaded!")
			interstitial_loaded.emit()
		)

func show_interstitial() -> void:
	if _plugin_singleton:
		_plugin_singleton.showInterstitial()
	else:
		print("[Mock] Displaying Interstitial Video/Ad")
		interstitial_opened.emit()
		get_tree().create_timer(2.0).timeout.connect(func():
			print("[Mock] Interstitial Closed")
			interstitial_closed.emit()
		)

# --- REWARDED VIDEO ADS ---

func load_reward_video(ad_id: String = "") -> void:
	var final_ad_id = ad_id if ad_id != "" else rewarded_ad_id

	if _plugin_singleton:
		_plugin_singleton.loadRewardVideo(final_ad_id)
	else:
		print("[Mock] Loading Rewarded Video Ad ID: ", final_ad_id)
		get_tree().create_timer(1.0).timeout.connect(func():
			print("[Mock] Rewarded Video Loaded!")
			reward_loaded.emit()
		)

func show_reward_video() -> void:
	if _plugin_singleton:
		_plugin_singleton.showRewardVideo()
	else:
		print("[Mock] Displaying Rewarded Video")
		reward_opened.emit()
		get_tree().create_timer(3.0).timeout.connect(func():
			print("[Mock] User watched full rewarded video! Granting reward...")
			reward_earned.emit("Coins", 50)
			reward_closed.emit()
		)

# --- SIGNAL CONNECTIONS ---

func _connect_signals() -> void:
	if not _plugin_singleton:
		return

	# Connect Godot Android plugin signals if available
	if _plugin_singleton.has_signal("on_banner_loaded"):
		_plugin_singleton.connect("on_banner_loaded", Callable(self, "_on_banner_loaded"))
	if _plugin_singleton.has_signal("on_banner_failed"):
		_plugin_singleton.connect("on_banner_failed", Callable(self, "_on_banner_failed"))
	if _plugin_singleton.has_signal("on_banner_clicked"):
		_plugin_singleton.connect("on_banner_clicked", Callable(self, "_on_banner_clicked"))

	if _plugin_singleton.has_signal("on_interstitial_loaded"):
		_plugin_singleton.connect("on_interstitial_loaded", Callable(self, "_on_interstitial_loaded"))
	if _plugin_singleton.has_signal("on_interstitial_failed"):
		_plugin_singleton.connect("on_interstitial_failed", Callable(self, "_on_interstitial_failed"))
	if _plugin_singleton.has_signal("on_interstitial_opened"):
		_plugin_singleton.connect("on_interstitial_opened", Callable(self, "_on_interstitial_opened"))
	if _plugin_singleton.has_signal("on_interstitial_closed"):
		_plugin_singleton.connect("on_interstitial_closed", Callable(self, "_on_interstitial_closed"))

	if _plugin_singleton.has_signal("on_reward_loaded"):
		_plugin_singleton.connect("on_reward_loaded", Callable(self, "_on_reward_loaded"))
	if _plugin_singleton.has_signal("on_reward_failed"):
		_plugin_singleton.connect("on_reward_failed", Callable(self, "_on_reward_failed"))
	if _plugin_singleton.has_signal("on_reward_opened"):
		_plugin_singleton.connect("on_reward_opened", Callable(self, "_on_reward_opened"))
	if _plugin_singleton.has_signal("on_reward_closed"):
		_plugin_singleton.connect("on_reward_closed", Callable(self, "_on_reward_closed"))
	if _plugin_singleton.has_signal("on_reward_earned"):
		_plugin_singleton.connect("on_reward_earned", Callable(self, "_on_reward_earned"))

# Native Callbacks
func _on_banner_loaded() -> void:
	banner_loaded.emit()

func _on_banner_failed(error_code: int) -> void:
	var msg = get_error_message(error_code)
	banner_failed.emit(error_code, msg)

func _on_banner_clicked() -> void:
	banner_clicked.emit()

func _on_interstitial_loaded() -> void:
	interstitial_loaded.emit()

func _on_interstitial_failed(error_code: int) -> void:
	var msg = get_error_message(error_code)
	interstitial_failed.emit(error_code, msg)

func _on_interstitial_opened() -> void:
	interstitial_opened.emit()

func _on_interstitial_closed() -> void:
	interstitial_closed.emit()

func _on_reward_loaded() -> void:
	reward_loaded.emit()

func _on_reward_failed(error_code: int) -> void:
	var msg = get_error_message(error_code)
	reward_failed.emit(error_code, msg)

func _on_reward_opened() -> void:
	reward_opened.emit()

func _on_reward_closed() -> void:
	reward_closed.emit()

func _on_reward_earned(type: String, amount: int) -> void:
	reward_earned.emit(type, amount)
