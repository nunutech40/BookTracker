# AI Project Context Guide for BookTracker

Welcome to the BookTracker project! This guide will help you quickly get up to speed with the application's purpose, architecture, and implementation details.

## Step 1: Understand the Application from `README.md`

Before diving into the code, please thoroughly read the `README.md` file located in the project root. This document provides:
- A high-level overview of the BookTracker application.
- Its main features and functionalities.
- The core technologies used (SwiftUI, SwiftData, Google Books API).
- The architectural patterns followed (MVVM, Dependency Injection).
- Information about unit testing strategies.

Understanding the `README.md` will give you a solid foundation and context for the entire project.

## Step 2: Understand the Source Code

Once you have a clear understanding of what the application does, proceed to analyze the entire source code. Pay close attention to:
- **File Structure:** How the project is organized into `Core`, `Features`, and `Assets`.
- **`BookTrackerApp.swift`:** The application's entry point and how dependencies are initialized.
- **`Injection.swift`:** The Dependency Injection container and how services and view models are provided.
- **Model Layer:** (`Core/Data/Book.swift`, `ReadingSession.swift`) - The data structures and how they are persisted with SwiftData.
- **Service Layer:** (`Core/Service/BookService.swift`, `GoogleBooksService.swift`) - The business logic, data persistence operations, and external API interactions.
- **Feature Modules (MVVM):** Specifically, explore how `View`, `ViewModel`, and related components interact within features like `Home`, `Library`, `History`, and `Profile`.
- **Localization:** Understand how `Localizable.xcstrings` is used for multilingual support.
- **Data Scanning:** Review the implementation of `DataScannerView` and its integration.

By following these steps, you should gain a comprehensive understanding of the BookTracker project, enabling you to perform tasks effectively.
