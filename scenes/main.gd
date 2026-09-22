# main.gd
extends Control

@onready var coins_label: Label = $VBoxContainer/Header/CoinsLabel
@onready var status_label: Label = $VBoxContainer/StatusPanel/StatusLabel
@onready var log_box: TextEdit = $VBoxContainer/LogPanel/LogBox

@onready var btn_load_banner: Button = $VBoxContainer/BannerSection/HBox/BtnLoadBanner
@onready var btn_show_banner: Button = $VBoxContainer/BannerSection/HBox/BtnShowBanner
@onready var btn_hide_banner: Button = $VBoxContainer/BannerSection/HBox/BtnHideBanner

@onready var btn_load_interstitial: Button = $VBoxContainer/InterstitialSection/HBox/BtnLoadInterstitial
@onready var btn_show_interstitial: Button = $VBoxContainer/InterstitialSection/HBox/BtnShowInterstitial

@onready var btn_load_reward: Button = $VBoxContainer/RewardSection/HBox/BtnLoadReward
@onready var btn_show_reward: Button = $VBoxContainer/RewardSection/HBox/BtnShowReward

var coins: int = 0

func _ready() -> void:
	_log("App started. Connecting Petal Ads signals...")
	_update_coins_display()

	# Connect signals from PetalAds autoload
	PetalAds.banner_loaded.connect(_on_banner_loaded)
	PetalAds.banner_failed.connect(_on_banner_failed)
	PetalAds.banner_clicked.connect(_on_banner_clicked)

	PetalAds.interstitial_loaded.connect(_on_interstitial_loaded)
	PetalAds.interstitial_failed.connect(_on_interstitial_failed)
	PetalAds.interstitial_opened.connect(_on_interstitial_opened)
	PetalAds.interstitial_closed.connect(_on_interstitial_closed)

	PetalAds.reward_loaded.connect(_on_reward_loaded)
	PetalAds.reward_failed.connect(_on_reward_failed)
	PetalAds.reward_opened.connect(_on_reward_opened)
	PetalAds.reward_closed.connect(_on_reward_closed)
	PetalAds.reward_earned.connect(_on_reward_earned)

	# Initial button states
	btn_show_banner.disabled = true
	btn_hide_banner.disabled = true
	btn_show_interstitial.disabled = true
	btn_show_reward.disabled = true

	# Button signals
	btn_load_banner.pressed.connect(_on_btn_load_banner_pressed)
	btn_show_banner.pressed.connect(_on_btn_show_banner_pressed)
	btn_hide_banner.pressed.connect(_on_btn_hide_banner_pressed)

	btn_load_interstitial.pressed.connect(_on_btn_load_interstitial_pressed)
	btn_show_interstitial.pressed.connect(_on_btn_show_interstitial_pressed)

	btn_load_reward.pressed.connect(_on_btn_load_reward_pressed)
	btn_show_reward.pressed.connect(_on_btn_show_reward_pressed)

	_log("Petal Ads Wrapper ready.")

func _log(message: String) -> void:
	print("[UI] ", message)
	status_label.text = "Status: " + message
	if log_box:
		log_box.text += message + "\n"

func _update_coins_display() -> void:
	coins_label.text = "Coins: %d" % coins

# --- BANNER ACTIONS ---

func _on_btn_load_banner_pressed() -> void:
	_log("Demande de chargement de la Banner Ads...")
	PetalAds.load_banner()

func _on_btn_show_banner_pressed() -> void:
	_log("Affichage de la Banner Ads.")
	PetalAds.show_banner()
	btn_hide_banner.disabled = false

func _on_btn_hide_banner_pressed() -> void:
	_log("Masquage de la Banner Ads.")
	PetalAds.hide_banner()
	btn_hide_banner.disabled = true

# --- INTERSTITIAL ACTIONS ---

func _on_btn_load_interstitial_pressed() -> void:
	_log("Chargement de l'Interstitial Ad...")
	PetalAds.load_interstitial()

func _on_btn_show_interstitial_pressed() -> void:
	_log("Affichage de l'Interstitial Ad.")
	PetalAds.show_interstitial()

# --- REWARDED VIDEO ACTIONS ---

func _on_btn_load_reward_pressed() -> void:
	_log("Chargement de la Reward Video...")
	PetalAds.load_reward_video()

func _on_btn_show_reward_pressed() -> void:
	_log("Affichage de la Reward Video.")
	PetalAds.show_reward_video()

# --- CALLBACK SIGNAL HANDLERS ---

func _on_banner_loaded() -> void:
	_log("Banner Ad chargee avec succes !")
	btn_show_banner.disabled = false

func _on_banner_failed(error_code: int) -> void:
	_log("Echec de la Banner Ad. Code: %d" % error_code)

func _on_banner_clicked() -> void:
	_log("Banner Ad cliquee !")

func _on_interstitial_loaded() -> void:
	_log("Interstitial Ad charge avec succes !")
	btn_show_interstitial.disabled = false

func _on_interstitial_failed(error_code: int) -> void:
	_log("Echec de l'Interstitial Ad. Code: %d" % error_code)

func _on_interstitial_opened() -> void:
	_log("Interstitial Ad ouvert.")

func _on_interstitial_closed() -> void:
	_log("Interstitial Ad ferme.")
	btn_show_interstitial.disabled = true

func _on_reward_loaded() -> void:
	_log("Reward Video chargee avec succes !")
	btn_show_reward.disabled = false

func _on_reward_failed(error_code: int) -> void:
	_log("Echec de la Reward Video. Code: %d" % error_code)

func _on_reward_opened() -> void:
	_log("Reward Video ouverte.")

func _on_reward_closed() -> void:
	_log("Reward Video fermee.")
	btn_show_reward.disabled = true

func _on_reward_earned(type: String, amount: int) -> void:
	coins += amount
	_update_coins_display()
	_log("Recompense gagnees ! +%d %s" % [amount, type])
