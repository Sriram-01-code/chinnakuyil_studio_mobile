# Chinnakuyil Studio 2.0 - Technical Manual

## **1. Core Objective**
A premium, personalized recording suite built for **Sathiya (The Artist)** and **Sriram (The Producer)**. Optimized for recording vocal covers over YouTube/MP3 tracks with professional-grade UI and local-first audio persistence.

---

## **2. System Workflow**
1.  **Authentication**: Zero-friction login using First Name + DOB. 
    *   **Admin (Sriram)**: Unlocks curation tools (Add/Edit/Delete tracks).
    *   **Artist (Sathiya)**: Clean, high-performance stage focused on music.
2.  **The Stage (Library)**: Firestore-synced collection. 
    *   **Upsert Logic**: Tracks are updated by Title to prevent duplicates.
    *   **Filters**: Smart sorting by Newest, Challenge Level, and Ilayaraja Classics.
3.  **The Hub (Recording)**:
    *   **YouTube Integration**: Full-frame video with native controls.
    *   **Top-Highlight Lyrics**: Active line stays at the top for maximum visibility of upcoming lyrics.
    *   **Nightingale Aura**: A soft, reactive glow that breathes with the singer's voice amplitude.
4.  **The Vault (Archives)**:
    *   **Local Storage**: Files are saved as `.wav` on the device for privacy and speed.
    *   **Versioning**: Multiple takes of the same song are grouped (e.g., Take 1, Take 2).
    *   **Vocal FX**: Simulated Reverb (Studio, Hall, Cathedral) and AI Noise Clean during playback.

---

## **3. Tech Stack**
*   **Framework**: Flutter (Dart)
*   **Backend**: Firebase Firestore (Metadata), Local SQFlite (File Tracking).
*   **Audio**: `record` (Capture), `audioplayers` (Playback/FX), `youtube_player_iframe` (Sync).
*   **Visuals**: `flutter_animate` (Aura/Glow), `google_fonts` (Tamil optimization via Catamaran).

---

## **4. Component Logic**

### **Lyrics Top-Highlight Scroller**
Located in `studio_screen.dart`.
*   **Logic**: Highlighting starts at the top line.
*   **Math**: `padding: EdgeInsets.only(bottom: viewportHeight - itemHeight)`.
*   **Result**: The singer sees the current line at the top and the next 5-6 lines below it.

### **Nightingale Aura**
Located in `studio_screen.dart`.
*   **Logic**: Connects to `AudioRecorder.onAmplitudeChanged`.
*   **UI**: A circular gradient that scales from 1.0 to 1.5 based on dB levels (-60 to 0).

---

## **5. Database Schema (Firestore: `songs`)**
| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | String | Unique Identifier for Upsert |
| `lyrics` | String | Tamil/English text with \n |
| `composer` | String | Music Director (e.g., Ilayaraja) |
| `difficulty`| String | Easy, Medium, Masterpiece |
| `searchKeywords` | Array | Tags for rapid search |

---

## **6. Build & Environment Fixes**
*   **Path Issue**: Bypassed `jlink.exe` crash via `gradle.properties` flags.
*   **Drives**: Disabled incremental Kotlin to fix cross-drive (C: to D:) root errors.
*   **Cloud Build**: Use GitHub Actions for a clean Linux build environment to avoid all local PC path errors.

---
**Build Version**: 2.0.0+1 (Nightingale Edition)
**Status**: Release Ready
