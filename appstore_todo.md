# BookTracker App Store Release Checklist

Here are some suggestions for final polish before releasing to the App Store.

- [ ] **Add an App Icon**
  - The project is missing an app icon. The `AppIcon.appiconset` folder is there but doesn't contain any images. An app icon is required for App Store submission.

- [x] **Improve New User Experience**
  - Make the "empty state" view in `HomeView` a button that navigates to the "Add Book" screen. This gives new users a more direct call to action.

- [x] **Enhance User Feedback**
  - In the "Update Progress" sheet, add a text label that explains why the "Save" button is disabled if the page number is invalid (e.g., not greater than the current page).

- [ ] **Handle Camera/Photo Permissions**
  - Implement a check for camera and photo library permissions. If access is denied, show an alert that guides the user to the Settings app to enable permissions.

- [x] **Clean Up Code**
  - Remove the obsolete `// TODO: Implement camera functionality` comment in `HomeView.swift` since the data scanner feature is now implemented.