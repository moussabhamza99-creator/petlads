# petal_ads_wrapper.gd
# Single-entry wrapper for Huawei Petal Ads integration in Godot 4.
# Handles native Java plugin calls on Android or mock behavior on desktop/editor.

extends Node

# Signals
signal banner_loaded
signal banner_failed(error_code)
signal banner_clicked

signal interstitial_loaded
signal interstitial_failed(error_code)
signal interstitial_opened
signal interstitial_closed

signal reward_loaded
signal reward_failed(error_code)
signal reward_opened
signal reward_closed
signal reward_earned(type, amount)

# HMS Petal Ads Test Slot IDs (Official Huawei Test IDs)
const TEST_BANNER_ID: String = "testw6ac88gbe3"
const TEST_INTERSTITIAL_ID: String = "testb4z2vhch44"
const TEST_REWARDED_ID: String = "testx9dtjw2sp5"

const PLUGIN_NAME: String = "GodotPetalAds"

var _plugin_singleton: Object = null
var _is_initialized: bool = false

func _ready() -> void:
	if Engine.has_singleton(PLUGIN_NAME):
		_plugin_singleton = Engine.get_singleton(PLUGIN_NAME)
		_connect_signals()
		print("[PetalAdsWrapper] Native Huawei Petal Ads Plugin detected.")
	else:
		print("[PetalAdsWrapper] Running in editor/desktop. Using Mock Ads implementation.")

	init_ads()

func init_ads() -> void:
	if _plugin_singleton:
		_plugin_singleton.initAds()
		_is_initialized = true
		print("[PetalAdsWrapper] Initialized native Petal Ads SDK.")
	else:
		_is_initialized = true
		print("[PetalAdsWrapper] Initialized Mock Petal Ads SDK.")

# --- BANNER ADS ---

func load_banner(ad_id: String = TEST_BANNER_ID, position: String = "BOTTOM") -> void:
	if _plugin_singleton:
		_plugin_singleton.loadBanner(ad_id, position)
	else:
		print("[Mock] Loading Banner Ad ID: ", ad_id, " at position: ", position)
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

func load_interstitial(ad_id: String = TEST_INTERSTITIAL_ID) -> void:
	if _plugin_singleton:
		_plugin_singleton.loadInterstitial(ad_id)
	else:
		print("[Mock] Loading Interstitial Ad ID: ", ad_id)
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

func load_reward_video(ad_id: String = TEST_REWARDED_ID) -> void:
	if _plugin_singleton:
		_plugin_singleton.loadRewardVideo(ad_id)
	else:
		print("[Mock] Loading Rewarded Video Ad ID: ", ad_id)
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
func _on_banner_loaded() -> void: banner_loaded.emit()
func _on_banner_failed(error_code: int) -> void: banner_failed.emit(error_code)
func _on_banner_clicked() -> void: banner_clicked.emit()

func _on_interstitial_loaded() -> void: interstitial_loaded.emit()
func _on_interstitial_failed(error_code: int) -> void: interstitial_failed.emit(error_code)
func _on_interstitial_opened() -> void: interstitial_opened.emit()
func _on_interstitial_closed() -> void: interstitial_closed.emit()

func _on_reward_loaded() -> void: reward_loaded.emit()
func _on_reward_failed(error_code: int) -> void: reward_failed.emit(error_code)
func _on_reward_opened() -> void: reward_opened.emit()
func _on_reward_closed() -> void: reward_closed.emit()
func _on_reward_earned(type: String, amount: int) -> void: reward_earned.emit(type, amount)
