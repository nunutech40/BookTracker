//
//  UpdateProgressSheet.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//
import SwiftUI

struct UpdateProgressSheet: View {
    // MARK: - Properties
    let book: Book
    let maxPage: Int
    var onSubmit: (Int) async -> Void
    
    // MARK: - State
    @State private var inputPage: String = ""
    @State private var showAlert = false
    @State private var isSaving = false
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Form Content
                Form {
                    inputSection
                }
                .navigationTitle(String(localized: "Update Progress"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .onAppear(perform: setupView)
                .onChange(of: inputPage, perform: validateInput)
                .alert(String(localized: "Invalid Page"), isPresented: $showAlert) {
                    Button(String(localized: "OK")) { }
                } message: {
                    Text(String(format: NSLocalizedString("Please enter a valid page number between %lld and %lld.", comment: ""), book.currentPage, maxPage))
                }
                .disabled(isSaving) // Disable form while saving
                
                // Native Loading Overlay
                if isSaving {
                    // Use a system material for a native, blurred background
                    // that adapts to light/dark mode automatically.
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                    
                    ProgressView(String(localized: "Saving..."))
                        .progressViewStyle(.circular)
                        .tint(.primary) // Ensure spinner color is visible in both themes
                        .padding()
                        .background(
                            // Add a thicker material background to the ProgressView itself
                            // for better legibility.
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.thickMaterial)
                        )
                        .shadow(radius: 10)
                }
            }
        }
    }
}

// MARK: - Components & Builders
private extension UpdateProgressSheet {
    
    var inputSection: some View {
        Section {
            HStack {
                Spacer()
                TextField(String(localized: "Page"), text: $inputPage)
                    .keyboardType(.numberPad)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                Spacer()
            }
            .listRowBackground(Color.clear)
        } header: {
            Text(String(format: NSLocalizedString("Enter page for '%@' (Max: %lld)", comment: ""), book.title, maxPage))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: "Cancel")) { dismiss() }
                .disabled(isSaving)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button(String(localized: "Save"), action: {
                Task {
                    await saveAction()
                }
            })
            .disabled(inputPage.isEmpty || isSaving)
        }
    }
    
    // MARK: - Logic & Actions
    
    func setupView() {
        self.inputPage = String(book.currentPage)
        isFocused = true
    }
    
    /// Validates the input in real-time.
    func validateInput(newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        
        if filtered != newValue {
            self.inputPage = filtered
        }

        if let number = Int(filtered), number > self.maxPage {
            DispatchQueue.main.async {
                self.inputPage = String(self.maxPage)
            }
        }
    }
    
    func saveAction() async {
        guard let page = Int(inputPage), page >= book.currentPage, page <= maxPage else {
            showAlert = true
            return
        }
        
        isSaving = true
        await onSubmit(page)
        // Dismissal is now handled by the parent view.
    }
}
