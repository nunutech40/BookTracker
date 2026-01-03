# BookTracker App Store Release Checklist

Here are some suggestions for final polish before releasing to the App Store.

## Social & Virality (Share Productivity)
- [ ] **Reading Activity Share Card (Session-Based)**
  - Implementasi fitur generate gambar untuk setiap sesi baca yang baru selesai.
  - **Data Points to Include**:
    - *The Sprint*: Kecepatan baca (hal/menit).
    - *The Deep Work*: Durasi fokus tanpa gangguan.
    - *The Jump*: Progress dari halaman X ke Y.
    - *Context*: Timestamp (misal: "Late Night Session") + Mood Emoji.
  - **3 UI Themes Option**:
    - **Receipt Style**: Minimalis, monospace, techy (vibe developer).
    - **Glassmorphism**: Estetik, frosted glass, background blur dari cover buku.
    - **Activity Ring**: Ala Apple Watch rings untuk durasi & halaman.
  - **Growth Hooks**:
    - QR Code kecil yang nge-link ke App Store.
    - Statistik perbandingan (e.g., "Top 10% Reader today").
  - **Tech Stack**: Gunakan `ImageRenderer` (SwiftUI) & `SwiftCharts` untuk grafik kecepatan baca.
  
## Graphics & Assets
- [ ] **Add an App Icon**
  - The project is missing an app icon. The `AppIcon.appiconset` folder is there but doesn't contain any images. An app icon is required for App Store submission.

## App Polish & UX
- [ ] **Onboarding Screen (First-Time User)**
  - Implementasi screen intro yang muncul cuma sekali pas app pertama kali diinstall. Isinya highlight fitur utama.
- [ ] **Static Tutorial View (Account Menu)**
  - Tambahkan menu "Cara Penggunaan" atau "Tutorial" di halaman Akun/Settings. Isinya panduan static (bisa gambar + teks) biar user nggak bingung.
- [x] **Improve New User Experience**
  - Make the "empty state" view in `HomeView` a button that navigates to the "Add Book" screen. This gives new users a more direct call to action.
- [x] **Enhance User Feedback**
  - In the "Update Progress" sheet, add a text label that explains why the "Save" button is disabled if the page number is invalid (e.g., not greater than the current page).
- [x] **Handle Camera/Photo Permissions**
  - Implement a check for camera and photo library permissions. If access is denied, show an alert that guides the user to the Settings app to enable permissions.
- [x] **Clean Up Code**
  - Remove the obsolete `// TODO: Implement camera functionality` comment in `HomeView.swift` since the data scanner feature is now implemented.

## About & Support (Global Target)
- [x] **About App with Dynamic Versioning**
  - Implement logic to fetch and display the `Version` and `Build Number` langsung dari `Info.plist`.
- [x] **Refine About View UI**
  - Poles UI About View biar terlihat profesional dan modern.
- [x] **About Developer (Persuasive Story)**
  - Tulis section "About Developer" yang keren untuk menggerakkan hati user supaya mau kasih dukungan.
- [x] **Support the Developer Page**
  - Buat halaman terpisah untuk donasi dengan link global: **Buy Me a Coffee**, **Ko-fi**, atau **PayPal.me`.

## Firebase & Backend Services
- [ ] **Setup Firebase Cloud Messaging (FCM)**
  - Implementasi push notification remote.
- [ ] **Setup Firebase Crashlytics**
  - Hubungkan app ke Crashlytics untuk monitoring crash.
- [ ] **Setup Firebase Remote Config**
  - Implementasi Feature Flag/Toggle dari dashboard Firebase.
- [ ] **News/Updates Feed**
  - Halaman khusus untuk menampilkan berita/update dari remote notification.

## DevOps
- [ ] **Setup Fastlane**
  - Automasi proses upload ke TestFlight dan App Store Connect.