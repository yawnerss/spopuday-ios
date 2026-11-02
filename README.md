# 🎵 SPOPUDAY for iOS

Native Swift + WKWebView iOS application for SPOPUDAY with background audio playback, lock screen media controls, and automated cloud `.ipa` packaging via GitHub Actions.

---

## 🚀 How to Build the `.ipa` (No Mac Needed!)

This project uses **GitHub Actions** with macOS cloud runners to compile and produce an installable `SPOPUDAY.ipa`.

### Step 1: Create a GitHub Repository
1. Go to [github.com/new](https://github.com/new) and create a new repository (e.g. `spopuday-ios`).
2. Keep it **Public** or **Private**.

### Step 2: Push this folder to your repository
Open PowerShell inside `C:\Users\RYZEN PRO\Downloads\SPOPUDAY_iOS`:

```powershell
cd "C:\Users\RYZEN PRO\Downloads\SPOPUDAY_iOS"
git init
git add .
git commit -m "Initial SPOPUDAY iOS project with GitHub Actions"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/spopuday-ios.git
git push -u origin main
```

### Step 3: Download the `.ipa`
1. Go to your repository on GitHub.
2. Click on the **Actions** tab.
3. You will see **"Build SPOPUDAY iOS IPA"** running.
4. Once completed (typically 1–2 minutes), click on the build summary.
5. Under **Artifacts**, click **`SPOPUDAY-iOS-IPA`** to download your ready-to-install `SPOPUDAY.ipa`!

---

## 📱 How to Install on iPhone / iPad

You can install this `.ipa` using any of these popular free sideloading tools:
- **AltStore** (Windows / Mac) — [altstore.io](https://altstore.io)
- **Sideloadly** (Windows / Mac) — [sideloadly.io](https://sideloadly.io)
- **TrollStore** (if compatible iOS version)
- **Scarlet** — direct on-device installer

Simply connect your iPhone via USB, open Sideloadly or AltStore, drag and drop `SPOPUDAY.ipa`, sign in with your free Apple ID, and it will install directly onto your iPhone!

---

## 🎧 Features Included
- **Lock Screen Controls:** Integrates with iOS `MPRemoteCommandCenter` and `MPNowPlayingInfoCenter` (Play, Pause, Skip, Previous).
- **Background Audio:** Plays music in the background and with the screen locked via `AVAudioSession` category `.playback`.
- **Custom Server Support:** Connects to your local SPOPUDAY server or hosted cloud server URL.
- **No Zooming:** Fixed viewport preventing accidental 2-finger zoom.
- **Pull to Refresh:** Pull down anywhere to refresh the app cleanly.

