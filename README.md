# Application Demo Huawei Petal Ads pour Godot 4+

Cette application d'exemple montre comment intégrer les publicités **Huawei Petal Ads** (HMS Ads) dans un projet **Godot 4+** pour Android (Bannière, Interstitiel et Vidéo Récompensée / Rewarded Video).

---

## 📁 Structure du Projet

```text
.
├── project.godot                     # Fichier de configuration du projet Godot 4
├── icon.svg                          # Icône de l'application
├── scripts/
│   └── petal_ads_wrapper.gd          # Singleton / Autoload GDScript gérant Petal Ads & Mock
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

## 🚀 Identifiants de Test Huawei Petal Ads

Le projet utilise par défaut les identifiants officiels de test fournis par Huawei :

* **Bannière (Banner) :** `testw6ac88gbe3`
* **Interstitiel (Interstitial) :** `testb4z2vhch44`
* **Vidéo Récompensée (Rewarded Video) :** `testx9dtjw2sp5`

---

## 🛠️ Fonctionnalités du Singleton (`petal_ads_wrapper.gd`)

Le wrapper `PetalAds` (déclaré comme Autoload dans Godot) gère à la fois le mode **Android natif** et le mode **Simulation / Mock** lorsque vous exécutez le jeu dans l'éditeur Godot ou sur PC.

### Méthodes disponibles :
* `init_ads()` : Initialise le SDK Petal Ads.
* `load_banner(ad_id, position)` : Charge une bannière ("TOP" ou "BOTTOM").
* `show_banner()` : Affiche la bannière.
* `hide_banner()` : Masque la bannière.
* `load_interstitial(ad_id)` : Charge une publicité interstitielle.
* `show_interstitial()` : Affiche l'interstitiel chargé.
* `load_reward_video(ad_id)` : Charge une vidéo récompensée.
* `show_reward_video()` : Affiche la vidéo récompensée.

### Signaux émis :
* `banner_loaded`, `banner_failed(error_code)`, `banner_clicked`
* `interstitial_loaded`, `interstitial_failed(error_code)`, `interstitial_opened`, `interstitial_closed`
* `reward_loaded`, `reward_failed(error_code)`, `reward_opened`, `reward_closed`, `reward_earned(type, amount)`

---

## 📱 Compilation et Exportation Android pour Godot 4

### 1. Compilation du Plugin Android Natif
Pour générer le fichier `.aar` de la bibliothèque native :
1. Téléchargez la bibliothèque Godot Android `godot-lib.template_release.aar` correspondant à votre version de Godot 4 et placez-la dans `android/plugins/godotpetalads/libs/`.
2. Ouvrez un terminal dans le dossier `android/` et exécutez :
   ```bash
   ./gradlew :plugins:godotpetalads:assembleRelease
   ```
3. Copiez le fichier `.aar` généré depuis `android/plugins/godotpetalads/build/outputs/aar/` vers `android/plugins/godotpetalads/GodotPetalAds.aar`.

### 2. Configuration de l'Exportation Godot
1. Ouvrez le projet dans **Godot 4**.
2. Allez dans **Projet > Installer le modèle de build Android...** (Android Build Template).
3. Dans **Projet > Paramètres du projet > Autoload**, vérifiez que `PetalAds` pointe vers `res://scripts/petal_ads_wrapper.gd`.
4. Allez dans **Projet > Exporter...**, ajoutez un profil **Android**.
5. Cochez **Utiliser le build personnalisé (Custom Build)**.
6. Dans la section **Plugins**, cochez **GodotPetalAds**.
7. Dans les permissions Android (`Permissions`), assurez-vous d'activer `INTERNET` et `ACCESS_NETWORK_STATE`.
8. Exportez le projet au format `.apk`.
