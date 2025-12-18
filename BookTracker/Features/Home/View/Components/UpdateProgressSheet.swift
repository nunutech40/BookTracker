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
                Form {
                    inputSection
                }
                .navigationTitle("Update Progress")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .onAppear(perform: setupView)
                .onChange(of: inputPage, perform: validateInput)
                .alert("Invalid Page", isPresented: $showAlert) {
                    Button("OK") { }
                } message: {
                    Text("Please enter a valid page number between \(book.currentPage) and \(maxPage).")
                }
                .disabled(isSaving)
                
                if isSaving {
                    ProgressView("Saving...")
                        .progressViewStyle(.circular)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
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
                TextField("Page", text: $inputPage)
                    .keyboardType(.numberPad)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                Spacer()
            }
            .listRowBackground(Color.clear)
        } header: {
            Text("Enter page for '\(book.title)' (Max: \(maxPage))")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
                .disabled(isSaving)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", action: {
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
        // 1. Filter for numbers only
        let filtered = newValue.filter { "0123456789".contains($0) }
        
        // 2. Check if the filtered value is different
        if filtered != newValue {
            self.inputPage = filtered
        }

        // 3. Check against maxPage
        if let number = Int(filtered) {
            if number > self.maxPage {
                // Use DispatchQueue.main.async to avoid modifying state during a view update
                DispatchQueue.main.async {
                    self.inputPage = String(self.maxPage)
                }
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
        // Dismissal is handled by the parent view setting selectedBook to nil
    }
}
