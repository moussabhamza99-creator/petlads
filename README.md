# Application Demo Huawei Petal Ads pour Godot 4+

Cette application d'exemple montre comment intégrer les publicités **Huawei Petal Ads** (HMS Ads) dans un projet **Godot 4+** pour Android (Bannière, Interstitiel et Vidéo Récompensée / Rewarded Video).

---

## 📁 Structure du Projet

```text
.
├── project.godot                     # Fichier de configuration du projet Godot 4
├── petal_ads_config.json             # Fichier de configuration JSON pour les IDs Petal Ads
├── icon.svg                          # Icône de l'application
├── scripts/
│   └── petal_ads_wrapper.gd          # Singleton GDScript lisant le JSON & gérant Petal Ads & Mock
├── scenes/
│   ├── main.tscn                     # Scène principale UI (Boutons + Logs + Compteur de pièces)
│   └── main.gd                       # Script de contrôle de l'interface
└── android/
    ├── settings.gradle
    └── plugins/
        └── godotpetalads/            # Module Plugin Android natif Godot 4
            ├── GodotPetalAds.gdip    # Fichier de configuration du plugin Godot
            ├── build.gradle          # Configuration Gradle et dépendance HMS Ads Lite SDK
            └── src/main/java/com/godot/petalads/
                └── GodotPetalAds.java # Code Java du plugin (Petal Ads SDK)
```

---

## ⚙️ Configuration JSON (`petal_ads_config.json`)

Toutes les clés d'annonces sont configurables dans le fichier `res://petal_ads_config.json` :

```json
{
  "app_id": "testq63x296kg1",
  "banner": {
    "ad_id": "testw6ac88gbe3",
    "position": "BOTTOM"
  },
  "interstitial": {
    "ad_id": "testb4z2vhch44"
  },
  "rewarded_video": {
    "ad_id": "testx9dtjw2sp5"
  }
}
```

Pour utiliser vos propres annonces Huawei AppGallery / Petal Ads Publisher, modifiez simplement les valeurs de ce fichier JSON sans toucher au code GDScript.

---

## 🛠️ Fonctionnalités du Singleton (`petal_ads_wrapper.gd`)

Le wrapper `PetalAds` (Autoload Godot) charge automatiquement le fichier `petal_ads_config.json` au démarrage.

### Méthodes disponibles :
* `init_ads()` : Initialise le SDK Petal Ads.
* `load_banner(ad_id, position)` : Charge une bannière (utilise la position et l'ID du JSON par défaut).
* `show_banner()` : Affiche la bannière.
* `hide_banner()` : Masque la bannière.
* `load_interstitial(ad_id)` : Charge un interstitiel (ID du JSON par défaut).
* `show_interstitial()` : Affiche l'interstitiel.
* `load_reward_video(ad_id)` : Charge une vidéo récompensée (ID du JSON par défaut).
* `show_reward_video()` : Affiche la vidéo récompensée.

---

## 📱 Compilation et Exportation Android pour Godot 4

### 1. Compilation du Plugin Android Natif sous Windows / Linux
Ouvrez un terminal dans le dossier `android/` :
* **Windows (PowerShell) :**
  ```powershell
  .\gradlew.bat :plugins:godotpetalads:assembleRelease
  ```
* **Linux / Mac / Git Bash :**
  ```bash
  ./gradlew :plugins:godotpetalads:assembleRelease
  ```

### 2. Configuration de l'Exportation Godot
1. Ouvrez le projet dans **Godot 4**.
2. Allez dans **Projet > Installer le modèle de build Android...** (Android Build Template).
3. Allez dans **Projet > Exporter...**, ajoutez un profil **Android**.
4. Cochez **Utiliser le build personnalisé (Custom Build)**.
5. Dans la section **Plugins**, cochez **GodotPetalAds**.
6. Dans les permissions Android (`Permissions`), activez `INTERNET` et `ACCESS_NETWORK_STATE`.
7. Exportez le projet au format `.apk`.
