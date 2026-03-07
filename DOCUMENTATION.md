# Chinnakuyil Studio 2.0 - Comprehensive Documentation

## **1. Executive Summary & Objective**
**Objective**: To provide a premium, private, and highly personalized recording sanctuary for **Sathiya (Chinnakuyil)** and a powerful curation tool for **Sriram**. The app enables the high-fidelity capture of vocal performances over backing tracks, specifically optimized for the complex nuances of Ilayaraja's music.

---

## **2. Core Workflow**
1.  **Identity Verification**: Users log in using their first name and date of birth. This unlocks personalized greetings and permissions.
2.  **The Stage (Discovery & Curation)**:
    *   Browse a cloud-synced library of tracks.
    *   Use advanced filters (Ilayaraja hits) and sorting (Challenge level, New Arrival, A-Z).
    *   **Universal Curation**: Both the Artist and the Producer can add new tracks or refine existing metadata (lyrics, movie, composer, difficulty).
3.  **The Hub (Performance)**:
    *   Select a track to enter the studio.
    *   Lyrics auto-scroll with a **Top-Highlight** system for maximum anticipation of lines.
    *   **Nightingale Aura**: A soft, breathing visual feedback that reacts to vocal intensity live.
4.  **The Vault (Archives)**:
    *   Recordings are saved locally as high-quality `.wav` files.
    *   Multiple takes of the same song are automatically grouped as "Takes" (Take 1, Take 2).
    *   Review performances with **Vocal FX** (Reverb presets) and **AI Noise Clean** simulations.
5.  **Offline Capability**: The app prioritizes local storage for privacy and performance, ensuring the artist can sing anywhere without data dependency.

---

## **3. Tech Stack**
*   **Framework**: Flutter (Dart) - *Material 3 Design*.
*   **Database**: 
    *   **Cloud**: Firebase Firestore (Central Track Library).
    *   **Local**: SQFlite (Recording Management & Versioning).
*   **Audio Engine**: 
    *   `record`: High-fidelity capture with real-time dB monitoring.
    *   `audioplayers`: Native playback with balance/volume control.
    *   `youtube_player_iframe`: Standardized backing track delivery.
*   **Visuals & FX**: `flutter_animate` (Reactive Aura), custom Glassmorphism components.
*   **Environment**: Optimized for **GitHub Actions** & **Codemagic** cloud builds.

---

## **4. Component Breakdown**

### **A. Screens**
| Component | Objective | Key Description |
| :--- | :--- | :--- |
| `AuthScreen` | Personalized Entry | Personalized login with hint text and specific profile logic. |
| `MainWrapper` | Navigation Architecture | Floating glass bottom navigation and the Onboarding/Birthday logic. |
| `StageScreen` | Library & Curation | The central hub for discovery. Includes the "ADD TRACK" button and long-press edit functionality for all users. |
| `StudioScreen` | The Hub | The performance environment. Features Top-Highlight lyrics and the reactive Nightingale Aura. |
| `VaultScreen` | The Archives | Local device-specific archive. Features large, glowing Play buttons and TAKE grouping. |
| `PlaybackScreen` | The Review Suite | High-end player with Vocal FX (Reverb/Noise Clean) and real-time seek synchronization. |

### **B. Services**
| Component | Objective | Key Description |
| :--- | :--- | :--- |
| `FirebaseService` | Cloud Sync | Manages the Upsert logic for tracks to prevent duplicates and keep the library fresh. |
| `MobileStorageService` | Local Reliability | Manages physical files and performs automatic asset scanning of `assets/sfx/`. |
| `NotificationService` | User Connection | Triggers deeply personal, non-generic local notifications. |

---

## **5. Logic & Mathematics**

### **Lyrics Top-Highlight Scroller**
*   **Logic**: Highlighting starts at the top of the viewport.
*   **Result**: The singer sees the current line clearly at the top, leaving the rest of the screen entirely for upcoming lines.
*   **Calibration**: `padding: EdgeInsets.only(bottom: viewportHeight - itemHeight)`.

### **Nightingale Aura (Dynamic Glow)**
*   **Logic**: Connects to the micro-amplitude stream of the `AudioRecorder`.
*   **Varying Effect**: Glow expands/contracts smoothly based on vocal volume (dB mapping).

---

## **6. Build Environment Configuration**
*   **Gradle Properties**: Includes "Nuclear Fixes" to bypass local path errors (spaces/quotes) and cross-drive root issues.
*   **APK Generation**: Pre-configured for cloud builders (GitHub Actions/Codemagic) to ensure a 100% stable Release APK.

---
**Document Version**: 2.0.0 (Release Candidate)
**Last Updated**: March 8th
