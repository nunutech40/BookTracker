# Aplikasi BookTracker

BookTracker adalah aplikasi seluler yang dirancang untuk membantu pengguna mengelola dan melacak kemajuan membaca mereka. Aplikasi ini menyediakan fitur untuk mencatat halaman terakhir yang dibaca dari sebuah buku, memvisualisasikan aktivitas membaca, dan menemukan buku baru melalui integrasi Google Books.

## Fitur Utama

*   **Pelacakan Kemajuan Membaca:** Catat dengan mudah halaman terakhir yang Anda baca di buku apa pun. Data ini disimpan menggunakan SwiftData dan dikelola oleh `BookService`.
*   **Dasbor Aktivitas Membaca:** Visualisasikan kebiasaan dan riwayat membaca Anda melalui dasbor aktivitas yang intuitif, termasuk peta panas (heatmap) yang dihasilkan dari sesi membaca Anda. Aktivitas membaca dimuat dan ditampilkan dari data `ReadingSession` melalui `BookService`.
*   **Integrasi Google Books:** Cari buku menggunakan Google Books API. Aplikasi ini memungkinkan Anda menambahkan buku ke perpustakaan dengan mengambil detail dan gambar sampul langsung dari Google Books.
*   **Manajemen Buku:** Tambah, edit, dan lihat detail buku Anda.

## Arsitektur

Aplikasi ini dibangun mengikuti pola arsitektur **MVVM (Model-View-ViewModel)**, yang mendorong pemisahan tanggung jawab yang jelas:

*   **Model:** Struktur data yang mewakili entitas inti aplikasi, seperti `Book` dan `ReadingSession`, yang dipertahankan menggunakan **SwiftData**.
*   **View:** Komponen UI yang bertanggung jawab untuk menyajikan informasi kepada pengguna (misalnya, `HomeView`, `BookEditorView`).
*   **ViewModel:** Bertindak sebagai perantara antara View dan Model, menangani logika tampilan, manajemen status, dan mengatur aliran data (misalnya, `HomeViewModel`, `BookEditorViewModel`).
*   **Layanan (Services):** Lapisan layanan khusus (`BookService`, `GoogleBooksService`) merangkum logika bisnis, operasi persistensi data (SwiftData), dan interaksi API eksternal (Google Books API).

## Teknologi yang Digunakan

*   **Swift:** Bahasa pemrograman utama.
*   **SwiftUI:** Untuk membangun antarmuka pengguna deklaratif.
*   **SwiftData:** Untuk persistensi dan manajemen data lokal.
*   **Google Books API:** Untuk mencari dan mengambil informasi buku.

## Pengujian Unit (Unit Testing)

Proyek ini mencakup pengujian unit untuk lapisan layanannya guna memastikan keandalan dan kebenaran. Secara khusus:

*   **`BookServiceTest.swift`**: Menguji logika inti untuk mengelola buku dan sesi membaca.
*   **`GoogleBookServiceTest.swift`**: Menguji integrasi dengan Google Books API, menggunakan `MockURLProtocol` untuk mensimulasikan respons jaringan dan memastikan pengujian yang terisolasi dan andal.

## Memulai

*(Instruksi tentang cara menyiapkan dan menjalankan proyek akan ditambahkan di sini.)*
