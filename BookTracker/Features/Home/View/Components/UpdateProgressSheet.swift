//
//  Untitled.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//
import SwiftUI

struct UpdateProgressSheet: View {
    // MARK: - Properties
    let book: Book
    var onSubmit: (Int) -> Void
    
    // MARK: - State
    @State private var inputPage: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    // MARK: - Main Body (Abstraction)
    var body: some View {
        NavigationStack {
            Form {
                inputSection
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear(perform: setupView)
        }
    }
}

// MARK: - Components & Builders
private extension UpdateProgressSheet {
    
    // 1. Input Section
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
            .listRowBackground(Color.clear) // Biar angka terlihat melayang bersih
        } header: {
            headerText
        }
    }
    
    // 2. Header Text
    var headerText: some View {
        Text("Current Page for '\(book.title)'")
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
    
    // 3. Toolbar Buttons
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", action: saveAction)
                .disabled(inputPage.isEmpty)
        }
    }
    
    // MARK: - Logic & Actions
    
    func setupView() {
        inputPage = "" // Reset input
        isFocused = true // Auto pop-up keyboard
    }
    
    func saveAction() {
        if let page = Int(inputPage) {
            onSubmit(page)
            dismiss()
        }
    }
}
